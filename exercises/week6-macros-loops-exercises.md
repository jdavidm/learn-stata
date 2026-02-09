---
layout: exercise
topic: Macros and Loops
title: Week 6 – Macros and Loops with `eth_allrounds_final`
language: Stata
---

All exercises in this file use the Ethiopia LSMS-ISA plot-level dataset  
`eth_allrounds_final.dta`.

You can assume your `project.do` has already set up paths. If not, you can load
the data directly with something like:

```stata
    use "path/to/eth_allrounds_final.dta", clear
```

---

## Exercise 1 – Using locals in regressions

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

## Exercise 2 – Using locals to store results

In this exercise you will **capture results** from `summarize` into local
macros and reuse them.

1. Using `eth_allrounds_final.dta`, summarize `yield_kg`:

   ```stata
   summarize yield_kg
   ```

2. Store the mean and standard deviation from this command in locals named
   `mean_yield` and `sd_yield` using `r(mean)` and `r(sd)`:

   ```stata
   local mean_yield = r(mean)
   local sd_yield   = r(sd)
   ```

3. Use these locals to create a **standardized yield** variable:

   ```stata
   gen yield_kg_std = (yield_kg - `mean_yield') / `sd_yield'
   ```

4. Check that the standardized variable behaves as expected by summarizing it:

   ```stata
   summarize yield_kg_std
   ```

   - Does the mean look close to 0?
   - Does the standard deviation look close to 1?

5. Use a `display` command and your locals to print a short, readable sentence
   to the Results window. For example (modify the text as you like):

   ```stata
   display "Mean yield on Ethiopian plots is `mean_yield' kg with sd `sd_yield' kg."
   ```

---

## Exercise 3 – Using globals (carefully)

In this exercise you will practice using a **global macro** to store a cutoff
that is reused in several commands. Remember: in this course, locals are
preferred almost always; this exercise is to help you understand how globals
work and why they can be risky.

1. Define a global macro named `largeplot_cutoff` that stores the size (in
   hectares) above which you will consider a plot “large”. Use 1 hectare as the
   cutoff:

   ```stata
   global largeplot_cutoff = 1
   ```

2. Create a new indicator variable `large_plot` that equals 1 if
   `plot_area_GPS` is **strictly greater** than `$largeplot_cutoff` and 0
   otherwise.

   ```stata
   gen large_plot = plot_area_GPS > $largeplot_cutoff
   label var large_plot "1 if plot area > $largeplot_cutoff ha"
   ```

3. Compare yields on large vs smaller plots:

   - Use `tabstat` or `summarize` with `if` to compute the mean `yield_kg` for
     `large_plot == 1` and for `large_plot == 0`.

4. Now **change the definition** of the global cutoff to 0.5 hectares:

   ```stata
   global largeplot_cutoff = 0.5
   ```

   Recreate the variable `large_plot` (you can `drop large_plot` first) using
   the new cutoff, and recompute the mean yields for large vs non-large plots.

5. In a comment in your do-file, briefly note:

   - What changed when you changed the global macro?
   - Why could using many globals like this make debugging harder in a large
     project?

---

## Exercise 4 – Storing results as numbers (scalars)

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

## Exercise 5 – Forvalues: looping over waves

In this exercise you will use `forvalues` to loop over survey waves and compute
summary statistics.

1. Tabulate the `wave` variable to see how many survey waves you have and what
   their codes are:

   ```stata
   tab wave
   ```

2. Use a `forvalues` loop to summarize `yield_kg` separately for each wave.
   Your code should:

   - Loop over all integer values of `wave` observed in the data (for example,
     `1/3` if there are 3 waves).
   - For each wave:
     - Display a header line like `"Wave 1"`.
     - Run `summarize yield_kg if wave == ...`.

   Example structure (modify the range to match your data):

   ```stata
   forvalues w = 1/3 {
       display "------------------------"
       display "Summary for wave `w'"
       summarize yield_kg if wave == `w'
   }
   ```

3. Extend your loop so that for each wave it also summarizes `nitrogen_kg`:

   ```stata
   forvalues w = 1/3 {
       display "------------------------"
       display "Summary for wave `w'"
       summarize yield_kg    if wave == `w'
       summarize nitrogen_kg if wave == `w'
   }
   ```

4. (Optional challenge) Use a `forvalues` loop over planting months:

   - Use `tab planting_month` to see which months are present.
   - Loop over months 1 to 12.
   - For each month, count how many plots have that planting month and display
     a line like:

     ```text
     Month 3: 452 plots
     ```

   using `count if planting_month == ...` and `r(N)`.

---

## Exercise 6 – Foreach: looping over variables and shocks

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

## Exercise 7 – Combining macros and loops

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

## Exercise 8 – Conditional loops

In this final exercise you’ll use **programming `if`**, `foreach`, and
`continue` to control what happens inside a loop based on sample size.

Goal: For a list of variables, automatically summarize and graph them, but
**skip** variables that have too few non-missing observations.

1. Define a local macro named `vars` with the following variables:

   - `yield_kg`
   - `harvest_value_USD`
   - `nitrogen_kg`
   - `totcons_USD`

   ```stata
   local vars yield_kg harvest_value_USD nitrogen_kg totcons_USD
   ```

2. Write a `foreach` loop over `vars`. Inside the loop, for each variable `v`:

   - Run `quietly summarize `v', detail`.
   - Store the number of non-missing observations in a local `N`:

     ```stata
     local N = r(N)
     ```

3. Add a **programming `if`** statement that:

   - If `N < 1000`, displays a message like:

     ```stata
     display as txt "Skipping `v' (only `N' non-missing obs)"
     ```

     and uses `continue` to move on to the next variable **without** graphing.

   - Otherwise:
     - Displays the variable name and some key statistics (mean, median, sd)
       using `display` and `r(mean)`, `r(p50)`, `r(sd)`.
     - Creates a histogram of `v` with a clear title and axis labels.
     - Saves the graph with a name that depends on the variable, e.g.
       `hist_yield_kg.png`.

   Example structure (fill in the pieces):

   ```stata
   foreach v of local vars {

       quietly summarize `v', detail
       local N = r(N)

       if `N' < 1000 {
           display as txt "Skipping `v' (only `N' obs)"
           continue
       }

       display "------------------------"
       display "Variable: `v'"
       display "Mean: "      %9.3f r(mean)
       display "Median: "    %9.3f r(p50)
       display "Std. dev.: " %9.3f r(sd)

       histogram `v', ///
           title("Distribution of `v'") ///
           xtitle("`v'") ///
           name(hist_`v', replace)

       graph export "hist_`v'.png", replace
   }
   ```

4. (Optional challenge) Modify the loop so that if the **mean** of the
   variable is less than 0 (for any variable where that makes sense), you print
   a warning message using `display as error` before the histogram.

---
