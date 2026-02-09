---
layout: exercise
topic: Loops
title: For Each
language: Stata
---


This exercise uses `foreach` to loop over **lists** of variables.

1. Use a `foreach` loop to summarize several continuous plot-level variables:

   - The variables should be:
     - `yield_kg`
     - `nitrogen_kg`
     - `seed_kg`
     - `total_labor_days`

   Example structure:

   ```stata
   foreach v of varlist yield_kg nitrogen_kg seed_kg total_labor_days {
       display "Summary for `v'"
       summarize `v'
   }
   ```

2. Now use `foreach` to explore a set of shock indicator variables:

   - `crop_shock`
   - `pests_shock`
   - `rain_shock`
   - `drought_shock`
   - `flood_shock`

   For each variable, run a one-way tabulation:

   ```stata
   foreach shock in crop_shock pests_shock rain_shock drought_shock flood_shock {
       display "------------------------"
       display "Shock variable: `shock'"
       tab `shock'
   }
   ```

3. Modify the loop in (2) so that:

   - It also calculates the **share of plots** that experienced the shock
     (i.e., where the shock variable == 1).
   - For each shock, store that share in a local macro named
     `share_`shock'` and display a sentence like:

     ```text
     About 23.5% of plots experienced a pests_shock.
     ```

   Hint: you can use `summarize` and `r(mean)`, since the mean of a 0/1
   variable is the share of 1s.

---
