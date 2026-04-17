---
layout: exercise
topic: Standard Errors
title: Challenge 13
language: Stata
---

In the previous exercises we estimated the effect of conservation agriculture (CA) on **maize** yields. But the `Michler_JEEM.dta` dataset contains five crops. When we test the same hypothesis across five crops, we are conducting **multiple hypothesis tests**, and the probability of at least one spurious rejection rises sharply. In this exercise you will estimate crop-specific production functions, apply three MHT corrections, and build a summary table comparing all the corrected *p*-values.

#### Part 1 — Estimate Crop-Specific Production Functions

- Load `"$data/Michler_JEEM.dta"`.
- The `crop` variable takes five values: `1` = Maize, `2` = Sorghum, `3` = Millet, `4` = Groundnut, `5` = Cowpea.
- Because `eststo` does not support factor-variable operators inside loops, first generate year dummies with `tab year, gen(y_)`.
- Loop over each crop, subset the data, and run the OLS production function regression of `lnyield` on `CA lnbasal lntop lnseed lnaream2 pdate pdate2 y_*`, clustering standard errors at the household (`rc`) level. Store each set of results with a descriptive name:

```stata
* load data
	use             "$data/Michler_JEEM.dta", clear

* create year dummies (eststo can't handle i.year inside loops)
	qui tab         year, gen(y_)

* estimate crop-specific production functions
	local crops `" "Maize" "Sorghum" "Millet" "Groundnut" "Cowpea" "'
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

	    restore
	    local       ++i
	}
```

#### Part 2 — Bonferroni and Holm Corrections

- We have 5 hypotheses (one per crop). Apply the **Bonferroni** and **Holm** corrections by hand, storing the corrected *p*-values into locals so they can be used later in a table:

```stata
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
```

#### Part 3 — Westfall-Young Correction

- Use `wyoung` (a resampling-based FWER correction) to compute adjusted *p*-values that account for the correlation structure across the five crops, then store the results into locals:

```stata
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
```

*(Note: You may need to run `ssc install wyoung` first.)*

#### Part 4 — Summary Table with All *p*-Values

- Use `estadd` to attach the raw and corrected *p*-values as scalars to each stored estimate, then export a single table. Instead of standard errors, the table shows the CA coefficient followed by a row for each *p*-value correction:

```stata
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
```

#### Part 5 — Interpretation

1. Which crops have a statistically significant effect of CA at the 5% level using the raw *p*-value? Do any results lose significance under the corrections?
2. Why do the Westfall-Young adjusted *p*-values tend to be less conservative than the Bonferroni correction?

---

