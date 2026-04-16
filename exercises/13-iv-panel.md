---
layout: exercise
topic: Instrumental Variables
title: Panel IV with `xtivreg2`
language: Stata
---

In the previous exercises we estimated the effect of conservation agriculture on maize yields using cross-sectional IV. But the `Michler_JEEM.dta` dataset is actually a **panel**: households (`rc`) are observed over multiple years. This means we can absorb time-invariant household heterogeneity with fixed effects *while* instrumenting for CA adoption.

- Using `Michler_JEEM.dta` (maize only), declare the panel structure with `xtset rc year`.
- Run a **fixed effects** regression using `xtreg` using the same variables as in the previous exercises but adding `fe`and `cluster(rc)`. Store as `fe`.
- Run a **panel IV** regression using `xtivreg2` using the same variables as in the previous exercises but adding `fe` and `cluster(rc)`. Store as `fe_iv`.


1\. Adapt your previous table to add 2 more columns. Order results as ols, manual, iv, fe, fe_iv. Export and put into Overleaf.

2\. Adapt your previous `coefplot` to include all 5 specifications and export to Overleaf.

3\. How does the CA coefficient change when you move from pooled OLS to fixed effects? What does this tell you about time-invariant confounders?

4\. How does the CA coefficient change when you add IV? What does this tell you about time-varying confounders?

---
