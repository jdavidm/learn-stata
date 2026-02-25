---
layout: exercise
topic: Problem Solving
title: Stata Help
language: Stata
---

In this exercise you will practice using Stata’s built-in help and documentation to solve a concrete coding problem. Using `plot_dataset.dta` you need to create a graph of mean yield per hectare by main crop, with bars sorted from lowest to highest mean yield. You are expected to use `help` or `search` inside Stata to figure out the exact syntax and options. You are **not** to use online sources or LLMs.

1\. Load the `plot_dataset.dta` and create and label a variable called `yield_USD` which is `yield_value_USD` divided by `plot_area_GPS`. Summarize the variable and below that command add a `***` comment that records the mean, standard deviation, min and max values.

2\. Use `help graph bar` (or another relevant help file) to answer questions like:
- How do I compute mean of a variable in a `graph bar` command?
- How do I put different groups on the x-axis?
- How can I sort the bars by the mean value?
- How can I add axis titles and an overall title?

Record key options you decide to use in comments as well as summaries of  what you learned from `help`. The exact graphing options are up to you, as long as they work and are informed by the help file.

---