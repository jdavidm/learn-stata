---
layout: exercise
topic: Instrumental Variables
title: Comparing IV to OLS
language: Stata
---

The manual 2SLS from the previous exercise produces correct coefficients but incorrect standard errors, because Stata doesn't know that `CA_hat` is an estimated variable. Now we'll use the user-written `ivreg2` command, which handles both stages simultaneously, properly adjusts the standard errors, and automatically reports key diagnostic statistics (weak instrument F-stat, overidentification test).

- Using `Michler_JEEM.dta` (maize only), run `ivreg2` with `wardNGO` as the instrument for `CA`, including the same controls as Exercise 1 (`lnbasal lntop lnseed lnaream2 pdate pdate2 i.year`) and robust standard errors. Use the `first` option to display the first-stage results. Store as `iv`.
- Create a three-column table comparing OLS, Manual 2SLS, and `ivreg2`:

```stata
* three-column comparison
	esttab          ols manual iv ///
	                    using "$answ/13-iv-comparison.tex", replace ///
	                    b(3) se(3) ///
	                    keep(CA CA_hat) ///
	                    star(* 0.10 ** 0.05 *** 0.01) ///
	                    mtitles("OLS" "Manual 2SLS" "IV (ivreg2)") ///
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
	                        "is log maize yield. Column 1 is OLS. " ///
	                        "Column 2 is manual 2SLS (SEs incorrect). " ///
	                        "Column 3 is \texttt{ivreg2} with robust " ///
	                        "SEs. * p$<$0.10, ** p$<$0.05, " ///
	                        "*** p$<$0.01.} " ///
	                        "\end{tabular}")
```

- Create a `coefplot` comparing the `CA` coefficient across OLS and `ivreg2` and export for LaTeX:

```stata
* coefficient plot comparing OLS and IV
	coefplot        (ols, label("OLS")) ///
	                (iv, label("IV (2SLS)")), ///
	                    keep(CA) xline(0) ///
	                    title("Effect of CA on Maize Yield: OLS vs IV") ///
	                    xtitle("Coefficient on CA") ///
	                    graphregion(color(white))
	graph export    "$answ/13-iv-coefplot.png", replace
```

1\. Is the coefficient on `CA` from `ivreg2` identical to the one you found manually in Exercise 1?
2\. Are the standard errors the same? Why or why not?
3\. Look at the diagnostic statistics that `ivreg2` reports at the bottom of the output. What is the Kleibergen-Paap F-statistic? Does it suggest `wardNGO` is a strong instrument?

---
