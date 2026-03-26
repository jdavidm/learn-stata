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


* scatter plot of yield vs fertilizer
	twoway			(scatter yield q_f_ha, ///
							msymbol(oh) msize(vsmall)) ///
					(lfit yield q_f_ha), ///
						title("Rice yield vs fertilizer") ///
						xtitle("Fertilizer (kg/ha)") ///
						ytitle("Yield (kg/ha)") ///
						legend(order(1 "Parcels" 2 "Linear fit")) ///
						graphregion(color(white))

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
                        rename(q_f_ha = "Fertilizer (kg/ha)" ///
                               lt_f_ha = "Labor (days/ha)" ///
                               1.irrig = "Irrigated (=1)" ///
							   1.tenure = "Own Plot (=1)") ///
						title("Rice yield regression coefficients") ///
						xtitle("Coefficients") ///
						graphregion(color(white))

	graph export	"$answ/10-coefplot-basic.png", replace
    *** basic coefplot showing all regressors except the constant


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
   coefplot			(m1, label("Baseline") ) ///
					(m2, label("+ Tenure/Irrig") ) ///
					(m3, label("+ Village/Year FE") ), ///
						keep(q_f_ha lt_f_ha) xline(0) ///
						title("Input impact on yield") ///
						xtitle("Coefficient size")

	graph export	"$answ/10-coefplot-multi.png", replace


********************************************************************************
**# 8 - specification chart
********************************************************************************

* reload data
	use				"$data/tenuredata.dta", clear


* set up postfile for results
	tempfile		results
	postfile		handle spec beta se ci_lo ci_up ///
						controls fe cluster_hh ///
						using `results'

* loop over specifications
	local			spec = 0

	foreach ctrl in 0 1 2 3 {
		foreach f in 0 1 2 {
			foreach cl in 0 1 {

				local		spec = `spec' + 1

				* build RHS controls
				local		rhs "lnf lnl lnp"
				if `ctrl' >= 1	local rhs "`rhs' i.irrig i.tenure"
				if `ctrl' >= 2	local rhs "`rhs' tractor carabao"
				if `ctrl' == 3	local rhs "`rhs' hhsize educhoh agehoh"
				local		ctrl_ind = `ctrl' + 1

				* build RHS fixed effects
				local		fe_opt ""
				if `f' >= 1		local fe_opt "i.site"
				if `f' == 2		local fe_opt "`fe_opt' i.year"
				if "`fe_opt'" != "" local rhs "`rhs' `fe_opt'"
				local		fe_ind = `f' + 1

				* clustering
				local		vce_opt ""
				local		cl_ind = `cl' + 1
				if `cl' == 1	local vce_opt ", vce(cluster panelid)"

				* run regression
				cap reg		lny `rhs' `vce_opt'
				if _rc == 0 {
					local	b = _b[lnf]
					local	s = _se[lnf]
					local	lo = `b' - 1.96*`s'
					local	hi = `b' + 1.96*`s'
					post	handle (`spec') (`b') (`s') (`lo') (`hi') ///
								(`ctrl_ind') (`fe_ind') (`cl_ind')
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
	gen				k1 = controls
	gen				k2 = fe + 5
	gen				k3 = cluster_hh + 9

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
							1 "Baseline (inputs)" 2 "+ Plot chars" ///
							3 "+ Assets" 4 "+ HH chars" ///
							5 "{bf:Controls}" ///
							6 "None" 7 "Site" 8 "Site & Year" ///
							9 "{bf:Fixed Effects}" ///
							10 "Default" 11 "Clustered" ///
							12 "{bf:Std. Errors}" 22 " ", ///
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
						cols(3) size(small) pos(6)) 

	graph export	"$answ/10-spec-chart-rice.png", replace
    *** specification chart showing robustness of fertilizer coefficient


********************************************************************************
**# 10 - challenge
********************************************************************************

* setup
	use				"$data/tenuredata.dta", clear


	estimates clear
	
**## 10.1 - summary statistics
	estpost			sum yield q_f_ha lt_f_ha area irrig tenure ///
						educhoh agehoh

	esttab			using "$answ/10-challenge-sumstats.tex", replace ///
						cells("count(fmt(0)) mean(fmt(2)) sd(fmt(2)) min(fmt(1)) max(fmt(1))") ///
						booktabs label nonum nomtitle nobaselevels ///
						nogaps noobs fragment ///
						prehead("\begin{tabular}{l*{5}{c}}" ///
							"\toprule") ///
						posthead("\midrule") ///
						postfoot("\bottomrule" ///
							"\multicolumn{6}{p{0.8\linewidth}}{\footnotesize " ///
							"\textit{Note}: Data restricted to rice parcels.} \\ " ///
							"\end{tabular}")
    *** exported challenge summary stats table

**## 10.2 - coefficient plot

* run and store four specifications for the coefplot
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

* multi-model coefplot
	coefplot		c1 c2 c3 c4, keep(q_f_ha) xline(0) ///
						xtitle("Effect on yield (kg/ha)") ///
						legend(order(2 "Baseline" 4 "+ Tenure/Irrig" ///
									 6 "+ HH chars" 8 "+ Full FE")) ///
						graphregion(color(white)) 

	graph export	"$answ/10-challenge-coefplot.png", replace
    *** exported challenge coefplot

**## 10.3 - import into LaTeX



********************************************************************************
**# 10 - end matter, clean up
********************************************************************************

* close log
	log				close

/* end */
