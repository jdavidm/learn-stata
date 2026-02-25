---
layout: exercise
topic: Problem Solving
title: Challenge 7
language: Stata
---

For this challenge you are going to take the `plot_dataset` and create a household-level analysis dataset (one row per `hh_id_merge`). This is essentially the "goal problem" from this week, but here you will carry it to completion. In building the household-level data set, you are **not allowed to use `collapse`**.

1\. Plan first (problem decomposition in your `.do` file). Before writing real code, create a section where you plan the solution using headings and comments only.
   - Restate the problem in your own words
   - Identify inputs/outputs
   - Break into steps (load → construct variables → aggregate/tag → check uniqueness → analysis → graphs → save)

2\. Build the household dataset. 
   - Start by dropping all observations that **are not** maize
   - Instead of using `collapse`, use `egen` to compute household-level statistics for the following:
   	   - `hh_id_merge`
   	   - `mean_yield` = mean of plot-level `yield_USD`
   	   - `tot_labor` = sum of `total_labor_days`
   	   - `tot_fert` = sum of `nitrogen_kg`
   	   - `n_plots` = count of plots per household
   	   - `any_irrig` = 1 if household has any plot with `irrigated==1`, else 0
   - Label each variable
   - Tag one observation per household using the `tag` function
   - Use `keep if` to keep one row per household. How many observations are now in the data set?

3\. Check that following and include `***` comments recording the mean of each variable and the number of irrigated plots:
   - Confirm the dataset is one row per household: `isid hh_id_merge`
   - Summarize `mean_yield`, `tot_labor`, `tot_fert`, `n_plots`
   - Tabulate `any_irrig`

4\. Run the regressions `reg mean_yield tot_labor tot_fert any_irrig`. Add `***` comments that report:
   - The sign of each coefficient
   - One sentence interpreting the coefficient on `any_irrig`

5\. Create two graphs.
   - A `twoway` scatter plot of household mean yield (y-axis) vs total fertilizer (x-axis). Overlay a linear fit (`lfit`) to the data and provide informative axis titles and a legend.
   - Create a bar chart of mean household yield by irrigation status (`over`). Bars are for `any_irrig==0` and `any_irrig==1` and the y-axis should be the mean of `mean_yield`.

---
