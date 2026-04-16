---
layout: exercise
topic: Standard Errors
title: Challenge 13
language: Stata
---

In the previous exercises we estimated the effect of conservation agriculture (CA) on **maize** yields. But the `Michler_JEEM.dta` dataset contains five crops. When we test the same hypothesis across five crops, we are conducting **multiple hypothesis tests**, and the probability of at least one spurious rejection rises sharply. In this exercise you will estimate crop-specific production functions, build a five-column table, and apply four different MHT corrections.

#### Part 1 — Estimate Crop-Specific Production Functions

- Load `"$data/Michler_JEEM.dta"`.
- The `crops` variable takes five values: `1` = Maize, `2` = Groundnut, `3` = W. Sorghum, `4` = Millet, `5` = Cowpea.
- Loop over each crop, subset the data, and run the OLS production function regression of `lnyield` on `CA lnbasal lntop lnseed lnaream2 pdate pdate2 i.year`, clustering standard errors at the household (`rc`) level. Store each set of results with a descriptive name:

```stata
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
```

#### Part 2 — Build a Five-Column Comparison Table

- Export a table with one column per crop, keeping only the `CA` coefficient:

```stata
* five-crop comparison table
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
```

#### Part 3 — Bonferroni and Holm Corrections

- We have 5 hypotheses (one per crop). Apply the **Bonferroni** and **Holm** corrections by hand:

```stata
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
```

#### Part 4 — Westfall-Young Correction

- Use `wyoung` (a resampling-based FWER correction) to compute adjusted *p*-values that account for the correlation structure across the five dependent variables:

```stata
* westfall-young adjusted p-values
	use             "$data/Michler_JEEM.dta", clear
	wyoung          lnyield, cmd(reg OUTCOMEVAR CA lnbasal lntop ///
	                    lnseed lnaream2 pdate pdate2 i.year ///
	                    if crops == GROUPVAR, vce(cluster rc)) ///
	                    familyp(CA) ///
	                    subgroup(crops) ///
	                    reps(1000) seed(123)
```

*(Note: You may need to run `ssc install wyoung` first.)*

#### Part 5 — Anderson Sharpened *q*-Values

- Finally, apply Anderson's (2008) FDR correction using the `fdr_sharpened_qvalues.do` script. This takes a dataset of *p*-values as input:

```stata
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
```

#### Part 6 — Compare All Corrections

1\. Create a summary table (by hand or in Stata) with one row per crop and columns for: raw *p*-value, Bonferroni, Holm, Westfall-Young, and Anderson *q*-value.
2\. Which crops have a statistically significant effect of CA after each correction? Do any results that were significant at the 5% level lose significance under the corrections?

---
