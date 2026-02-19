---
layout: exercise
topic: Loops
title: Conditional Loops
language: Stata
---

In this final exercise you’ll use **programming** `if`, `foreach`, and `continue` to control what happens inside a loop based on sample size.

Goal: For a list of variables, automatically summarize and graph them, but **skip** variables that have too few non-missing observations. Start bv defining a local macro named `vars` with the following variables:
   - `yield_kg`
   - `harvest_value_USD`
   - `nitrogen_kg`
   - `totcons_USD`

1. Write a `foreach` and `varlist` to loop over `vars`. Inside the loop, for each variable `v`:
   - Run `` `qui sum `v', detail ``
   - Store the number of non-missing observations in a local `N` using `r(N)` (remember to use `=` so that the local equals the expression and not the literal text `r(N)`). Then, still within the loop, have Stata `display` the number of observations for each variable. How many observations are there for each variable?

---
