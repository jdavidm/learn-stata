---
title: Distributions Exercises
layout: page
element: exercises
language: Stata
---

These exercises use the Stata system dataset `nlsw88.dta`. Start each exercise by making sure it is loaded:

```stata
sysuse nlsw88, clear
```

## Exercise 1 - Tabulating Data

1. **One-way tabulation**

   - Use `tab` to produce a frequency table for the variable `race`.
   - Write down:
     - The number of observations in each race category.
     - The percentage of women in each category.
     - Which race category is the mode (most common).

2. **Using a `tab` option**

   - Use `tab` again, this time on the variable `collgrad` (indicator for college graduate), but include missing values in the table using the `missing` option:
     ```stata
     tab collgrad, missing
     ```
   - Answer:
     - How many observations are `Yes`, how many are `No`, and how many are missing?
     - What percent of the sample has missing values for `collgrad`?

## Exercise 2 - Summarizing Data with `summarize`

1. **Basic summary**

   - Use `sum` to summarize the variable `wage`:
     ```stata
     sum wage
     ```
   - Write down:
     - The number of observations.
     - The mean wage.
     - The standard deviation.
     - The minimum and maximum values.

2. **More detail with `detail`**

   - Use the `detail` option with `sum`:
     ```stata
     sum wage, detail
     ```
   - Record:
     - The median (50th percentile) of wage.
     - The 25th and 75th percentiles of wage.

3. **Conditional summary**

   - Restrict the summary to women who are college graduates:
     ```stata
     sum wage if collgrad == 1
     ```
   - Compare this to the overall summary in part (1):
     - Is the mean wage for college graduates higher or lower than the overall mean?
     - Is the standard deviation for college graduates larger or smaller than in the full sample?

## Exercise 3 - Using Stored `r()` Results

1. **Range of wage using `r()`**

   - Run:
     ```stata
     sum wage
     ```
   - Then use the stored results to calculate the range of wage:
     ```stata
     display r(max) - r(min)
     ```
   - Write down the range. How does it relate to the minimum and maximum values you saw in the `sum` output?

2. **Interquartile range of wage using `r()`**

   - Run:
     ```stata
     sum wage, detail
     ```
   - Then use the stored percentiles to calculate the interquartile range (IQR) of wage:
     ```stata
     display r(p75) - r(p25)
     ```
   - Write down the IQR. How does it compare to the full range you calculated in part (1)?
