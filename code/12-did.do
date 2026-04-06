* course: 597a
* assignment: 12
* created on: 31 mar 26
* created by: jdm
* edited on: 5 apr 26
* edited by: jdm
* stata v.18.0


**********************************************************************
**# 0 - setup
**********************************************************************

* open log
	cap             log close
	log             using "$logout/12-did.log", append

**********************************************************************
**# exercise 1 - Continuous Treatment DiD
**********************************************************************

* load data
	use             "$data/panel_gis.dta", clear
    
* set panel   
	xtset           district_id year

* continuous treatment did
	eststo          did1: xtreg evi_med c.seed i.year, fe ///
						vce(cluster district_id)

* did using didregress
	eststo          did2: didregress (evi_med) (seed, continuous), group(district_id) ///
						time(year) vce(cluster district_id)
						
   esttab      did1 did2 using "$answ/12-did.tex", replace ///
                    b(4) se(4) ///
                    rename(seed "STRV Seed") ///
                    keep("STRV Seed") ///
                    star(* 0.10 ** 0.05 *** 0.01) ///
                    stats(N r2, labels("Observations" "R-squared") fmt(0 3)) ///
                    noobs booktabs nonum nomtitle eqlabels(none) collabels(none) ///
                    nobaselevels nogaps fragment label ///
                    prehead("\begin{tabular}{l*{2}{c}} " ///
                      "\\[-1.8ex]\hline \hline \\[-1.8ex] " ///
                      "& \multicolumn{1}{c}{xtreg} & " ///
                      "\multicolumn{1}{c}{didreg} \\ \midrule") ///
                    postfoot("\hline \hline \\[-1.8ex] " ///
                      "\multicolumn{3}{p{\linewidth}}{\small " ///
                      "\noindent \textit{Note}: Dependent variable " ///
                      "is median EVI. All models use " ///
                      "standard errors clustered at the " ///
                      "household level (in parentheses). " ///
                      "* p$<$0.10, ** p$<$0.05, *** p$<$0.01.} " ///
                      "\end{tabular}")
					  
					  
**********************************************************************
**# exercise 2 - Parallel Trends
**********************************************************************

* find maximum seed adoption per district
	bysort          district_id: egen max_seed = max(seed)

* get median of maximum seed
	sum             max_seed, detail
	local           med = r(p50)

* define early/high adoption districts vs never/low
	gen             high_adopt = (max_seed > `med') & !missing(max_seed)

* collapse to mean by group and year
	preserve
	collapse        (mean) evi_med, by(high_adopt year)

* map parallel trends
	twoway          (connected evi_med year if high_adopt == 1, ///
						lcolor(maroon)) ///
					(connected evi_med year if high_adopt == 0, ///
						lcolor(navy)), xline(2011) ///
						legend(order(1 "High Adopters" ///
						2 "Low/Never Adopters")) xtitle("Year") ///
						ytitle("Mean EVI") ///
						title("Parallel Trends Check")
	graph export    "$answ/12-parallel_trends.png", replace
	restore


**********************************************************************
**# exercise 3 - Continuous Interacted DiD
**********************************************************************

**## 3.1 - table

* interacted model
	eststo          did3: xtreg evi_med c.seed##c.bin_max_60_611 i.year, ///
						fe vce(cluster district_id)

* build esttab table

   esttab      did1 did2 did3 using "$answ/12-interact-did.tex", replace ///
                    b(4) se(4) ///
                    rename(seed "STRV Seed") ///
                    keep("STRV Seed") ///
                    star(* 0.10 ** 0.05 *** 0.01) ///
                    stats(N r2, labels("Observations" "R-squared") fmt(0 3)) ///
                    noobs booktabs nonum nomtitle eqlabels(none) collabels(none) ///
                    nobaselevels nogaps fragment label ///
                    prehead("\begin{tabular}{l*{3}{c}} " ///
                      "\\[-1.8ex]\hline \hline \\[-1.8ex] " ///
                      "& \multicolumn{1}{c}{xtreg} & " ///
                      "\multicolumn{1}{c}{didreg} & " ///
					  "\multicolumn{1}{c}{inter} \\ \midrule") ///
                    postfoot("\hline \hline \\[-1.8ex] " ///
                      "\multicolumn{4}{p{\linewidth}}{\small " ///
                      "\noindent \textit{Note}: Dependent variable " ///
                      "is median EVI. All models use " ///
                      "standard errors clustered at the " ///
                      "household level (in parentheses). " ///
                      "* p$<$0.10, ** p$<$0.05, *** p$<$0.01.} " ///
                      "\end{tabular}")

**## 3.2 - interpretation					  
					  
**********************************************************************
**# exercise 4 - Event Study Regression
**********************************************************************

**## 4.1 - table

* generate cohort variable
	gen			seed_year = year if seed > 0
    bysort		district_id: ///
		egen		first_seed = min(seed_year)
    drop		seed_year
 
* code the relative time categorical variable.
	gen 		ry = year - first_seed
	replace		ry = 10 if ry > 10 & ry != .

* take the control cohort to be districts that never got strvs
	gen 		never_seed = (first_seed == .)
	gen			last_seed = (first_seed == 2019)
	
* generate relative time indicators
	forvalues 	k = 16(-1)2 {
		gen 		g_`k' = ry == -`k'
		label 		var g_`k' "-`k'"
	}
	forvalues k = 0/10 {
		gen 		g`k' = ry == `k'
		label 		var g`k' "`k'"
	}
   **## 4.1 - TWFE event study

* event study of evi_med using standard TWFE
	eststo twfe: xtreg  evi_med g_* g0-g10 i.year, ///
							fe vce(cluster district_id)

**## 4.2 - robust event study

* event study of evi_med using eventstudyinteract
	eventstudyinteract 	evi_med g_* g0-g10, ///
							cohort(first_seed) control_cohort(last_seed) ///
							covariates(fld_cuml) absorb(i.district_id i.year) ///
							vce(cluster district_id)

* post results for esttab
	matrix          b_iw = e(b_iw)
	matrix          V_iw = e(V_iw)
	erepost         b = b_iw V = V_iw
	eststo iw

* export results to latex
   esttab       twfe iw using "$answ/12-event-reg.tex", replace ///
                    b(4) se(4) ///
                    drop(*.year _cons) ///
                    star(* 0.10 ** 0.05 *** 0.01) ///
                    mtitles("TWFE" "Interaction-Weighted") ///
                    noobs booktabs nonum ///
                    eqlabels(none) collabels(none) ///
                    nobaselevels nogaps fragment label ///
                    prehead("\begin{tabular}{l*{2}{c}} " ///
                        "\\[-1.8ex]\hline \hline \\[-1.8ex] " ///
                        "& \multicolumn{2}{c}{Event Study} \\ \midrule") ///
                    postfoot("\hline \hline \\[-1.8ex] " ///
                        "\multicolumn{3}{p{\linewidth}}{\small " ///
                        "\noindent \textit{Note}: Dependent variable " ///
                        "is median EVI. Standard errors clustered at the " ///
                        "district level (in parentheses). " ///
                        "* p$<$0.10, ** p$<$0.05, *** p$<$0.01.} " ///
                        "\end{tabular}")	

**## 4.3 - Compare Models
					   
**********************************************************************
**# exercise 5 - Event Plot with coefplot
**********************************************************************

**## 5.1

 
* event study of evi_med	
	eventstudyinteract 	evi_med g_* g0-g10, ///
							cohort(first_seed) control_cohort(last_seed) ///
							covariates(fld_cuml) absorb(i.district_id i.year) ///
							vce(cluster district_id)

* set up matrix of results
	matrix 		C = e(b_iw)
	mata 		st_matrix("A",sqrt(diagonal(st_matrix("e(V_iw)"))))
	matrix 		C = C \ A'
	matrix 		list C							
							
* graph for paper
	coefplot 	matrix(C[1]), se(C[2]) graphregion(fcolor(white))  ///
						xtitle("Event years", size(medlarge)) ///
						vertical omitted msymbol(s) ///
						mc(black) mfcolor(white) yline(0, lc(black) lw(vthin)) ///
						recast(connected) lw(thick) lc(black) ///
						ciopts(recast(rline) lw(thin) lc(black) lp(dash)) ///
						xline(16, lc(red) lw(vthin) lp(solid) ) ///
						ylabel(,angle(0) nogrid) keep(g_* g*) ///
						rename(g_* ="-" g* = "") ///
						ytitle("Median EVI") xlabel(02 "-15" 07 "-10" 12 "-5" ///
						16 "0" 21 "5" 25 "10" )
	
* graph save
	graph export    "$answ/12-event-plot.png", replace

**********************************************************************
**# exercise 6 - Treatment Adoption Heatmap
**********************************************************************

* create post-adoption indicator
	gen             post_adopt = (year >= first_seed) & (first_seed != .)

* treatment adoption heatmap
	heatplot        post_adopt i.district_id i.year, ///
	                    colors(white dkgreen) ///
	                    ylabel(, labsize(tiny) angle(0)) ///
	                    xlabel(, labsize(small) angle(45)) ///
	                    ytitle("District") xtitle("Year") ///
	                    legend(order(1 "No Seed" 2 "Seed Adopted")) ///
	                    graphregion(color(white))
	graph export    "$answ/12-heatmap.png", replace

	
**********************************************************************
**# exercise 7 - Using the eventdd Package
**********************************************************************

**## 7.1

* eventdd automates event study estimation and plotting
 
   eventdd 			evi_med c.bin_max_60_611 i.year, timevar(ry) ///
                           method(fe, cluster(district_id)) ///
                           graph_op(ytitle("Effect on EVI (Yield Index)"))
	graph export    "$answ/12-eventdd.png", replace

	fdsf
**********************************************************************
**# exercise 8 - Ridgeline Plot
**********************************************************************

**## 8.1

* ridgeline plot of yield distributions by event time
   joyplot     evi_med if inrange(ry, -3, 5) ///
                   & first_seed != ., ///
                   by(ry) droplow ///
                   palette(CET C1) ///
                   lcolor(white) lwidth(0.2) ///
                   ytitle("Relative Time") ///
                   xtitle("EVI (Yield Index)") ///
                   title("Yield Distribution by Event Time")
				   
				   
				   fdsfs
	graph export    "$answ/12-joyplot.png", replace

**********************************************************************
**# 9 - end matter
**********************************************************************

* close log
	cap             log close

/* end */
