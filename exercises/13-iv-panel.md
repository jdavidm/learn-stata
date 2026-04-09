---
layout: exercise
topic: Instrumental Variables
title: Panel IV with `xtivreg2`
language: Stata
---

In the previous exercises we estimated the effect of conservation agriculture on maize yields using cross-sectional IV. But the `Michler_JEEM.dta` dataset is actually a **panel**: households (`rc`) are observed over multiple years. This means we can absorb time-invariant household heterogeneity with fixed effects *while* instrumenting for CA adoption.

- Using `Michler_JEEM.dta` (maize only), declare the panel structure with `xtset rc year`.
- Run a **pooled OLS** regression as a baseline: `reg lnyield CA lnbasal lntop lnseed lnaream2 pdate pdate2 i.year, vce(cluster rc)`. Store as `pooled`.
- Run a **fixed effects** regression using `xtreg`: `xtreg lnyield CA lnbasal lntop lnseed lnaream2 pdate pdate2 i.year, fe vce(cluster rc)`. Store as `fe`.
- Run a **panel IV** regression using `xtivreg2`: `xtivreg2 lnyield lnbasal lntop lnseed lnaream2 pdate pdate2 i.year (CA = wardNGO), fe cluster(rc) first`. Store as `fe_iv`.
- Export a three-column comparison table (Pooled OLS, FE, FE-IV):

```stata
* three-column panel comparison
	esttab          pooled fe fe_iv ///
	                    using "$answ/13-iv-panel.tex", replace ///
	                    b(3) se(3) ///
	                    keep(CA) ///
	                    star(* 0.10 ** 0.05 *** 0.01) ///
	                    mtitles("Pooled OLS" "FE" "FE-IV") ///
	                    stats(N r2, labels("Observations" "R-squared") ///
	                          fmt(0 3)) ///
	                    noobs booktabs nonum collabels(none) ///
	                    nobaselevels nogaps fragment label ///
	                    prehead("\begin{tabular}{l*{3}{c}} " ///
	                        "\\[-1.8ex]\hline \hline \\[-1.8ex] " ///
	                        "& \multicolumn{1}{c}{(1)} & " ///
	                        "\multicolumn{1}{c}{(2)} & " ///
	                        "\multicolumn{1}{c}{(3)} \\ \midrule") ///
	                    postfoot("\hline \hline \\[-1.8ex] " ///
	                        "\multicolumn{4}{p{0.85\linewidth}}{\small " ///
	                        "\noindent \textit{Note}: Dependent variable " ///
	                        "is log maize yield. All models include " ///
	                        "year fixed effects and input controls. " ///
	                        "Standard errors clustered at household " ///
	                        "level in parentheses. Column 3 instruments " ///
	                        "CA with wardNGO. " ///
	                        "* p$<$0.10, ** p$<$0.05, *** p$<$0.01.} " ///
	                        "\end{tabular}")
```

- Create a `coefplot` comparing the CA coefficient across all three specifications and export:

```stata
* coefficient plot across specifications
	coefplot        (pooled, label("Pooled OLS")) ///
	                (fe, label("Fixed Effects")) ///
	                (fe_iv, label("FE-IV")), ///
	                    keep(CA) xline(0) ///
	                    title("CA Effect Across Specifications") ///
	                    xtitle("Coefficient on CA") ///
	                    graphregion(color(white))
	graph export    "$answ/13-iv-panel-coefplot.png", replace
```

1\. How does the CA coefficient change when you move from pooled OLS to fixed effects? What does this tell you about time-invariant confounders?
2\. How does the CA coefficient change when you add IV (column 3)? What does this tell you about time-varying confounders?

---
