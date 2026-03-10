---
layout: exercise
topic: Regression
title: Clustered Standard Errors
language: Stata
---


Using the **maize only** version of `eth_allrounds_final.dta` with per hectare inputs, compare default and clustered standard errors.
- Run `reg yield_kg fert labor i.irr i.admin_1, robust`
- Run the same regression with clustered standard errors: `, vce(cluster hhid)`

1. How did the standard error on `fert` change when moving from robust to clustered?
2. Does clustering at the household level or plot-level make sense for this data?

---