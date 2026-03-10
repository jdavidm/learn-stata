---
layout: exercise
topic: Regression
title: Simple Regression
language: Stata
---

For all the exercises this week we are going to use `eth_allrounds_final.dta`. Before we start, after loading the data:
- Drop all observations that are not **maize**
- Generate a variable called `fert` that measures nitrogen fertilizer in kg per hectare (`nitrogen_kg / plot_area_GPS`). Label the variable.
- Generate a variable called `labor` that measures total labor in days per hectare (`total_labor_days / plot_area_GPS`). Label the variable.

This **maize only** data set with per hectare inputs will be the one we use for all the exercises this week. It will make our yield function regressions more realistic.

1. Create a scatter plot of `yield_kg` against `fert` with a fitted line (`lfit`)
2. Run `reg yield_kg fert`
   - What is the slope on `fert` and how do you interpret it?
   - Is it statistically significant at the 5% level?
   - What is the R-squared and what does it mean?

---