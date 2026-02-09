---
layout: exercise
topic: Loops
title: Conditional Loops
language: Stata
---

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
