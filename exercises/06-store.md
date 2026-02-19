---
layout: exercise
topic: Macros
title: Storing Results as Numbers
language: Stata
---


Here you will practice storing regression output in **scalars** and using them later.

1. Run a regression of yield (`yield_kg`) on fertilizer (`nitrogen_kg`) and plot characteristics (`plot_area_GPS irrigated`). Using the `e()` objects, store the R-squared and the number of observations from this regression in
   scalars named `rsq_yield` and `N_yield`. Using `display`, what are the R-squared value and number of observations?

2. Immediately after, run the same regression but with `harvest_value_USD` as the dependent variable instead of `yield_kg` This will overwrite `e(r2)` and `e(N)`. Store the R-squared from the second regression in a `local` macro named `rsq_harv`. Using `display`, what is the R-squared value?

---
