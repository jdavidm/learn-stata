---
layout: exercise
topic: Macros
title: Using Globals
language: Stata
---


In this exercise you will practice using a **global macro** to store a cutoff that is reused in several commands. Remember: in this course, locals are preferred almost always; this exercise is to help you understand how globals work and why they can be risky.

Define a global macro named `lg_cut` that stores the size (in hectares) above which you will consider a plot "large”. Use 1 hectare as the cutoff.

1. Create a new indicator variable `large_plot` that equals 1 if `plot_area_GPS` is **strictly greater** than `$lg_cut` and 0 otherwise. Label the variable as "= 1 if plot area > 1 ha". How many large plots are there in the data set?

2. Use `sum` and `if` to compute the mean `yield_kg` on large and non-large plots. What is mean yield in each group?

3. Download the following code files and place this in the folder where you keep all your code. That should be the path that `$code` points to.
- [00_main](https://jdavidm.github.io/learn-stata/code/00_main.do)
- [01_cleaning](https://jdavidm.github.io/learn-stata/code/01_cleaning.do)
- [02_revise](https://jdavidm.github.io/learn-stata/code/02_revise.do)
- [03_tables](https://jdavidm.github.io/learn-stata/code/03_tables.do)

Add 

---
