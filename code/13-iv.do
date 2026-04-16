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
	keep if         crops == 1

* naive ols
	reg             lnyield CA lnbasal lntop lnseed lnaream2 ///
	                    pdate pdate2 i.year, cluster(rc)
	eststo          ols

* first stage
	reg             CA wardNGO lnbasal lntop lnseed lnaream2 ///
	                    pdate pdate2 i.year, cluster(rc)
	eststo          first

* generate predicted values
	predict         CA_hat, xb

* second stage (manual 2sls)
	reg             lnyield CA_hat lnbasal lntop lnseed lnaream2 ///
	                    pdate pdate2 i.year, cluster(rc)
	eststo          manual

**## 1.1 - export table

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
	                        "\noindent \textit{Note}: Dependent var. " ///
	                        "is log maize yield. Standard errors " ///
	                        "clustered at household level in " ///
	                        "parentheses. Manual 2SLS standard errors " ///
	                        "are incorrect. " ///
	                        "* p$<$0.10, ** p$<$0.05, *** p$<$0.01.} " ///
	                        "\end{tabular}")

**## 1.2 - interpretation


**********************************************************************
**# exercise 2 - Using ivreg2
**********************************************************************

* run ivreg2
	ivreg2          lnyield lnbasal lntop lnseed lnaream2 ///
	                    pdate pdate2 i.year (CA = wardNGO), ///
	                    cluster(rc) first
	eststo          iv

**## 2.1 - three-column table (adapt from exercise 1)

	esttab          ols manual iv using "$answ/13-iv-comparison.tex", replace ///
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
	                        "\multicolumn{1}{c}{Manual 2SLS} & " ///
	                        "\multicolumn{1}{c}{IV (ivreg2)} " ///
	                        "\\ \midrule") ///
	                    postfoot("\hline \hline \\[-1.8ex] " ///
	                        "\multicolumn{4}{p{\linewidth}}{\small " ///
	                        "\noindent \textit{Note}: Dependent var. " ///
	                        "is log maize yield. Standard errors " ///
	                        "clustered at household level in " ///
	                        "parentheses. Manual 2SLS standard errors " ///
	                        "are incorrect. " ///
	                        "* p$<$0.10, ** p$<$0.05, *** p$<$0.01.} " ///
	                        "\end{tabular}")

**## 2.2 - coefficient plot comparing OLS, Manual, and IV

	coefplot        (ols, label("OLS")) ///
	                (manual, label("Manual 2SLS")) ///
	                (iv, label("IV (2SLS)")), ///
	                    keep(CA CA_hat) xline(0) ///
	                    title("Effect of CA on Maize Yield: " ///
						"OLS vs Manual vs IV") ///
	                    xtitle("Coefficient on CA and CA_hat") ///
	                    graphregion(color(white))
	graph export    "$answ/13-iv-comparison-2.png", replace

**## 2.3 - interpretation


**********************************************************************
**# exercise 3 - Panel IV with xtivreg2
**********************************************************************

* reload data (need to drop CA_hat and start fresh)
	use             "$data/Michler_JEEM.dta", clear
	keep if         crops == 1

* create year dummies (xtivreg2 can't handle i.year)
	qui tab         year, gen(y_)

* declare panel structure
	xtset           rc

* fixed effects regression
	xtreg           lnyield CA lnbasal lntop lnseed lnaream2 ///
	                    pdate pdate2 y_*, fe vce(cluster rc)
	eststo          fe

* panel iv regression
	xtivreg2        lnyield lnbasal lntop lnseed lnaream2 ///
	                    pdate pdate2 y_* (CA = wardNGO), ///
	                    fe cluster(rc) first
	eststo          fe_iv

**## 3.1 - five-column table

	esttab          ols manual iv fe fe_iv ///
	                    using "$answ/13-iv-panel.tex", replace ///
	                    b(3) se(3) ///
	                    keep(CA) rename(CA_hat CA) nodepvars ///
	                    star(* 0.10 ** 0.05 *** 0.01) ///
	                    nomtitles ///
	                    stats(N r2, labels("Observations" "R-squared") ///
	                          fmt(0 3)) ///
	                    noobs booktabs nonum collabels(none) ///
	                    nobaselevels nogaps fragment label ///
	                    prehead("\begin{tabular}{l*{5}{c}} " ///
	                        "\\[-1.8ex]\hline \hline \\[-1.8ex] " ///
	                        "& \multicolumn{1}{c}{OLS} & " ///
	                        "\multicolumn{1}{c}{Manual} & " ///
	                        "\multicolumn{1}{c}{IV} & " ///
	                        "\multicolumn{1}{c}{FE} & " ///
	                        "\multicolumn{1}{c}{FE-IV} " ///
	                        "\\ \midrule") ///
	                    postfoot("\hline \hline \\[-1.8ex] " ///
	                        "\multicolumn{6}{p{\linewidth}}{\small " ///
	                        "\noindent \textit{Note}: Dependent var. " ///
	                        "is log maize yield. Standard errors " ///
	                        "clustered at household level in " ///
	                        "parentheses. " ///
	                        "* p$<$0.10, ** p$<$0.05, *** p$<$0.01.} " ///
	                        "\end{tabular}")

**## 3.2 - five-model coefficient plot

	coefplot        (ols, label("OLS")) ///
	                (manual, label("Manual 2SLS")) ///
	                (iv, label("IV (ivreg2)")) ///
	                (fe, label("FE")) ///
	                (fe_iv, label("FE-IV")), ///
	                    keep(CA CA_hat) xline(0) ///
	                    title("CA Effect Across Specifications") ///
	                    xtitle("Coefficient on CA") ///
	                    graphregion(color(white))
	graph export    "$answ/13-iv-panel-2.png", replace

**## 3.3 - interpretation


**********************************************************************
**# exercise 4 - Instrument Diagnostics
**********************************************************************

* run xtivreg2 with diagnostics
	xtivreg2        lnyield lnbasal lntop lnseed lnaream2 ///
	                    pdate pdate2 y_* (CA = wardNGO), ///
	                    fe cluster(rc) first endog(CA)

**## 4.1 - interpretation


**********************************************************************
**# exercise 5 - Robust Standard Errors
**********************************************************************

* reload data
	use             "$data/Michler_JEEM.dta", clear
	keep if         crops == 1

* default (uncorrected) standard errors
	ivreg2          lnyield lnbasal lntop lnseed lnaream2 ///
	                    pdate pdate2 i.year (CA = wardNGO)
	eststo          def

* robust standard errors
	ivreg2          lnyield lnbasal lntop lnseed lnaream2 ///
	                    pdate pdate2 i.year (CA = wardNGO), ///
	                    robust
	eststo          robust

* hc2 (bell-mccaffrey) standard errors
* bw/kernel options require tsset; generate unique obs id
* (bw(1) + truncated kernel uses only lag 0, so artificial id is harmless)
	gen             obs_id = _n
	tsset           obs_id
	ivreg2          lnyield lnbasal lntop lnseed lnaream2 ///
	                    pdate pdate2 i.year (CA = wardNGO), ///
	                    bw(1) kernel(tru)
	eststo          hc2
	drop            obs_id

* clustered standard errors
	ivreg2          lnyield lnbasal lntop lnseed lnaream2 ///
	                    pdate pdate2 i.year (CA = wardNGO), ///
	                    cluster(rc)
	eststo          cluster

**## 5.1 - four-column table

	esttab          def robust hc2 cluster ///
	                    using "$answ/13-se-hc2.tex", replace ///
	                    b(3) se(3) keep(CA) nomtitles ///
	                    star(* 0.10 ** 0.05 *** 0.01) ///
	                    stats(N, labels("Observations") fmt(0)) ///
	                    noobs booktabs nonum collabels(none) ///
	                    nobaselevels nogaps fragment label ///
	                    prehead("\begin{tabular}{l*{4}{c}} " ///
	                        "\\[-1.8ex]\hline \hline \\[-1.8ex] " ///
	                        "& \multicolumn{1}{c}{Uncorrected} & " ///
	                        "\multicolumn{1}{c}{Robust} & " ///
	                        "\multicolumn{1}{c}{HC2} & " ///
	                        "\multicolumn{1}{c}{Clustered} " ///
	                        "\\ \midrule") ///
	                    postfoot("\hline \hline \\[-1.8ex] " ///
	                        "\multicolumn{5}{p{0.9\linewidth}}{\small " ///
	                        "\noindent \textit{Note}: Dependent variable " ///
	                        "is log maize yield. CA instrumented with " ///
	                        "wardNGO. All models include input controls " ///
	                        "and year FE. " ///
	                        "* p$<$0.10, ** p$<$0.05, *** p$<$0.01.} " ///
	                        "\end{tabular}")

**## 5.2 - interpretation


**********************************************************************
**# exercise 6 - Bootstrap Comparisons
**********************************************************************

* bootstrap standard errors
	bootstrap,      reps(1000) seed(5453654) cluster(rc): ///
	                    ivreg2 lnyield lnbasal lntop lnseed lnaream2 ///
	                    pdate pdate2 i.year (CA = wardNGO), ///
	                    cluster(rc)
	eststo          boot

**## 6.1 - five-column table (add bootstrap to exercise 5 table)

	esttab          def robust hc2 cluster boot ///
	                    using "$answ/13-se-bootstrap.tex", replace ///
	                    b(3) se(3) keep(CA) nomtitles ///
	                    star(* 0.10 ** 0.05 *** 0.01) ///
	                    stats(N, labels("Observations") fmt(0)) ///
	                    noobs booktabs nonum collabels(none) ///
	                    nobaselevels nogaps fragment label ///
	                    prehead("\begin{tabular}{l*{5}{c}} " ///
	                        "\\[-1.8ex]\hline \hline \\[-1.8ex] " ///
	                        "& \multicolumn{1}{c}{Uncorrected} & " ///
	                        "\multicolumn{1}{c}{Robust} & " ///
	                        "\multicolumn{1}{c}{HC2} & " ///
	                        "\multicolumn{1}{c}{Clustered} & " ///
	                        "\multicolumn{1}{c}{Bootstrap} " ///
	                        "\\ \midrule") ///
	                    postfoot("\hline \hline \\[-1.8ex] " ///
	                        "\multicolumn{6}{p{0.9\linewidth}}{\small " ///
	                        "\noindent \textit{Note}: Dependent variable " ///
	                        "is log maize yield. CA instrumented with " ///
	                        "wardNGO. Bootstrap uses 1,000 reps. " ///
	                        "* p$<$0.10, ** p$<$0.05, *** p$<$0.01.} " ///
	                        "\end{tabular}")

**## 6.2 - interpretation


**********************************************************************
**# exercise 7 - Wild Cluster Bootstrap
**********************************************************************

* iv regression clustered at ward level
	ivreg2          lnyield lnbasal lntop lnseed lnaream2 ///
	                    pdate pdate2 i.year (CA = wardNGO), ///
	                    cluster(ward_id)
	eststo          ward

* wild cluster bootstrap for CA coefficient
	boottest        CA
	eststo          wboot

**## 7.1 - seven-column table (add ward + wboot to exercise 6 table)

	esttab          def robust hc2 cluster boot ward wboot ///
	                    using "$answ/13-se-boottest.tex", replace ///
	                    b(3) se(3) keep(CA) nomtitles ///
	                    star(* 0.10 ** 0.05 *** 0.01) ///
	                    stats(N, labels("Observations") fmt(0)) ///
	                    noobs booktabs nonum collabels(none) ///
	                    nobaselevels nogaps fragment label ///
	                    prehead("\begin{tabular}{l*{7}{c}} " ///
	                        "\\[-1.8ex]\hline \hline \\[-1.8ex] " ///
	                        "& \multicolumn{1}{c}{Uncorr.} & " ///
	                        "\multicolumn{1}{c}{Robust} & " ///
	                        "\multicolumn{1}{c}{HC2} & " ///
	                        "\multicolumn{1}{c}{Cluster} & " ///
	                        "\multicolumn{1}{c}{Boot} & " ///
	                        "\multicolumn{1}{c}{Ward} & " ///
	                        "\multicolumn{1}{c}{WCB} " ///
	                        "\\ \midrule") ///
	                    postfoot("\hline \hline \\[-1.8ex] " ///
	                        "\multicolumn{8}{p{\linewidth}}{\small " ///
	                        "\noindent \textit{Note}: Dependent variable " ///
	                        "is log maize yield. CA instrumented with " ///
	                        "wardNGO. " ///
	                        "* p$<$0.10, ** p$<$0.05, *** p$<$0.01.} " ///
	                        "\end{tabular}")

**## 7.2 - interpretation


**********************************************************************
**# exercise 8 - Randomization Inference
**********************************************************************

* reload data
	use             "$data/Michler_JEEM.dta", clear
	keep if         crops == 1

* save true coefficient
	reg             lnyield CA lnbasal lntop lnseed lnaream2 ///
	                    pdate pdate2 i.year, cluster(rc)
	local           true_b = _b[CA]

* randomization inference
	ritest          CA _b[CA], reps(1000) seed(0) nodots ///
	                    saving("$data/ri_yield", replace): ///
	                    reg lnyield CA lnbasal lntop lnseed ///
	                    lnaream2 pdate pdate2 i.year, cluster(rc)

* save ri p-value
	matrix          pvalues = r(p)
	local           ri_p = pvalues[1,1]
	local           ri_p : di %5.3f `ri_p'

**## 8.1 - kdensity plot

* load permutation distribution
	use             "$data/ri_yield.dta", clear

* plot permutation distribution
	twoway          (kdensity _pm_1, lwidth(medthick) ///
	                    lcolor(sky) lpattern(dash)), ///
	                    ytitle("Density") ///
	                    xtitle("Hypothetical treatment effect estimate") ///
	                    title("CA effect on yield (t/ha)") ///
	                    xline(`true_b', lpattern(solid) ///
	                        lwidth(thin) lcolor(sky)) ///
	                    text(.18 `=`true_b'-.01' "CA TE", ///
	                        color(sky) j(left) size(vsmall) ///
	                        place(nw) orient(vertical)) ///
	                    text(2.2 `=`true_b'-.01' ///
	                        "p-value = `ri_p'", color(sky) ///
	                        j(left) size(vsmall) place(nw) ///
	                        orient(vertical)) ///
	                    legend(off)
	graph export    "$answ/13-ri-kdensity.png", replace

**## 8.2 - interpretation


**********************************************************************
**# challenge 13 - Multiple Hypothesis Testing
**********************************************************************

**## part 1 - estimate crop-specific production functions

* load data
	use             "$data/Michler_JEEM.dta", clear

* estimate crop-specific production functions
	local crops     `" "Maize" "Groundnut" "Sorghum" "Millet" "Cowpea" "'
	local i = 1

	foreach c of local crops {
	    preserve
	    keep if     crops == `i'

	    reg         lnyield CA lnbasal lntop lnseed lnaream2 ///
	                    pdate pdate2 i.year, vce(cluster rc)
	    eststo      `c'

	    * store the p-value on CA for later
	    local       p`i' = r(table)[4,1]

	    restore
	    local       ++i
	}

**## part 2 - five-crop comparison table

	esttab          Maize Groundnut Sorghum Millet Cowpea ///
	                    using "$answ/13-se-mht.tex", replace ///
	                    b(3) se(3) ///
	                    keep(CA) ///
	                    star(* 0.10 ** 0.05 *** 0.01) ///
	                    mtitles("Maize" "Groundnut" "W. Sorghum" ///
	                        "Millet" "Cowpea") ///
	                    stats(N, labels("Observations") fmt(0)) ///
	                    noobs booktabs nonum collabels(none) ///
	                    nobaselevels nogaps fragment label ///
	                    prehead("\begin{tabular}{l*{5}{c}} " ///
	                        "\\[-1.8ex]\hline \hline \\[-1.8ex] " ///
	                        "& \multicolumn{5}{c}{Dependent Variable: " ///
	                        "Log Yield} \\ \midrule") ///
	                    postfoot("\hline \hline \\[-1.8ex] " ///
	                        "\multicolumn{6}{p{0.95\linewidth}}{\small " ///
	                        "\noindent \textit{Note}: Each column is a " ///
	                        "separate OLS regression for the indicated " ///
	                        "crop. Standard errors clustered at the " ///
	                        "household level in parentheses. " ///
	                        "* p$<$0.10, ** p$<$0.05, *** p$<$0.01.} " ///
	                        "\end{tabular}")

**## part 3 - bonferroni and holm corrections

* collect the 5 p-values
	matrix          pvals = (`p1', `p2', `p3', `p4', `p5')
	matrix colnames pvals = Maize Groundnut Sorghum Millet Cowpea

* bonferroni: multiply each p-value by 5
	di              "=== Bonferroni Correction ==="
	forvalues       j = 1/5 {
	    local       p_bonf = min(pvals[1,`j'] * 5, 1)
	    di          "  Crop `j': raw p = " %6.4f pvals[1,`j'] ///
	                    "  Bonferroni p = " %6.4f `p_bonf'
	}

* holm: sort p-values and apply step-down penalties
	di              _n "=== Holm Correction ==="
	preserve
	clear
	set             obs 5
	gen             crop = ""
	gen             pval = .
	replace         crop = "Maize"     in 1
	replace         crop = "Groundnut" in 2
	replace         crop = "Sorghum"   in 3
	replace         crop = "Millet"    in 4
	replace         crop = "Cowpea"    in 5
	replace         pval = `p1'        in 1
	replace         pval = `p2'        in 2
	replace         pval = `p3'        in 3
	replace         pval = `p4'        in 4
	replace         pval = `p5'        in 5

	sort            pval
	gen             rank = _n
	gen             holm_p = min(pval * (5 - rank + 1), 1)

* enforce monotonicity (holm adjusted p-values must be non-decreasing)
	replace         holm_p = holm_p[_n-1] if holm_p < holm_p[_n-1] ///
	                    & _n > 1
	list            crop pval holm_p, clean noobs
	restore

**## part 4 - westfall-young correction

* westfall-young adjusted p-values
	use             "$data/Michler_JEEM.dta", clear
	wyoung          lnyield, cmd(reg OUTCOMEVAR CA lnbasal lntop ///
	                    lnseed lnaream2 pdate pdate2 i.year ///
	                    if crops == GROUPVAR, vce(cluster rc)) ///
	                    familyp(CA) ///
	                    subgroup(crops) ///
	                    reps(1000) seed(123)

**## part 5 - anderson sharpened q-values

* prepare p-value dataset for anderson's procedure
	clear
	set             obs 5
	gen             crop = ""
	gen             pval = .
	replace         crop = "Maize"     in 1
	replace         crop = "Groundnut" in 2
	replace         crop = "Sorghum"   in 3
	replace         crop = "Millet"    in 4
	replace         crop = "Cowpea"    in 5
	replace         pval = `p1'        in 1
	replace         pval = `p2'        in 2
	replace         pval = `p3'        in 3
	replace         pval = `p4'        in 4
	replace         pval = `p5'        in 5

* run anderson's sharpened q-value procedure
	do              "$code/fdr_sharpened_qvalues.do"
	list            crop pval bky06_qval, clean noobs

**## part 6 - interpretation


**********************************************************************
**# 9 - end matter
**********************************************************************

* close log
	cap             log close

/* end */