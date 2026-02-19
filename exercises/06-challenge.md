---
layout: exercise
topic: Loops
title: Challenge 6
language: Stata
---
### Example: automated summaries and graphs

Let’s put everything together in something closer to real work.

Goal: For a list of variables, produce:

- A table of summary statistics  
- A histogram saved to disk for each variable  

```stata
sysuse auto, clear

* 1. variables to summarize
    local vars price mpg weight length

* 2. loop over them
    foreach v of local vars {

        * summarize with detail and save N
            quietly summarize `v', detail
            local N = r(N)

        * only graph if we have at least 50 observations
            if `N' < 50 {
                display as txt "Skipping `v' (only `N' obs)"
                continue
            }

        * print a header and key stats
            display "-------------------------"
            display "Variable: `v'"
            display "Mean: "      %9.3f r(mean)
            display "Median: "    %9.3f r(p50)
            display "Std. dev.: " %9.3f r(sd)

        * histogram and save graph
            histogram `v', ///
                title("Distribution of `v'") ///
                name(hist_`v', replace)

            graph export "hist_`v'.png", replace
    }
```

Things to notice:

- We use a **local macro** `vars` as the source list for a `foreach` loop.  
- Inside the loop we rely on **stored results** from `summarize`.  
- We use a programming `if` to **skip** variables with too few observations (`continue`).  
- We reuse the macro `\`v'` in graph titles and filenames, avoiding copy-paste errors.

This is the kind of pattern that will be extremely helpful later in the course and in your own research.
Putting loops and macros together: cleaning variables

4. (Optional challenge) Use a `forvalues` loop over planting months:

   - Use `tab planting_month` to see which months are present.
   - Loop over months 1 to 12.
   - For each month, count how many plots have that planting month and display
     a line like:

     ```text
     Month 3: 452 plots
     ```

   using `count if planting_month == ...` and `r(N)`.

   (Optional) Modify the loop so that for each regression you also store the
   R-squared in a scalar named `rsq_`y'` (e.g., `rsq_yield_kg`,
   `rsq_harvest_kg`).
