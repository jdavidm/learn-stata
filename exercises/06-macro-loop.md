---
layout: exercise
topic: Loops
title: Combining Macros and Loops
language: Stata
---

Here you’ll combine **local macros** and **foreach** loops to create new
variables and run multiple regressions.

1. Create a local macro named `logvars` that contains three nonnegative
   variables that you expect to be skewed:

   - `yield_kg`
   - `harvest_value_USD`
   - `totcons_USD`

   ```stata
   local logvars yield_kg harvest_value_USD totcons_USD
   ```

2. Use a `foreach` loop over `logvars` to create log-transformed versions of
   each variable:

   - For each variable `v` in `logvars`, generate `ln_`v' = ln(`v')` **only**
     where `v > 0` (log of nonpositive values is undefined).
   - Label each new variable `"log of v"`.

   Example structure:

   ```stata
   foreach v of local logvars {
       gen ln_`v' = ln(`v') if `v' > 0
       label var ln_`v' "log of `v'"
   }
   ```

3. Now define two more local macros:

   - `local yvars yield_kg harvest_kg`
   - `local controls plot_area_GPS irrigated nitrogen_kg female_manager`

4. Use a nested loop structure to run regressions of each outcome in `yvars`
   on the same set of controls:

   - For each outcome variable `y` in `yvars`, run:

     ```stata
     regress `y' `controls'
     ```

   - Before each regression, display a line indicating which outcome you’re
     working with.

   Example:

   ```stata
   foreach y of local yvars {
       display "========================"
       display "Regression with outcome: `y'"
       regress `y' `controls'
   }
   ```

5. (Optional) Modify the loop so that for each regression you also store the
   R-squared in a scalar named `rsq_`y'` (e.g., `rsq_yield_kg`,
   `rsq_harvest_kg`).


---
