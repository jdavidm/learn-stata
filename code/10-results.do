* course: AAE 497A/597A
* assignment: 10
* created on: mar 26
* created by: jdm
* edited on: 13 mar 26
* edited by: jdm
* Stata v.19.5
	
* open log
	cap log 		close
	log using		"$logout/10-results", append


********************************************************************************
**# 1 - latex formatting and math
********************************************************************************

* no Stata code needed for exercise 1 (LaTeX-only exercise)
	di as result	"exercise 1: LaTeX formatting and math — done in Overleaf"
	di as text		"part 4 standard error formula should look like:"
	di as text		"SE(\hat{\beta}) = \sqrt{\frac{1}{n} \sum_{i=1}^{n} (X_i - \bar{X})^2}"


********************************************************************************
**# 2 - inserting a stata figure
********************************************************************************

* load tenure data and keep rice
	use				"$data/tenuredata.dta", clear
	keep if			rice == 1

* scatter plot of yield vs fertilizer
	twoway			(scatter yield q_f_ha, ///
							msymbol(oh) msize(vsmall)) ///
					(lfit yield q_f_ha), ///
						title("Rice yield vs fertilizer") ///
						xtitle("Fertilizer (kg/ha)") ///
						ytitle("Yield (kg/ha)") ///
						legend(order(1 "Parcels" 2 "Linear fit")) ///
						graphregion(color(white)) ///
						name(g_scatter_rice, replace)

	graph export	"$answ/10-latex-figure-1.png", replace
    *** exported scatter for inclusion in LaTeX document

	
********************************************************************************
**# 3 - summary statistics table
********************************************************************************

	estimates clear

* summary statistics
	estpost			summarize yield q_f_ha lt_f_ha area irrig tenure, ///
						detail

* display
	esttab,			cells("count mean sd min max") ///
						noobs nonumber nomtitle ///
						title("Summary Statistics — Rice Parcels") ///
						label


********************************************************************************
**# 4 - basic esttab table
********************************************************************************

**## 4.1 run and store
	reg				yield q_f_ha lt_f_ha i.irrig i.tenure, ///
						vce(cluster panelid)
	eststo 			r1


* print table
   esttab      r1 using "$answ/10-esttab-basic-1.tex", replace ///
                   se star(* 0.10 ** 0.05 *** 0.01) ///
                   keep(q_f_ha lt_f_ha) ///
                   label booktabs ///
                   stats(N r2, labels("Observations" "R-squared") fmt(0 3))


**## 4.2 - multiple regressions
	reg				yield q_f_ha lt_f_ha i.irrig i.tenure, ///
						vce(cluster panelid)
	estimates		store r2

	reg				yield q_f_ha lt_f_ha i.irrig i.tenure ///
						i.site i.year, vce(cluster panelid)
	estimates		store r3


* print table
   esttab      r1 r2 r3 using "$answ/10-esttab-basic-2.tex", replace ///
                   se star(* 0.10 ** 0.05 *** 0.01) ///
                   keep(q_f_ha lt_f_ha 1.irrig 1.tenure) ///
                   order(q_f_ha lt_f_ha 1.irrig 1.tenure) ///
                   label booktabs ///
                   indicate("Site FE = *.site" "Year FE = *.year") ///
                   stats(N r2, labels("Observations" "R-squared") fmt(0 3)) ///
                   note("Clustered SEs at household level." ///
                        "\sym{*} \(p<0.10\), \sym{**} \(p<0.05\), " ///
                        "\sym{***} \(p<0.01\)")
				   
				   
********************************************************************************
**# 5 - multi-column table with notes
********************************************************************************

* reg 1
	reg				yield q_f_ha lt_f_ha, vce(cluster panelid)
	estimates		store r3

* reg 2
	reg				yield q_f_ha lt_f_ha i.irrig i.tenure, vce(cluster panelid)
	estimates		store r3

* reg 3
	reg				yield q_f_ha lt_f_ha i.irrig i.tenure i.site i.year, vce(cluster panelid)
	estimates		store r3

* output to latex
   esttab      r1 r2 r3 using "$answ/10-esttab-multi.tex", replace ///
                   b(3) se(3) ///
                   keep(q_f_ha lt_f_ha 1.irrig 1.tenure) ///
                   order(q_f_ha lt_f_ha 1.irrig 1.tenure) ///
                   star(* 0.10 ** 0.05 *** 0.01) ///
                   indicate("Site FE = *.site" "Year FE = *.year") ///
                   stats(N r2, labels("Observations" "R-squared") fmt(0 3)) ///
                   noobs booktabs nonum nomtitle collabels(none) ///
                   nobaselevels nogaps fragment label ///
                   prehead("\begin{tabular}{l*{3}{c}} \\[-1.8ex]\hline \hline \\[-1.8ex] " ///
                   "& \multicolumn{1}{c}{Baseline} & \multicolumn{2}{c}{With Controls} \\ " ///
                   "\cline{2-2} \cline{3-4} \\[-1.8ex] " ///
                   "& \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} " ///
                   "& \multicolumn{1}{c}{(3)} \\ ") ///
                   postfoot("\hline \hline \\[-1.8ex] " ///
                   "\multicolumn{4}{p{0.8\linewidth}}{\small " ///
                   "\noindent \textit{Note}: Dependent variable " ///
                   "is rice yield in kg/ha. All models use " ///
                   "OLS with standard errors clustered at the " ///
                   "household level (in parentheses). " ///
                   "* p$<$0.10, ** p$<$0.05, *** p$<$0.01.} " ///
                   "\end{tabular}")
						
						
********************************************************************************
**# 6 - basic coefplot
********************************************************************************

* run regression
	reg				yield q_f_ha lt_f_ha i.irrig i.tenure, ///
						vce(cluster panelid)

* basic coefficient plot
	coefplot,		drop(_cons) xline(0) ///
						title("Rice yield regression coefficients") ///
						xtitle("Coefficient estimate") ///
						graphregion(color(white)) ///
						name(g_coefplot_basic, replace)

	graph export	"$answ/10-coefplot-basic.png", replace
    *** basic coefplot showing all regressors except the constant
fdfs

********************************************************************************
**# 7 - multi-model coefplot
********************************************************************************

* model 1: baseline
	reg				yield q_f_ha lt_f_ha, vce(cluster panelid)
	estimates		store m1

* model 2: add tenure and irrigation
	reg				yield q_f_ha lt_f_ha i.irrig i.tenure, ///
						vce(cluster panelid)
	estimates		store m2

* model 3: add site and year FE
	reg				yield q_f_ha lt_f_ha i.irrig i.tenure ///
						i.site i.year, vce(cluster panelid)
	estimates		store m3

* multi-model coefplot: fertilizer across specs
	coefplot		m1 m2 m3, keep(q_f_ha) xline(0) ///
						title("Fertilizer coefficient across specifications") ///
						xtitle("Effect on yield (kg/ha)") ///
						legend(order(2 "Baseline" 4 "+ Tenure/Irrig" ///
									 6 "+ FE")) ///
						graphregion(color(white)) ///
						name(g_coefplot_multi, replace)

	graph export	"$answ/10-coefplot-multi.png", replace

* print interpretation
	di as result	"exercise 7 solution"
	di as text		"check whether the fertilizer coefficient is stable across specifications."
	di as text		"if the point estimate and CI barely move, the result is robust to control choice."
    *** the stability of q_f_ha across specs is the key answer


********************************************************************************
**# 8 - specification chart
********************************************************************************

* reload data
	use				"$data/tenuredata.dta", clear
	keep if			rice == 1
	gen				ln_yield = ln(yield)

* set up postfile for results
	tempfile		results
	postfile		handle spec beta se ci_lo ci_up ///
						depvar controls cluster_hh ///
						using `results'

* loop over specifications
	local			spec = 0

	foreach dv in yield ln_yield {
		foreach ctrl in 0 1 2 {
			foreach cl in 0 1 {

				local		spec = `spec' + 1

				* dep var indicator
				local		dv_ind = cond("`dv'" == "yield", 1, 2)

				* build RHS
				local		rhs "q_f_ha lt_f_ha"
				if `ctrl' >= 1	local rhs "`rhs' i.irrig i.tenure"
				if `ctrl' == 2	local rhs "`rhs' i.site i.year"
				local		ctrl_ind = `ctrl' + 1

				* clustering
				local		vce_opt ""
				local		cl_ind = `cl' + 1
				if `cl' == 1	local vce_opt ", vce(cluster panelid)"

				* run regression
				cap reg		`dv' `rhs' `vce_opt'
				if _rc == 0 {
					local	b = _b[q_f_ha]
					local	s = _se[q_f_ha]
					local	lo = `b' - 1.96*`s'
					local	hi = `b' + 1.96*`s'
					post	handle (`spec') (`b') (`s') (`lo') (`hi') ///
								(`dv_ind') (`ctrl_ind') (`cl_ind')
				}
			}
		}
	}

	postclose		handle

* load results and flag significance
	use				`results', clear
	gen				b_sig = beta if (ci_lo > 0 | ci_up < 0)
	gen				b_ns  = beta if b_sig == .

* sort and create observation index
	sort			beta
	gen				obs = _n

* stack specification indicators
	gen				k1 = depvar
	gen				k2 = controls + 3
	gen				k3 = cluster_hh + 7

* compute axis ranges
	qui sum			ci_up
	global			bmax = r(max)
	qui sum			ci_lo
	global			bmin = r(min)
	global			brange = $bmax - $bmin
	global			from_y = $bmin - 2.5*$brange
	global			gheight = 12

* plot the specification chart
	twoway			(scatter k1 k2 k3 obs, ///
						xsize(10) ysize(6) xtitle("") ytitle("") ///
						msize(small small small) ///
						mcolor(gs10 gs10 gs10) ///
						ylabel( ///
							1 "Yield (kg)" 2 "Ln(yield)" ///
							3 "{bf:Dep. Var.}" ///
							4 "Baseline" 5 "+ Tenure/Irrig" 6 "+ Full FE" ///
							7 "{bf:Controls}" ///
							8 "Default" 9 "Clustered" ///
							10 "{bf:Std. Errors}" 12 " ", ///
							angle(0) labsize(vsmall) tstyle(notick)) ///
						plotregion(margin(4 4 4 7))) ///
					|| (scatter b_sig obs if beta > 0, yaxis(2) ///
						mcolor(edkblue%75) msymbol(+) ///
						ylab(, axis(2) labsize(vsmall) angle(0)) ///
						yscale(range($from_y $bmax) axis(2))) ///
					|| (scatter b_sig obs if beta < 0, yaxis(2) ///
						mcolor(maroon%75) msymbol(+)) ///
					|| (scatter b_ns obs, yaxis(2) ///
						mcolor(black%75) msymbol(Th)) ///
					|| (rbar ci_lo ci_up obs if b_sig == ., ///
						barwidth(.3) color(black%50) yaxis(2)) ///
					|| (rbar ci_lo ci_up obs if b_sig != . & beta > 0, ///
						barwidth(.3) color(edkblue%50) yaxis(2)) ///
					|| (rbar ci_lo ci_up obs if b_sig != . & beta < 0, ///
						barwidth(.3) color(maroon%50) yaxis(2) ///
						yline(0, lcolor(maroon) axis(2) lstyle(solid))), ///
					legend(order(5 "Not sig." 6 "Sig. (positive)" ///
								 7 "Sig. (negative)") ///
						cols(3) size(small) pos(6)) ///
					title("Specification chart: fertilizer effect on rice yield") ///
					name(g_spec_chart, replace)

	graph export	"$answ/10-spec-chart-rice.png", replace
    *** specification chart showing robustness of fertilizer coefficient


********************************************************************************
**# 10 - challenge
********************************************************************************

**## 10.1 - setup
	use				"$data/tenuredata.dta", clear
	keep if			rice == 1

**## 10.2 - summary statistics
	estpost			summarize yield q_f_ha lt_f_ha area irrig tenure ///
						educhoh agehoh, detail

	esttab			using "$answ/10-challenge-sumstats.tex", replace ///
						cells("count(fmt(0)) mean(fmt(2)) sd(fmt(2)) min(fmt(1)) max(fmt(1))") ///
						noobs nonumber nomtitle ///
						title("Summary Statistics — Rice Parcels") ///
						booktabs label
    *** exported challenge summary stats table

**## 10.3 - regression table

* run and store four specifications
	reg				yield q_f_ha lt_f_ha, vce(cluster panelid)
	estimates		store c1

	reg				yield q_f_ha lt_f_ha i.irrig i.tenure, ///
						vce(cluster panelid)
	estimates		store c2

	reg				yield q_f_ha lt_f_ha i.irrig i.tenure ///
						educhoh agehoh, vce(cluster panelid)
	estimates		store c3

	reg				yield q_f_ha lt_f_ha i.irrig i.tenure ///
						educhoh agehoh i.site i.year, ///
						vce(cluster panelid)
	estimates		store c4

* export four-column table
	esttab			c1 c2 c3 c4 using "$answ/10-challenge-regs.tex", replace ///
						se star(* 0.10 ** 0.05 *** 0.01) ///
						keep(q_f_ha lt_f_ha 1.irrig 1.tenure educhoh agehoh) ///
						order(q_f_ha lt_f_ha 1.irrig 1.tenure educhoh agehoh) ///
						label booktabs ///
						mtitles("(1)" "(2)" "(3)" "(4)") ///
						indicate("Site FE = *.site" "Year FE = *.year") ///
						stats(N r2, labels("Observations" "R-squared") ///
							fmt(0 3)) ///
						note("Clustered SEs at household level." ///
							 "\sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)")
    *** exported challenge regression table

**## 10.4 - coefficient plot

* multi-model coefplot
	coefplot		c1 c2 c3 c4, keep(q_f_ha) xline(0) ///
						title("Fertilizer coefficient across specifications") ///
						xtitle("Effect on yield (kg/ha)") ///
						legend(order(2 "Baseline" 4 "+ Tenure/Irrig" ///
									 6 "+ HH chars" 8 "+ Full FE")) ///
						graphregion(color(white)) ///
						name(g_challenge_coef, replace)

	graph export	"$answ/10-challenge-coefplot.png", replace
    *** exported challenge coefplot


********************************************************************************
**# 10 - end matter, clean up
********************************************************************************

* close log
	log				close

/* end */
