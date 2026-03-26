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
	use				"$data/tenuredata.dta", clear

* run pooled OLS regression
	reg				yield q_f_ha, vce(cluster panelid)
	eststo			ols

* sort by panel id and time
	sort			panelid year

* create first-differenced variables
	by panelid:		gen d_yield = yield - yield[_n-1]
	by panelid:		gen d_fert = q_f_ha - q_f_ha[_n-1]

* regress the differenced variables
	reg				d_yield d_fert, vce(cluster panelid)
	eststo			fd

**## 1.2 - export table

* print table with OLS and FD columns
   esttab      ols fd using "$answ/11-fd.tex", replace ///
                    b(3) se(3) ///
                    rename(q_f_ha "Fertilizer" d_fert "Fertilizer") ///
                    keep("Fertilizer") ///
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
                      "is rice yield in kg/ha. All models use " ///
                      "standard errors clustered at the " ///
                      "household level (in parentheses). " ///
                      "* p$<$0.10, ** p$<$0.05, *** p$<$0.01.} " ///
                      "\end{tabular}")

**## 1.2 - interpretation


********************************************************************************
**# 2 - demeaning the data (within-transformation)
********************************************************************************

* calculate household-specific means
	bysort panelid:	egen mean_yield = mean(yield)
	bysort panelid:	egen mean_fert  = mean(q_f_ha)

* demean the variables
	gen				dm_yield = yield - mean_yield
	gen				dm_fert  = q_f_ha - mean_fert

* run the regression on demeaned data
	reg				dm_yield dm_fert, vce(cluster panelid)
	eststo			demean

**## 2.1 - export table with three columns

   esttab      ols fd demean using "$answ/11-demean.tex", replace ///
                    b(3) se(3) ///
                    rename(q_f_ha "Fertilizer" d_fert "Fertilizer" ///
                           dm_fert "Fertilizer") ///
                    keep("Fertilizer") ///
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
                      "is rice yield in kg/ha. All models use " ///
                      "standard errors clustered at the " ///
                      "household level (in parentheses). " ///
                      "* p$<$0.10, ** p$<$0.05, *** p$<$0.01.} " ///
                      "\end{tabular}")

**## 2.2 - interpretation


********************************************************************************
**# 3 - least squares dummy variables (LSDV)
********************************************************************************

* include household fixed effects via dummy variables using i.
	reg				yield q_f_ha i.panelid, vce(cluster panelid)
	eststo			lsdv

**## 3.1 - export table with four columns

   esttab      ols fd demean lsdv using "$answ/11-lsdv.tex", replace ///
                    b(3) se(3) ///
                    rename(q_f_ha "Fertilizer" d_fert "Fertilizer" ///
                           dm_fert "Fertilizer") ///
                    keep("Fertilizer") ///
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
                      "is rice yield in kg/ha. All models use " ///
                      "standard errors clustered at the " ///
                      "household level (in parentheses). " ///
                      "* p$<$0.10, ** p$<$0.05, *** p$<$0.01.} " ///
                      "\end{tabular}")

**## 3.2 - interpretation


********************************************************************************
**# 4 - xtreg, fe
********************************************************************************

* declare panel data structure
	xtset			panelid

* estimate the fixed effects model
	xtreg			yield q_f_ha, fe vce(cluster panelid)
	eststo			fe

**## 4.1 - export table with five columns

   esttab      ols fd demean lsdv fe using "$answ/11-fe.tex", replace ///
                    b(3) se(3) ///
                    rename(q_f_ha "Fertilizer" d_fert "Fertilizer" ///
                           dm_fert "Fertilizer") ///
                    keep("Fertilizer") ///
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
                      "is rice yield in kg/ha. All models use " ///
                      "standard errors clustered at the " ///
                      "household level (in parentheses). " ///
                      "* p$<$0.10, ** p$<$0.05, *** p$<$0.01.} " ///
                      "\end{tabular}")

**## 4.2 - interpretation


********************************************************************************
**# 5 - end matter, clean up
********************************************************************************

* close log
	log				close

/* end */
