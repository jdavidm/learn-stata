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
	keep if         crop == 1

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
	keep if         crop == 1

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
	keep if         crop == 1

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
	                        "\multicolumn{5}{p{\linewidth}}{\small " ///
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
	                        "\multicolumn{6}{p{\linewidth}}{\small " ///
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
* (use ivregress rather than ivreg2 for boottest compatibility)
	ivregress       2sls lnyield lnbasal lntop lnseed lnaream2 ///
	                    pdate pdate2 i.year (CA = wardNGO), ///
	                    vce(cluster ward_id)

* wild cluster bootstrap for CA coefficient
* discard flushes cached Mata libraries after reinstall
	discard
	cap noisily boottest CA

**## 7.1 - interpretation

**## 7.2 - interpretation


**********************************************************************
**# exercise 8 - Randomization Inference
**********************************************************************

* reload data
	use             "$data/Michler_JEEM.dta", clear
	keep if         crop == 1

* save true coefficient
	reg             lnyield CA lnbasal lntop lnseed lnaream2 ///
	                    pdate pdate2 i.year, cluster(rc)
	global          true_b = _b[CA]

* randomization inference
	ritest          CA _b[CA], reps(1000) seed(0) nodots ///
	                    saving("$data/ri_yield", replace): ///
	                    reg lnyield CA lnbasal lntop lnseed ///
	                    lnaream2 pdate pdate2 i.year, cluster(rc)

* save ri p-value
	matrix          pvalues = r(p)
	global          ri_p = pvalues[1,1]
	global          ri_p : di %5.3f ${ri_p}

**## 8.1 - kdensity plot

* load permutation distribution
	use             "$data/ri_yield.dta", clear

* plot permutation distribution
	twoway          (kdensity _pm_1, lwidth(medthick) ///
	                    lcolor(sky) lpattern(dash)), ///
	                    ytitle("Density") ///
	                    xtitle("Hypothetical treatment effect estimate") ///
	                    title("CA effect on yield (t/ha)") ///
	                    xscale(range(${true_b})) ///
	                    xline(${true_b}, lpattern(solid) ///
	                        lwidth(thin) lcolor(sky)) ///
	                    text(.18 `=${true_b} - .01' "CA TE", ///
	                        color(sky) j(left) size(vsmall) ///
	                        place(nw) orient(vertical)) ///
	                    text(2.2 `=${true_b} - .01' ///
	                        "p-value = ${ri_p}", color(sky) ///
	                        j(left) size(vsmall) place(nw) ///
	                        orient(vertical)) ///
	                    legend(off)
	graph export    "$answ/13-se-ritest-1.png", replace

**## 8.2 - interpretation


**********************************************************************
**# challenge 13 - Multiple Hypothesis Testing
**********************************************************************

**## part 1 - estimate crop-specific production functions

* load data
	use             "$data/Michler_JEEM.dta", clear

* create year dummies (eststo can't handle i.year inside loops)
	qui tab         year, gen(y_)

* estimate crop-specific production functions
	local crops     `" "Maize" "Sorghum" "Millet" "Groundnut" "Cowpea" "'
	local i = 1

	foreach c of local crops {
	    preserve
	    keep if     crop == `i'

	    count
	    if r(N) > 0 {
	        reg         lnyield CA lnbasal lntop lnseed lnaream2 ///
	                        pdate pdate2 y_*, vce(cluster rc)
	        eststo      `c'

	        * store the p-value on CA for later
	        local       p`i' = r(table)[4,1]
	    }
	    else {
	        di "  No observations for `c' (crop == `i'), skipping."
	    }

	    restore
	    local       ++i
	}

**## part 2 - bonferroni and holm corrections

* collect the 5 p-values
	matrix          pvals = (`p1', `p2', `p3', `p4', `p5')
	matrix colnames pvals = Maize Sorghum Millet Groundnut Cowpea

* bonferroni: multiply each p-value by 5
	local crops     `" "Maize" "Sorghum" "Millet" "Groundnut" "Cowpea" "'
	local j = 1
	foreach c of local crops {
	    local       p_bonf`j' = min(pvals[1,`j'] * 5, 1)
	    local       ++j
	}

* holm: sort p-values and apply step-down penalties
	preserve
	clear
	set             obs 5
	gen             crop_name = ""
	gen             crop_id   = .
	gen             pval      = .
	replace         crop_name = "Maize"     in 1
	replace         crop_name = "Sorghum"   in 2
	replace         crop_name = "Millet"    in 3
	replace         crop_name = "Groundnut" in 4
	replace         crop_name = "Cowpea"    in 5
	forvalues       j = 1/5 {
	    replace     crop_id = `j'     in `j'
	    replace     pval    = `p`j''  in `j'
	}

	sort            pval
	gen             rank   = _n
	gen             holm_p = min(pval * (5 - rank + 1), 1)

* enforce monotonicity (holm adjusted p-values must be non-decreasing)
	replace         holm_p = holm_p[_n-1] if holm_p < holm_p[_n-1] ///
	                    & _n > 1

* store holm p-values back into locals by crop id
	forvalues       j = 1/5 {
	    su          holm_p if crop_id == `j', meanonly
	    local       p_holm`j' = r(mean)
	}
	list            crop_name pval holm_p, clean noobs
	restore

**## part 3 - westfall-young correction

* westfall-young adjusted p-values
	use             "$data/Michler_JEEM.dta", clear
	wyoung          lnyield, cmd(reg OUTCOMEVAR CA lnbasal lntop ///
	                    lnseed lnaream2 pdate pdate2 i.year, ///
	                    vce(cluster rc)) cluster(rc) ///
	                    familyp(CA) subgroup(crop) ///
	                    reps(100) seed(123)

* store westfall-young p-values (wyoung returns matrix r(table))
	matrix          wy = r(table)
	forvalues       j = 1/5 {
	    local       p_wy`j' = wy[`j', 4]
	}

**## part 4 - summary table with all p-values

* attach corrected p-values to each stored estimate
	local crops     `" "Maize" "Sorghum" "Millet" "Groundnut" "Cowpea" "'
	local j = 1
	foreach c of local crops {
	    estimates   restore `c'
	    estadd      scalar raw_p   = `p`j''
	    estadd      scalar bonf_p  = `p_bonf`j''
	    estadd      scalar holm_p  = `p_holm`j''
	    estadd      scalar wy_p    = `p_wy`j''
	    estimates   drop `c'
	    estimates   store `c'
	    local       ++j
	}

* export summary table
	esttab          Maize Sorghum Millet Groundnut Cowpea ///
	                    using "$answ/13-challenge.tex", replace ///
	                    b(3) nostar ///
	                    keep(CA) nodepvars ///
	                    mtitles("Maize" "Sorghum" "Millet" ///
	                        "Groundnut" "Cowpea") ///
	                    stats(raw_p bonf_p holm_p wy_p N r2, ///
	                        labels("Raw \textit{p}-value" ///
	                            "Bonferroni \textit{p}" ///
	                            "Holm \textit{p}" ///
	                            "Westfall-Young \textit{p}" ///
	                            "\midrule Observations" ///
	                            "R-squared") ///
	                        fmt(3 3 3 3 0 3)) ///
	                    noobs booktabs nonum collabels(none) ///
	                    nobaselevels nogaps fragment label ///
	                    prehead("\begin{tabular}{l*{5}{c}} " ///
	                        "\\[-1.8ex]\hline \hline \\[-1.8ex] " ///
	                        "& \multicolumn{5}{c}{Dependent Variable: " ///
	                        "Log Yield} \\ \midrule") ///
	                    postfoot("\hline \hline \\[-1.8ex] " ///
	                        "\multicolumn{6}{p{\linewidth}}{\small " ///
	                        "\noindent \textit{Note}: Each column is a " ///
	                        "separate OLS regression for the indicated " ///
	                        "crop. Reported \textit{p}-values are for " ///
	                        "the null hypothesis that " ///
	                        "$\beta_{\text{CA}} = 0$. " ///
	                        "Bonferroni and Holm adjust for 5 " ///
	                        "hypotheses. Westfall-Young uses 1,000 " ///
	                        "bootstrap replications.} " ///
	                        "\end{tabular}")

**## part 5 - interpretation


**********************************************************************
**# 9 - end matter
**********************************************************************

* close log
	cap             log close

/* end */