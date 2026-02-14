---
layout: exercise
topic: Macros
title: Using Locals in Regressions
language: Stata
---


In this exercise you will use local macros to store variable lists and reuse
them in multiple regressions. For this week's assignment we will use `eth_allrounds_final.dta` so start by loading that data set.

Create a local macro named `controls` that contains three plot- or
   household-level control variables:

   - `crop_shock` (1 = experienced shock, 0 = no shock)
   - `irrigated` (1 = irrigated, 0 = not irrigated)
   - `hh_asset_index` (household asset index)


1. Use this macro to regress of `yield_kg` on `nitrogen_kg` and the controls stored in
     `controls` but only `if` the variable `crop_name` equals maize. What are the coefficients on each control that is statistically significant at the 90% level?

2. Now modify the macro definition so that the controls also include `female_manager` (1 = if the plot manager is female, 0 = if male). Re-run the regression **without changing the regression lines themselves**. What are the coefficients on each control that is statistically significant at the 90% level?

---
