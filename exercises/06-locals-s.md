---
layout: exercise
topic: Macros
title: Using Locals to Store Results
language: Stata
---

Using `eth_allrounds_final.dta`,

1. Summarize `yield_kg` and store the mean and standard deviation from this command in locals named
   `mean_yield` and `sd_yield` using `r(mean)` and `r(sd)`. Use these locals to create a standardized yield variable called `yield_std`. Recall from your stats classes, to standardize a variable you subtract the mean value from the variable and then divide the difference by the standard deviation. What is the mean and standard deviation of `yield_std`?

2. Use the `display` command and your locals to print the following sentence "Mean yield on Ethiopian plots is `` `mean_yield' `` kg with standard deviation of `` `sd_yield' `` kg."

---
