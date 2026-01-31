---
layout: exercise
topic: Expressions & Variables
title: Tabulate Data
language: Stata
---

Load the Stata system dataset `nlsw88.dta`:

```stata
* load national longitudinal survey of young women
    sysuse              nlsw88, clear
```

1\. Use `tab` to produce a frequency table for the variable `race`.
   1. What are the number of observations in each race category?
   2. Which race category is the mode (most common)?
   3. What is the percentage of women in each category?

2\. Use `tab` again, this time on the variable `union`, but include missing values in the table using the `missing` option:
   1. How many women are in a union, how many are not, and how many are missing?
   2. What percent of the sample has missing values for `union`?

---
