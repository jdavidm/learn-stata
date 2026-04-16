---
layout: exercise
topic: Instrumental Variables
title: Using `ivreg2`
language: Stata
---

The manual 2SLS from the previous exercise produces correct coefficients but incorrect standard errors, because Stata doesn't know that `CA_hat` is an estimated variable. Now we'll use the user-written `ivreg2` command, which handles both stages simultaneously, properly adjusts the standard errors, and automatically reports key diagnostic statistics (weak instrument F-stat, overidentification test).

- Using `Michler_JEEM.dta` (maize only), run `ivreg2` with `wardNGO` as the instrument for `CA`, including the same controls as Exercise 1 (`lnbasal lntop lnseed lnaream2 pdate pdate2 i.year`) and clustering at `rc`. Use the `first` option to display the first-stage results. Store as `iv`.

1\. Adapt the table code from Exercise 1 to add a third column for `ivreg2` and export to Overleaf.

2\. Create a `coefplot` comparing the `CA` coefficient across OLS, manual 2SLS, and `ivreg2` and export to Overleaf:

```stata
* coefficient plot comparing OLS, Manual, and IV
	coefplot        (ols, label("OLS")) ///
	                (manual, label("Manual 2SLS")) ///
	                (iv, label("IV (2SLS)")), ///
	                    keep(CA CA_hat) xline(0) ///
	                    title("Effect of CA on Maize Yield: " ///
						"OLS vs Manual vs IV") ///
	                    xtitle("Coefficient on CA and CA_hat") ///
	                    graphregion(color(white))
	graph export    "$answ/13-iv-coefplot.png", replace
```

3\. Is the coefficient on `CA` from `ivreg2` identical to the one you found manually in Exercise 1?

4\. Are the standard errors the same? Why or why not?

---
