---
layout: exercise
topic: Data Analysis
title: Conditional Distributions
language: Stata
---

Using the `eth_allrounds_final` data, explore how the distribution of an input varies across groups.

Start by using `sum, detail` to summarize `total_hired_labor_days` **separately** for:
   - Plots with improved seed (`improved == 1`), and  
   - Plots without improved seed (`improved == 0`).

1. Is the average number of hired labor days greater when a plot is planted with improved seed or without improved seed?

2. Draw two kernel density plots, one for each group, on the same graph using `if` conditions. Is this graph informative? Why or why not?


---
