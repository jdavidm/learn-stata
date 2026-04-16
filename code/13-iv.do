* course: 597a
* assignment: 13
* created on: 16 apr 26
* created by: jdm
* edited on: 16 apr 26
* edited by: jdm
* stata v.19.5


**********************************************************************
**# 0 - setup
**********************************************************************

* open log
	cap             log close
	log             using "$logout/13-iv.log", append

	
**********************************************************************
**# exercise 1 - Manual 2SLS
**********************************************************************

* load data
	use             "$data/Michler_JEEM.dta", clear
    
	keep if			crops == 1
	
* run OLS
	reg				lnyield CA lnbasal lntop lnseed lnaream2 pdate2 i.year, ///
						vce(cluster rc)
	eststo			ols
	
* manual first stage
	reg				CA wardNGO lnbasal lntop lnseed lnaream2 pdate2 i.year, ///
						vce(cluster rc)
	eststo			first
	
	predict			CA_hat, xb
	
* manual second stage
	reg				lnyield CA_hat lnbasal lntop lnseed lnaream2 pdate2 i.year, ///
						vce(cluster rc)
	eststo			manual

* compare ols and manual 2sls	
	esttab          ols manual using "$answ/13-iv-manual.tex", replace ///
	                    b(3) se(3) ///
	                    keep(CA) rename(CA_hat CA) nodepvars ///
	                    star(* 0.10 ** 0.05 *** 0.01) ///
	                    nomtitles ///
	                    stats(N r2, labels("Observations" "R-squared") ///
	                          fmt(0 3)) ///
	                    noobs booktabs nonum collabels(none) ///
	                    nobaselevels nogaps fragment label ///
	                    prehead("\begin{tabular}{l*{2}{c}} " ///
	                        "\\[-1.8ex]\hline \hline \\[-1.8ex] " ///
	                        "& \multicolumn{1}{c}{OLS} & " ///
	                        "\multicolumn{1}{c}{Manual 2SLS} " ///
	                        "\\ \midrule") ///
	                    postfoot("\hline \hline \\[-1.8ex] " ///
	                        "\multicolumn{3}{p{\linewidth}}{\small " ///
	                        "\noindent \textit{Note}: Dependent variable " ///
	                        "is log maize yield. Standard errors " ///
	                        "clustered at household level in " ///
	                        "parentheses. Manual 2SLS standard errors " ///
	                        "are incorrect. " ///
	                        "* p$<$0.10, ** p$<$0.05, *** p$<$0.01.} " ///
	                        "\end{tabular}")
							

**********************************************************************
**# exercise 2 - ivreg2
**********************************************************************
	
* manual second stage
	ivreg2			lnyield lnbasal lntop lnseed lnaream2 pdate2 i.year (CA = wardNGO, ///
						vce(cluster rc)
	eststo			iv

* compare ols and manual 2sls	
	esttab          ols manual iv using "$answ/13-ivregress.tex", replace ///
	                    b(3) se(3) ///
	                    keep(CA) rename(CA_hat CA) nodepvars ///
	                    star(* 0.10 ** 0.05 *** 0.01) ///
	                    nomtitles ///
	                    stats(N r2, labels("Observations" "R-squared") ///
	                          fmt(0 3)) ///
	                    noobs booktabs nonum collabels(none) ///
	                    nobaselevels nogaps fragment label ///
	                    prehead("\begin{tabular}{l*{3}{c}} " ///
	                        "\\[-1.8ex]\hline \hline \\[-1.8ex] " ///
	                        "& \multicolumn{1}{c}{OLS} & " ///
	                        "\multicolumn{1}{c}{Manual 2SLS} " ///
	                        "\\ \midrule") ///
	                    postfoot("\hline \hline \\[-1.8ex] " ///
	                        "\multicolumn{3}{p{\linewidth}}{\small " ///
	                        "\noindent \textit{Note}: Dependent variable " ///
	                        "is log maize yield. Standard errors " ///
	                        "clustered at household level in " ///
	                        "parentheses. Manual 2SLS standard errors " ///
	                        "are incorrect. " ///
	                        "* p$<$0.10, ** p$<$0.05, *** p$<$0.01.} " ///
	                        "\end{tabular}")
													