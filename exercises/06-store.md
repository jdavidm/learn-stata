---
layout: exercise
topic: Macros
title: Storing Results as Numbers
language: Stata
---


Here you will practice storing regression output in **scalars** and using them
later.

1. Run a regression of yield on fertilizer and plot characteristics:

   ```stata
   regress yield_kg nitrogen_kg plot_area_GPS irrigated
   ```

2. Store the R-squared and the number of observations from this regression in
   scalars named `rsq_yield` and `N_yield`:

   ```stata
   scalar rsq_yield = e(r2)
   scalar N_yield   = e(N)
   ```

3. Immediately after, run a *different* regression, for example:

   ```stata
   regress harvest_value_USD nitrogen_kg plot_area_GPS irrigated
   ```

   (This will overwrite `e(r2)` and `e(N)`.)

4. Use `display` to show the stored scalar values from the **first** regression:

   ```stata
   display "R-squared from yield regression: " rsq_yield
   display "N from yield regression: " N_yield
   ```

   Confirm that these values correspond to the first regression (not the
   second).

5. Now store the R-squared from the second regression in a **local macro**
   named `rsq_harv`:

   ```stata
   local rsq_harv = e(r2)
   display "R-squared from harvest regression (local): `rsq_harv'"
   ```

   In a short comment in your do-file, note one reason you might choose a
   scalar vs a local for storing numeric results.

---
