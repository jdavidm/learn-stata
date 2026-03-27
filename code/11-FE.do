* course: AAE 497A/597A
* assignment: 11
* created on: mar 26
* created by: jdm
* edited on: 26 mar 26
* edited by: jdm
* Stata v.19.5
	
* open log
	cap log 		close
	log using		"$logout/11-FE", append


********************************************************************************
**# 1 - first differencing
********************************************************************************

* load tenure data and keep rice
	use				"$data/mm-1.dta", clear

* run pooled OLS regression
	reg				yield totfertcostha, vce(cluster qnno)
	eststo			ols

* sort by panel id and time
	sort			qnno tindex

* create first-differenced variables
	by qnno:		gen d_yield = yield - yield[_n-1]
	by qnno:		gen d_fert = totfertcostha - totfertcostha[_n-1]

* regress the differenced variables
	reg				d_yield d_fert, vce(cluster qnno)
	eststo			fd

**## 1.2 - export table

* print table with OLS and FD columns
   esttab      ols fd using "$answ/11-fd.tex", replace ///
                    b(3) se(3) ///
                    rename(totfertcostha "Fertilizer Cost" d_fert "Fertilizer Cost") ///
                    keep("Fertilizer Cost") ///
                    star(* 0.10 ** 0.05 *** 0.01) ///
                    stats(N r2, labels("Observations" "R-squared") fmt(0 3)) ///
                    noobs booktabs nonum nomtitle collabels(none) ///
                    nobaselevels nogaps fragment label ///
                    prehead("\begin{tabular}{l*{2}{c}} " ///
                      "\\[-1.8ex]\hline \hline \\[-1.8ex] " ///
                      "& \multicolumn{1}{c}{OLS} & " ///
                      "\multicolumn{1}{c}{FD} \\ \midrule") ///
                    postfoot("\hline \hline \\[-1.8ex] " ///
                      "\multicolumn{3}{p{\linewidth}}{\small " ///
                      "\noindent \textit{Note}: Dependent variable " ///
                      "is chickpea yield in kg/ha. All models use " ///
                      "standard errors clustered at the " ///
                      "household level (in parentheses). " ///
                      "* p$<$0.10, ** p$<$0.05, *** p$<$0.01.} " ///
                      "\end{tabular}")

**## 1.2 - interpretation


********************************************************************************
**# 2 - demeaning the data (within-transformation)
********************************************************************************

* calculate household-specific means
	bysort qnno:	egen mean_yield = mean(yield)
	bysort qnno:	egen mean_fert  = mean(totfertcostha)

* demean the variables
	gen				dm_yield = yield - mean_yield
	gen				dm_fert  = totfertcostha - mean_fert

* run the regression on demeaned data
	reg				dm_yield dm_fert, vce(cluster qnno)
	eststo			demean

**## 2.1 - export table with three columns

   esttab      ols fd demean using "$answ/11-demean.tex", replace ///
                    b(3) se(3) ///
                    rename(totfertcostha "Fertilizer Cost" d_fert "Fertilizer Cost" ///
                           dm_fert "Fertilizer Cost") ///
                    keep("Fertilizer Cost") ///
                    star(* 0.10 ** 0.05 *** 0.01) ///
                    stats(N r2, labels("Observations" "R-squared") fmt(0 3)) ///
                    noobs booktabs nonum nomtitle collabels(none) ///
                    nobaselevels nogaps fragment label ///
                    prehead("\begin{tabular}{l*{3}{c}} " ///
                      "\\[-1.8ex]\hline \hline \\[-1.8ex] " ///
                      "& \multicolumn{1}{c}{OLS} & " ///
                      "\multicolumn{1}{c}{FD} & " ///
                      "\multicolumn{1}{c}{Demean} \\ \midrule") ///
                    postfoot("\hline \hline \\[-1.8ex] " ///
                      "\multicolumn{4}{p{\linewidth}}{\small " ///
                      "\noindent \textit{Note}: Dependent variable " ///
                      "is chickpea yield in kg/ha. All models use " ///
                      "standard errors clustered at the " ///
                      "household level (in parentheses). " ///
                      "* p$<$0.10, ** p$<$0.05, *** p$<$0.01.} " ///
                      "\end{tabular}")

**## 2.2 - interpretation


********************************************************************************
**# 3 - least squares dummy variables (LSDV)
********************************************************************************

* include household fixed effects via dummy variables using i.
	reg				yield totfertcostha i.qnno, vce(cluster qnno)
	eststo			lsdv

**## 3.1 - export table with four columns

   esttab      ols fd demean lsdv using "$answ/11-lsdv.tex", replace ///
                    b(3) se(3) ///
                    rename(totfertcostha "Fertilizer Cost" d_fert "Fertilizer Cost" ///
                           dm_fert "Fertilizer Cost") ///
                    keep("Fertilizer Cost") ///
                    star(* 0.10 ** 0.05 *** 0.01) ///
                    stats(N r2, labels("Observations" "R-squared") fmt(0 3)) ///
                    noobs booktabs nonum nomtitle collabels(none) ///
                    nobaselevels nogaps fragment label ///
                    prehead("\begin{tabular}{l*{4}{c}} " ///
                      "\\[-1.8ex]\hline \hline \\[-1.8ex] " ///
                      "& \multicolumn{1}{c}{OLS} & " ///
                      "\multicolumn{1}{c}{FD} & " ///
                      "\multicolumn{1}{c}{Demean} & " ///
                      "\multicolumn{1}{c}{LSDV} \\ \midrule") ///
                    postfoot("\hline \hline \\[-1.8ex] " ///
                      "\multicolumn{5}{p{\linewidth}}{\small " ///
                      "\noindent \textit{Note}: Dependent variable " ///
                      "is chickpea yield in kg/ha. All models use " ///
                      "standard errors clustered at the " ///
                      "household level (in parentheses). " ///
                      "* p$<$0.10, ** p$<$0.05, *** p$<$0.01.} " ///
                      "\end{tabular}")

**## 3.2 - interpretation


********************************************************************************
**# 4 - xtreg, fe
********************************************************************************

* declare panel data structure
	xtset			qnno

* estimate the fixed effects model
	xtreg			yield totfertcostha, fe vce(cluster qnno)
	eststo			fe

**## 4.1 - export table with five columns

   esttab      ols fd demean lsdv fe using "$answ/11-fe.tex", replace ///
                    b(3) se(3) ///
                    rename(totfertcostha "Fertilizer Cost" d_fert "Fertilizer Cost" ///
                           dm_fert "Fertilizer Cost") ///
                    keep("Fertilizer Cost") ///
                    star(* 0.10 ** 0.05 *** 0.01) ///
                    stats(N r2, labels("Observations" "R-squared") fmt(0 3)) ///
                    noobs booktabs nonum nomtitle collabels(none) ///
                    nobaselevels nogaps fragment label ///
                    prehead("\begin{tabular}{l*{5}{c}} " ///
                      "\\[-1.8ex]\hline \hline \\[-1.8ex] " ///
                      "& \multicolumn{1}{c}{OLS} & " ///
                      "\multicolumn{1}{c}{FD} & " ///
                      "\multicolumn{1}{c}{Demean} & " ///
                      "\multicolumn{1}{c}{LSDV} & " ///
                      "\multicolumn{1}{c}{FE} \\ \midrule") ///
                    postfoot("\hline \hline \\[-1.8ex] " ///
                      "\multicolumn{6}{p{\linewidth}}{\small " ///
                      "\noindent \textit{Note}: Dependent variable " ///
                      "is chickpea yield in kg/ha. All models use " ///
                      "standard errors clustered at the " ///
                      "household level (in parentheses). " ///
                      "* p$<$0.10, ** p$<$0.05, *** p$<$0.01.} " ///
                      "\end{tabular}")

**## 4.2 - interpretation


********************************************************************************
**# 5 - two-way fixed effects
********************************************************************************

* declare panel data structure
	xtset			qnno

* run a one-way fe model
	xtreg			yield totfertcostha, fe vce(cluster qnno)
	eststo			owfe
	
* run a two-way fe model
	xtreg			yield totfertcostha i.tindex, fe vce(cluster qnno)
	eststo			twfe
	
* run a two-way fe model with reghdfe
	reghdfe			yield totfertcostha, absorb(qnno tindex) vce(cluster qnno)
	eststo			reghdfe

**## 5.1 - export table with three columns

   esttab      owfe twfe reghdfe using "$answ/11-twfe.tex", replace ///
                    b(3) se(3) ///
                    rename(totfertcostha "Fertilizer Cost") ///
                    keep("Fertilizer Cost") ///
                    star(* 0.10 ** 0.05 *** 0.01) ///
                    stats(N r2, labels("Observations" "R-squared") fmt(0 3)) ///
                    noobs booktabs nonum nomtitle collabels(none) ///
                    nobaselevels nogaps fragment label ///
                    prehead("\begin{tabular}{l*{3}{c}} " ///
                      "\\[-1.8ex]\hline \hline \\[-1.8ex] " ///
                      "& \multicolumn{1}{c}{OWFE} & " ///
                      "\multicolumn{1}{c}{TWFE} & " ///
                      "\multicolumn{1}{c}{reghdfe} \\ \midrule") ///
                    postfoot("\hline \hline \\[-1.8ex] " ///
                      "\multicolumn{4}{p{\linewidth}}{\small " ///
                      "\noindent \textit{Note}: Dependent variable " ///
                      "is chickpea yield in kg/ha. All models use " ///
                      "standard errors clustered at the " ///
                      "household level (in parentheses). " ///
                      "* p$<$0.10, ** p$<$0.05, *** p$<$0.01.} " ///
                      "\end{tabular}")

**## 5.2 - interpretation


********************************************************************************
**# 6 - staggered adoption cohorts
********************************************************************************

* sort by panel id and time
	sort			qnno tindex

* create cohort matching variable
	gen				first_icp = tindex if icp == 1
	bysort qnno:	egen min_icp = min(first_icp)
	replace			first_icp = min_icp
	drop			min_icp
	replace			first_icp = 0 if missing(first_icp)

* run a twfe model
	reghdfe			yield icp, absorb(qnno tindex) vce(cluster qnno)
	eststo			bias_twfe

********************************************************************************
**# 7 - modern TWFE estimators
********************************************************************************

**## 7.1 - bacon decomposition
	xtset			qnno tindex

	bacondecomp		yield icp, ddetail
	graph export	"$answ/11-bacon.png", replace

* run csdid
	csdid			yield, ivar(qnno) time(tindex) gvar(first_icp) tr(icp)
	
* display and save event study
	estat			event
	eststo			bacon_csdid

**## 7.2 - export table with two columns
   esttab      bias_twfe bacon_csdid using "$answ/11-bacon.tex", replace ///
                    b(3) se(3) ///
                    star(* 0.10 ** 0.05 *** 0.01) ///
                    stats(N, labels("Observations") fmt(0)) ///
                    noobs booktabs nonum nomtitle collabels(none) ///
                    nobaselevels nogaps fragment label ///
                    prehead("\begin{tabular}{l*{2}{c}} " ///
                      "\\[-1.8ex]\hline \hline \\[-1.8ex] " ///
                      "& \multicolumn{1}{c}{TWFE} & " ///
                      "\multicolumn{1}{c}{CSDID} \\ \midrule") ///
                    postfoot("\hline \hline \\[-1.8ex] " ///
                      "\multicolumn{3}{p{\linewidth}}{\small " ///
                      "\noindent \textit{Note}: Dependent variable " ///
                      "is chickpea yield in kg/ha. All models use " ///
                      "standard errors clustered at the " ///
                      "household level (in parentheses). " ///
                      "* p$<$0.10, ** p$<$0.05, *** p$<$0.01.} " ///
                      "\end{tabular}")

**## 7.3 - interpretation


********************************************************************************
**# 8 - challenge
********************************************************************************

* load tenure data
	use				"$data/mm-2.dta", clear
	estimates		clear

* run pooled OLS regression
	reg				yield icp totfertcostha totchemcostha, vce(cluster qnno)
	eststo			c1

* run time FE regression
	reg				yield icp totfertcostha totchemcostha i.tindex, vce(cluster qnno)
	eststo			c2

* run one-way FE regression
	xtset			qnno
	xtreg			yield icp totfertcostha totchemcostha, fe vce(cluster qnno)
	eststo			c3

* run two-way FE regression
	xtreg			yield icp totfertcostha totchemcostha i.tindex, fe vce(cluster qnno)
	eststo			c4

**## 8.1 - export table
   esttab      c1 c2 c3 c4 using "$answ/11-challenge-regs.tex", replace ///
                    b(3) se(3) ///
                    keep(icp) ///
                    star(* 0.10 ** 0.05 *** 0.01) ///
                    stats(N r2, labels("Observations" "R-squared") fmt(0 3)) ///
                    noobs booktabs nonum nomtitle collabels(none) ///
                    nobaselevels nogaps fragment label ///
                    prehead("\begin{tabular}{l*{4}{c}} " ///
                      "\\[-1.8ex]\hline \hline \\[-1.8ex] " ///
                      "& \multicolumn{1}{c}{OLS} & " ///
                      "\multicolumn{1}{c}{Time FE} & " ///
                      "\multicolumn{1}{c}{OWFE} & " ///
                      "\multicolumn{1}{c}{TWFE} \\ \midrule") ///
                    postfoot("\hline \hline \\[-1.8ex] " ///
                      "\multicolumn{5}{p{\linewidth}}{\small " ///
                      "\noindent \textit{Note}: Dependent variable " ///
                      "is chickpea yield in kg/ha. All models use " ///
                      "standard errors clustered at the " ///
                      "household level (in parentheses). " ///
                      "* p$<$0.10, ** p$<$0.05, *** p$<$0.01.} " ///
                      "\end{tabular}")

**## 8.2 - export coefficient plot
	coefplot		c1 c2 c3 c4, ///
					drop(_cons) keep(icp) ///
					xline(0) ///
					title("Coefficient on Irrigation across Models") ///
					legend(order(2 "OLS" 4 "Time FE" 6 "OWFE" 8 "TWFE") ///
						row(1) pos(6)) ///
					name(chal, replace)

	graph export	"$answ/11-challenge-coefplot.png", replace

  
********************************************************************************
**# 9 - end matter, clean up
********************************************************************************

* close log
	log				close

/* end */
