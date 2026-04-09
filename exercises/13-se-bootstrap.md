---
layout: exercise
topic: Standard Errors & Inference
title: Bootstrap Comparisons
language: Stata
---

If we aren't satisfied with analytical approximations of standard errors, we can calculate them empirically through Bootstrapping. In this exercise you will compare bootstrap standard errors to the analytical standard errors from the previous exercise.

- Using `Michler_JEEM.dta` (maize only, with `xtset rc year` already declared), run the panel IV regression with **bootstrap** standard errors:

```stata
* bootstrap panel iv standard errors
	bootstrap,      reps(1000) seed(123) cluster(rc): ///
	                    xtivreg2 lnyield lnbasal lntop lnseed lnaream2 ///
	                    pdate pdate2 i.year (CA = wardNGO), fe cluster(rc)
	eststo          boot
```

- Create a three-column comparison table (robust, clustered, bootstrap) by combining the stored estimates from the previous exercise with the new bootstrap result:

```stata
* three-column comparison
	esttab          robust clustered boot ///
	                    using "$answ/13-se-bootstrap.tex", replace ///
	                    b(3) se(3) ///
	                    keep(CA) ///
	                    star(* 0.10 ** 0.05 *** 0.01) ///
	                    mtitles("FE Robust" "FE Clustered" "FE Bootstrap") ///
	                    stats(N, labels("Observations") fmt(0)) ///
	                    noobs booktabs nonum collabels(none) ///
	                    nobaselevels nogaps fragment label ///
	                    prehead("\begin{tabular}{l*{3}{c}} " ///
	                        "\\[-1.8ex]\hline \hline \\[-1.8ex] " ///
	                        "& \multicolumn{3}{c}{Panel FE-IV} " ///
	                        "\\ \midrule") ///
	                    postfoot("\hline \hline \\[-1.8ex] " ///
	                        "\multicolumn{4}{p{0.85\linewidth}}{\small " ///
	                        "\noindent \textit{Note}: Dependent variable " ///
	                        "is log maize yield. CA instrumented with " ///
	                        "wardNGO. Bootstrap uses 1,000 repetitions. " ///
	                        "* p$<$0.10, ** p$<$0.05, *** p$<$0.01.} " ///
	                        "\end{tabular}")
```

1\. Are the bootstrapped standard errors closer to the robust or the clustered standard errors from the previous exercise?
2\. The bootstrap makes almost no assumptions about the error distribution. Does this make you more or less confident in the analytical (robust/clustered) standard errors you computed earlier?

---
