---
layout: exercise
topic: Regression
title: Simple Regression
language: Stata
---

In this exercise, we will practice running a simple (single-variable) regression and interpreting its output.

### Tasks

1. Create a new do-file.
2. Load `eth_allrounds_final.dta` using your project paths.
3. Run a simple regression using the `regress` command with `yield_kg` as the dependent variable and `nitrogen_kg` as the sole independent variable.
4. Answer the following questions in comments in your do-file:
   - What is the estimated slope (coefficient) on `nitrogen_kg`? How do you interpret this number in terms of yield and nitrogen?
   - What is the value of the constant (`_cons`)? What does it represent in this context?
   - Is the coefficient on `nitrogen_kg` statistically significantly different from zero at the 5% level? (Hint: check the P>|t| column).
   - What is the R-squared value for this regression? What does it mean in terms of how much variation in yield is explained?
5. Now, run another simple regression of `yield_kg` on `plot_area_GPS`. In comments, record the slope and explain whether an increase in plot size is associated with higher or lower total yield.
