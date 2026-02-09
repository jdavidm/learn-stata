---
layout: exercise
topic: Macros
title: Using Locals in Regressions
language: Stata
---


In this exercise you will use **local macros** to store variable lists and reuse
them in multiple regressions.

1. Load `eth_allrounds_final.dta` if it is not already in memory.

2. Create a local macro named `controls` that contains **three** plot- or
   household-level control variables:

   - `plot_area_GPS` (plot size)
   - `irrigated` (1 = irrigated, 0 = not irrigated)
   - `hh_asset_index` (household asset index)

   ```stata
   local controls plot_area_GPS irrigated hh_asset_index
   ```

3. Use this macro in a regression of plot-level yield on fertilizer:

   - Regress `yield_kg` on `nitrogen_kg` and the controls stored in
     `controls`.

   Your command should look something like:

   ```stata
   regress yield_kg nitrogen_kg `controls'
   ```

4. Run a second regression that uses *the same* control set but a different
   outcome variable:

   - Regress `harvest_value_USD` on `nitrogen_kg` and the same controls.

5. Now modify the macro definition so that the controls also include
   `female_manager` (1 if the plot manager is female):

   ```stata
   local controls plot_area_GPS irrigated hh_asset_index female_manager
   ```

   Re-run both regressions from (3) and (4) **without changing the regression
   lines themselves**.

6. Add a short comment in your do-file (not for grading, just for you) that
   explains why it is convenient to change the controls in one place instead of
   editing every regression.
---
