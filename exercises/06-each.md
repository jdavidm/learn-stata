---
layout: exercise
topic: Loops
title: For Each
language: Stata
---

This exercise uses `foreach` to loop over **lists** of variables.

1. Use `foreach` to run a one-way tabulation (`tab`) for the following shock indicator variables:
   - `crop_shock`
   - `pests_shock`
   - `rain_shock`
   - `drought_shock`
   - `flood_shock`
  How many plots experienced each type of shock?

2. Modify the loop so that it also calculates the **share of plots** that experienced the shock (i.e., where the shock variable == 1). For each shock, use `sum`, `if`, and `r(mean)` to store that share in a local macro named `` `share_`shock'` `` and display the result as:

     ```stata
     * Print as percent with one decimal place
		    display			"About " %4.1f (100*`share_`shock'') "% of plots experienced a `shock'."
     ```
  What share of plots experienced each type of shock?

---
