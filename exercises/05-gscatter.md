---
layout: exercise
topic: Graphing
title: Grouped Scatter Plots
language: Stata
---


Using the `eth_allrounds_final` data,

1. Make a scatter plot of **harvest value** (`harvest_value_USD`) versus **farm size** (`farm_size`) **by irrigation status** (`irrigated`):

   - First, draw a **single** scatter plot using `twoway`, with different colors for irrigated and rainfed plots on the same axes.
   - Second, use the `by(irrigated)` option on `scatter` to make separate panels for irrigated and rainfed plots.

2. For each approach (overlay vs `by()` panels), answer:
   - Which makes it easier to compare irrigated and rainfed plots?  
   - Which makes it easier to see the overall relationship between farm size and harvest value?

3. Repeat part 1 using **urban vs rural** plots (`urban`) instead of irrigation status.

---
