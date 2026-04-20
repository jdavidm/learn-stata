* course: 597a
* assignment: 14
* created on: 19 apr 26
* created by: jdm
* edited on: 19 apr 26
* edited by: jdm
* stata v.19.5


**********************************************************************
**# 0 - setup
**********************************************************************

* define rural roads data path (modify the start of the path for your computer)
	global			rr "C:/Users/YourName/OneDrive - University of Arizona/Michler, Jeffrey David - (jdmichler)'s files - rural_roads/data"

* baseline controls
	global			blcontrols primary_school med_center elect ///
						tdist irr_share ln_land pc01_lit_share ///
						pc01_sc_share bpl_landed_share ///
						bpl_inc_source_sub_share bpl_inc_250plus

* open log
	cap             log close
	log             using "$logout/14-rdd.log", append


**********************************************************************
**# exercise 1 - RD Plot
**********************************************************************

* load data (cross-section)
	use             "$rr/gjp_main_working.dta", clear
	keep if         year == 2012

* rd plot of fire counts
	rdplot          fires10km v_pop if abs(v_pop) <= 250, ///
						c(0) nbins(20 20) ///
						graph_options(xtitle("Population minus threshold") ///
						ytitle("Annual fire count (10 km)") ///
						graphregion(color(white)))
	graph export    "$answ/14-rdd-plot.png", replace

**## 1.1 - interpretation
	*** there is visual evidence of a discontinuity at the
	*** threshold: fire counts appear to increase just above the
	*** cutoff where villages become eligible for road construction


**********************************************************************
**# exercise 2 - Reduced-Form RD
**********************************************************************

* load data
	use             "$rr/gjp_main_working.dta", clear

* unweighted reduced form - fires
	reghdfe         fires10km t left right, ///
						a(year dist_thresh_id) ///
						vce(cluster village_id)
	eststo          rf1

* kernel-weighted reduced form - fires
	reghdfe         fires10km t left right ///
						[aw = kernel_tri_ik], ///
						a(year dist_thresh_id) ///
						vce(cluster village_id)
	eststo          rf2

* kernel-weighted reduced form - pm 2.5
	reghdfe         pm25 t left right pm25_bl2001 ///
						[aw = kernel_tri_ik], ///
						a(year dist_thresh_id) ///
						vce(cluster village_id)
	eststo          rf3

**## 2.1 - export reduced-form table

	esttab          rf1 rf2 rf3 using "$answ/14-rdd-ols.tex", replace ///
						b(3) se(3) ///
						keep(t) coeflabels(t "Above threshold") ///
						star(* 0.10 ** 0.05 *** 0.01) ///
						mtitles("Fires" "Fires (wt)" "PM 2.5 (wt)") ///
						stats(N r2, labels("Observations" "R-squared") ///
							fmt(0 3)) ///
						noobs booktabs nonum collabels(none) ///
						nobaselevels nogaps fragment label ///
						prehead("\begin{tabular}{l*{3}{c}} " ///
							"\\[-1.8ex]\hline \hline \\[-1.8ex] " ///
							"& \multicolumn{3}{c}{Reduced-Form RD}" ///
							" \\ \midrule") ///
						postfoot("\hline \hline \\[-1.8ex] " ///
							"\multicolumn{4}{p{\linewidth}}{\small " ///
							"\noindent \textit{Note}: Dependent " ///
							"variable indicated in column header. " ///
							"All models include district-threshold " ///
							"and year FE. Columns 2--3 use " ///
							"triangular kernel weights. Std.\ errors " ///
							"clustered at village level. " ///
							"* p$<$0.10, ** p$<$0.05, " ///
							"*** p$<$0.01.} " ///
							"\end{tabular}")

**## 2.2 - interpretation
	*** the coefficient on t captures the jump in fire counts at the
	*** population threshold. kernel weighting gives more influence
	*** to observations close to the cutoff, potentially changing
	*** the estimate by reweighting the sample toward more comparable
	*** villages


**********************************************************************
**# exercise 3 - Using rdrobust
**********************************************************************

* load data (cross-section)
	use             "$rr/gjp_main_working.dta", clear
	keep if         year == 2012

* default rdrobust
	rdrobust        fires10km v_pop, c(0)
	*** note the optimal bandwidth and number of observations

* bandwidth sensitivity
	matrix          bw_results = J(6, 4, .)
	local           bandwidths 25 50 75 100 150 200
	local           row = 1

	foreach bw of local bandwidths {
		rdrobust    fires10km v_pop, c(0) h(`bw')
		matrix      bw_results[`row', 1] = `bw'
		matrix      bw_results[`row', 2] = e(tau_cl)
		matrix      bw_results[`row', 3] = e(ci_l_cl)
		matrix      bw_results[`row', 4] = e(ci_r_cl)
		local       ++row
	}

* convert matrix to dataset for plotting
	preserve
	clear
	svmat           bw_results
	rename          (bw_results1 bw_results2 bw_results3 bw_results4) ///
						(bandwidth estimate ci_lo ci_hi)

	twoway          (rcap ci_lo ci_hi bandwidth, lcolor(navy)) ///
						(scatter estimate bandwidth, ///
						mcolor(navy) msymbol(circle)), ///
						yline(0, lcolor(maroon) lpattern(dash)) ///
						ytitle("RD Estimate") ///
						xtitle("Bandwidth") ///
						legend(off) ///
						graphregion(color(white))
	graph export    "$answ/14-rdd-bw.png", replace
	restore

**## 3.1 - interpretation
	*** report the default bandwidth and number of observations
	*** assess whether the estimate is stable across bandwidths


**********************************************************************
**# exercise 4 - First Stage
**********************************************************************

* load data
	use             "$rr/gjp_main_working.dta", clear

* first-stage regression
	reghdfe         receivedroad t left right $blcontrols ///
						[aw = kernel_tri_ik], ///
						a(year dist_thresh_id) ///
						vce(cluster village_id)
	eststo          fs

* first-stage rd plot
	preserve
	keep if         year == 2012
	rdplot          receivedroad v_pop if abs(v_pop) <= 250, ///
						c(0) nbins(20 20) ///
						graph_options(xtitle("Population minus threshold") ///
						ytitle("Received road") ///
						graphregion(color(white)))
	graph export    "$answ/14-rdd-first-stage.png", replace
	restore

**## 4.1 - interpretation
	*** the coefficient on t shows the increase in probability of
	*** receiving a road when crossing the threshold

**## 4.2 - f-statistic
	*** check whether the f-statistic exceeds 10


**********************************************************************
**# exercise 5 - Fuzzy RDD
**********************************************************************

* load data
	use             "$rr/gjp_main_working.dta", clear

* fuzzy rd - fires
	ivreghdfe       fires10km (receivedroad = t) left right ///
						fires2001_10km $blcontrols ///
						[aw = kernel_tri_ik], ///
						a(year dist_thresh_id) cluster(village_id)
	eststo          iv_fires
	su              fires10km if e(sample) & t == 0
	estadd scalar   depvarmean = r(mean)

* fuzzy rd - pm 2.5
	ivreghdfe       pm25 (receivedroad = t) left right ///
						pm25_bl2001 $blcontrols ///
						[aw = kernel_tri_ik], ///
						a(year dist_thresh_id) cluster(village_id)
	eststo          iv_pm
	su              pm25 if e(sample) & t == 0
	estadd scalar   depvarmean = r(mean)

**## 5.1 - four-column table

	esttab          fs rf2 iv_fires iv_pm ///
						using "$answ/14-rdd-fuzzy.tex", replace ///
						b(3) se(3) ///
						keep(t receivedroad) ///
						coeflabels(t "Above threshold" ///
							receivedroad "Road built") ///
						star(* 0.10 ** 0.05 *** 0.01) ///
						mtitles("Road" "Fires" "Fires" "PM 2.5") ///
						stats(N depvarmean, ///
							labels("Observations" ///
								"Control group mean") ///
							fmt(0 2)) ///
						noobs booktabs nonum collabels(none) ///
						nobaselevels nogaps fragment label ///
						prehead("\begin{tabular}{l*{4}{c}} " ///
							"\\[-1.8ex]\hline \hline \\[-1.8ex] " ///
							"& \multicolumn{1}{c}{1st Stage} " ///
							"& \multicolumn{1}{c}{RF} " ///
							"& \multicolumn{2}{c}{Fuzzy RD (IV)}" ///
							" \\ \midrule") ///
						postfoot("\hline \hline \\[-1.8ex] " ///
							"\multicolumn{5}{p{\linewidth}}{\small " ///
							"\noindent \textit{Note}: All models " ///
							"include baseline controls, " ///
							"district-threshold and year FE, and " ///
							"triangular kernel weights. Std.\ errors " ///
							"clustered at village level. " ///
							"* p$<$0.10, ** p$<$0.05, " ///
							"*** p$<$0.01.} " ///
							"\end{tabular}")

**## 5.2 - interpretation
	*** the iv estimate is the reduced-form estimate scaled by the
	*** first-stage coefficient: iv = rf / fs


**********************************************************************
**# exercise 6 - Density Test
**********************************************************************

* load running variable data
	use             "$rr/pmgsy_runningvar.dta", clear

* restrict to within 500 of threshold
	keep if         abs(v_pop) <= 500

* run density test
	cap drop        Xj Yj r0 fhat se_fhat
	dc_density      v_pop, breakpoint(0) ///
						generate(Xj Yj r0 fhat se_fhat) ///
						graphname("$answ/14-rdd-density.eps")

* histogram of running variable
	twoway          (histogram v_pop if v_pop < 0, ///
						width(10) color(navy%50)) ///
						(histogram v_pop if v_pop >= 0, ///
						width(10) color(maroon%50)), ///
						xline(0, lcolor(black) lpattern(dash)) ///
						xtitle("Population minus threshold") ///
						ytitle("Density") ///
						legend(order(1 "Below" 2 "Above") ///
							ring(0) pos(1)) ///
						graphregion(color(white))
	graph export    "$answ/14-rdd-density.png", replace

**## 6.1 - interpretation
	*** report the test statistic and p-value. a non-significant
	*** result suggests no evidence of manipulation

**## 6.2 - interpretation
	*** the running variable is census population which is
	*** administratively determined and difficult for villages
	*** to manipulate


**********************************************************************
**# exercise 7 - Placebo Outcomes
**********************************************************************

* load data (cross-section)
	use             "$rr/gjp_main_working.dta", clear
	keep if         year == 2012

* placebo outcome list
	local           placebos primary_school med_center elect ///
						tdist irr_share ln_land pc01_lit_share ///
						pc01_sc_share bpl_landed_share ///
						bpl_inc_source_sub_share bpl_inc_250plus

* run placebo tests
	local           nvars : word count `placebos'
	matrix          placebo_res = J(`nvars', 3, .)
	matrix rownames placebo_res = `placebos'
	local           row = 1

	foreach var of local placebos {
		qui rdrobust    `var' v_pop, c(0)
		matrix      placebo_res[`row', 1] = e(tau_cl)
		matrix      placebo_res[`row', 2] = e(ci_l_cl)
		matrix      placebo_res[`row', 3] = e(ci_r_cl)
		local       ++row
	}

* convert to dataset for plotting
	preserve
	clear
	svmat           placebo_res
	rename          (placebo_res1 placebo_res2 placebo_res3) ///
						(estimate ci_lo ci_hi)
	gen             id = _n
	local           placebos primary_school med_center elect ///
						tdist irr_share ln_land pc01_lit_share ///
						pc01_sc_share bpl_landed_share ///
						bpl_inc_source_sub_share bpl_inc_250plus
	local           row = 1
	foreach var of local placebos {
		label define    idlbl `row' "`var'", add
		local           ++row
	}
	label values    id idlbl

	twoway          (rcap ci_lo ci_hi id, horizontal ///
						lcolor(navy)) ///
						(scatter id estimate, ///
						mcolor(navy) msymbol(circle)), ///
						xline(0, lcolor(maroon) lpattern(dash)) ///
						xtitle("RD Estimate") ///
						ytitle("") ///
						ylabel(1/`nvars', valuelabel angle(0) ///
							labsize(vsmall)) ///
						legend(off) ///
						graphregion(color(white))
	graph export    "$answ/14-rdd-placebo.png", replace
	restore

**## 7.1 - interpretation
	*** check how many covariates show a significant discontinuity

**## 7.2 - interpretation
	*** with 11 tests at the 10% level, we expect ~1 rejection
	*** by chance alone, which is not a systematic concern


**********************************************************************
**# challenge 14 - Replicating Table 2
**********************************************************************

**## part 1 - replicate table 2

* load data
	use             "$rr/gjp_main_working.dta", clear

	est clear

* first stage
	reghdfe         receivedroad t left right $blcontrols ///
						[aw = kernel_tri_ik], ///
						a(year dist_thresh_id) ///
						vce(cluster village_id)
	eststo          fs
	su              receivedroad if e(sample) & t == 0
	estadd scalar   depvarmean = r(mean)

* reduced form - fires
	reghdfe         fires10km t left right fires2001_10km ///
						$blcontrols [aw = kernel_tri_ik], ///
						a(year dist_thresh_id) cluster(village_id)
	eststo          rf_fires
	su              fires10km if e(sample) & t == 0
	estadd scalar   depvarmean = r(mean)

* iv - fires
	ivreghdfe       fires10km (receivedroad = t) left right ///
						fires2001_10km $blcontrols ///
						[aw = kernel_tri_ik], ///
						a(year dist_thresh_id) cluster(village_id)
	eststo          iv_fires
	su              fires10km if e(sample) & t == 0
	estadd scalar   depvarmean = r(mean)

* reduced form - pm 2.5
	reghdfe         pm25 t left right pm25_bl2001 ///
						$blcontrols [aw = kernel_tri_ik], ///
						a(year dist_thresh_id) cluster(village_id)
	eststo          rf_pm
	su              pm25 if e(sample) & t == 0
	estadd scalar   depvarmean = r(mean)

* iv - pm 2.5
	ivreghdfe       pm25 (receivedroad = t) left right ///
						pm25_bl2001 $blcontrols ///
						[aw = kernel_tri_ik], ///
						a(year dist_thresh_id) cluster(village_id)
	eststo          iv_pm
	su              pm25 if e(sample) & t == 0
	estadd scalar   depvarmean = r(mean)

* export table 2 replication
	esttab          fs rf_fires iv_fires rf_pm iv_pm ///
						using "$answ/14-challenge-tab2.tex", replace ///
						b(3) se(3) ///
						keep(t receivedroad) ///
						coeflabels(t "Above threshold" ///
							receivedroad "Road built") ///
						star(* 0.10 ** 0.05 *** 0.01) ///
						mgroups("Road" "Annual fire activity" ///
							"Annual average PM 2.5", ///
							pattern(1 1 0 1 0) ///
							prefix(\multicolumn{@span}{c}{) ///
							suffix(}) span ///
							erepeat(\cmidrule(lr){@span})) ///
						mtitles("1st stage" "RF" "IV" "RF" "IV") ///
						stats(N depvarmean, ///
							labels("Observations" ///
								"Control group mean") ///
							fmt(0 2)) ///
						noobs booktabs nonum collabels(none) ///
						nobaselevels nogaps fragment label ///
						prehead("\begin{tabular}{l*{5}{c}} " ///
							"\\[-1.8ex]\hline \hline \\[-1.8ex]") ///
						postfoot("\hline \hline \\[-1.8ex] " ///
							"\multicolumn{6}{p{\linewidth}}{\small " ///
							"\noindent \textit{Note}: All models " ///
							"include baseline controls, " ///
							"district-threshold and year FE, and " ///
							"triangular kernel weights. Std.\ errors " ///
							"clustered at village level. " ///
							"* p$<$0.10, ** p$<$0.05, " ///
							"*** p$<$0.01.} " ///
							"\end{tabular}")


**## part 2 - bandwidth sensitivity

* bandwidth sensitivity for iv fires
	matrix          bw_iv = J(7, 4, .)
	local           bws 25 50 75 100 150 200 250
	local           row = 1

	foreach bw of local bws {
		cap noisily ivreghdfe fires10km (receivedroad = t) ///
						left right fires2001_10km $blcontrols ///
						if abs(v_pop) <= `bw', ///
						a(year dist_thresh_id) cluster(village_id)
		if _rc == 0 {
			matrix  bw_iv[`row', 1] = `bw'
			matrix  bw_iv[`row', 2] = _b[receivedroad]
			matrix  bw_iv[`row', 3] = _b[receivedroad] - ///
						1.96 * _se[receivedroad]
			matrix  bw_iv[`row', 4] = _b[receivedroad] + ///
						1.96 * _se[receivedroad]
		}
		local       ++row
	}

* convert to dataset and plot
	preserve
	clear
	svmat           bw_iv
	rename          (bw_iv1 bw_iv2 bw_iv3 bw_iv4) ///
						(bandwidth estimate ci_lo ci_hi)
	drop if         bandwidth == .

	twoway          (rcap ci_lo ci_hi bandwidth, lcolor(navy)) ///
						(scatter estimate bandwidth, ///
						mcolor(navy) msymbol(circle)), ///
						yline(0, lcolor(maroon) lpattern(dash)) ///
						ytitle("IV Estimate (Road Built)") ///
						xtitle("Bandwidth (population)") ///
						legend(off) ///
						graphregion(color(white))
	graph export    "$answ/14-challenge-bw.png", replace
	restore


**## part 3 - subgroup analysis

* subgroup indicators
	gen             burning_crops = (rice_hi == 1 | sugar_hi == 1)

* iv fires - high rice/sugar
	ivreghdfe       fires10km (receivedroad = t) left right ///
						fires2001_10km $blcontrols ///
						[aw = kernel_tri_ik] ///
						if burning_crops == 1, ///
						a(year dist_thresh_id) cluster(village_id)
	eststo          iv_fires_hi
	su              fires10km if e(sample) & t == 0
	estadd scalar   depvarmean = r(mean)

* iv pm - high rice/sugar
	ivreghdfe       pm25 (receivedroad = t) left right ///
						pm25_bl2001 $blcontrols ///
						[aw = kernel_tri_ik] ///
						if burning_crops == 1, ///
						a(year dist_thresh_id) cluster(village_id)
	eststo          iv_pm_hi
	su              pm25 if e(sample) & t == 0
	estadd scalar   depvarmean = r(mean)

* iv fires - low rice/sugar
	ivreghdfe       fires10km (receivedroad = t) left right ///
						fires2001_10km $blcontrols ///
						[aw = kernel_tri_ik] ///
						if burning_crops == 0, ///
						a(year dist_thresh_id) cluster(village_id)
	eststo          iv_fires_lo
	su              fires10km if e(sample) & t == 0
	estadd scalar   depvarmean = r(mean)

* iv pm - low rice/sugar
	ivreghdfe       pm25 (receivedroad = t) left right ///
						pm25_bl2001 $blcontrols ///
						[aw = kernel_tri_ik] ///
						if burning_crops == 0, ///
						a(year dist_thresh_id) cluster(village_id)
	eststo          iv_pm_lo
	su              pm25 if e(sample) & t == 0
	estadd scalar   depvarmean = r(mean)

* subgroup table
	esttab          iv_fires_hi iv_pm_hi iv_fires_lo iv_pm_lo ///
						using "$answ/14-challenge-subgroup.tex", ///
						replace ///
						b(3) se(3) ///
						keep(receivedroad) ///
						coeflabels(receivedroad "Road built") ///
						star(* 0.10 ** 0.05 *** 0.01) ///
						mgroups("High rice/sugar" ///
							"Low rice/sugar", ///
							pattern(1 0 1 0) ///
							prefix(\multicolumn{@span}{c}{) ///
							suffix(}) span ///
							erepeat(\cmidrule(lr){@span})) ///
						mtitles("Fires" "PM 2.5" ///
							"Fires" "PM 2.5") ///
						stats(N depvarmean, ///
							labels("Observations" ///
								"Control group mean") ///
							fmt(0 2)) ///
						noobs booktabs nonum collabels(none) ///
						nobaselevels nogaps fragment label ///
						prehead("\begin{tabular}{l*{4}{c}} " ///
							"\\[-1.8ex]\hline \hline \\[-1.8ex]") ///
						postfoot("\hline \hline \\[-1.8ex] " ///
							"\multicolumn{5}{p{\linewidth}}{\small " ///
							"\noindent \textit{Note}: All models " ///
							"include baseline controls, " ///
							"district-threshold and year FE. " ///
							"Std.\ errors clustered at village " ///
							"level. " ///
							"* p$<$0.10, ** p$<$0.05, " ///
							"*** p$<$0.01.} " ///
							"\end{tabular}")

**## part 4 - interpretation
	*** the fire effect concentrates in districts with high rice
	*** or sugarcane production, consistent with the mechanism that
	*** roads make it cheaper to transport crops, favoring
	*** mechanized harvesting which leaves flammable stubble.
	*** subgroup analysis avoids the bad-controls problem of
	*** interacting an endogenous variable with treatment


**********************************************************************
**# 8 - end matter
**********************************************************************

* close log
	cap             log close

/* end */
