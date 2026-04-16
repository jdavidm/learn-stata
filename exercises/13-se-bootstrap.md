---
layout: exercise
topic: Standard Errors
title: Bootstrap Comparisons
language: Stata
---

If we aren't satisfied with analytical approximations of standard errors, we can calculate them empirically through bootstrapping. In this exercise you will compare bootstrap standard errors to the analytical standard errors from the previous exercise.

- Using `Michler_JEEM.dta` (maize only), run the pooled IV regression (`ivreg2`) with **bootstrap** standard errors.
- Set the seed to 5453654.
- Bootstrap the regression 1,000 times.
- Cluster the standard errors at the household (`rc`) level.

1. Adapt the table code from Exercise 5 to add a fifth column for the bootstrap results and export to Overleaf.
2. Are the bootstrapped standard errors closer to the robust or the clustered standard errors from the previous exercise?


---
