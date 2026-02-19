---
layout: exercise
topic: Loops
title: Combining Macros and Loops
language: Stata
---

Here you’ll combine `local` macros and `foreach` loops along with `varlist` to create new variables and run multiple regressions.

1. Create a local macro named `logvars` that contains three nonnegative variables that you expect to be skewed:
   - `yield_kg`
   - `harvest_value_USD`
   - `totcons_USD`

Use a `foreach` loop over the variables in `logvars` to create log-transformed versions of each variable:
   - For each variable `v` in `logvars`, generate `ln_`v' = ln(`v')`
   - Label each new variable `"log of v"`
   - Use `sum` to calculate the mean for each logged variable

What is the mean value of each variable?

2. Now define two more local macros:
   - `local yvars ln_*`
   - `local controls plot_area_GPS irrigated nitrogen_kg female_manager`

Use a `foreach` loop to run regressions of each outcome in `yvars` on the **same** set of controls. In each regression, what controls are **not** significant?

---
