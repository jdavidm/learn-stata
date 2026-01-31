---
layout: exercise
topic: Data Analysis
title: Conditional Means (Discrete)
language: Stata
---

Using the `eth_allrounds_final` data, look at **mean outcomes by group** for a discrete variable.

1. Choose an outcome variable such as **harvest quantity** (`harvest_kg`) or **harvest value** (`harvest_value_USD`).

2. Compute mean outcomes by **plot ownership** (`plot_owned`) using a table and a graph:
   1. Use `tabstat` (or another summary command) to report mean, standard deviation, and number of observations by `plot_owned`.
   2. Make a `graph bar` of the **mean** outcome by `plot_owned`, adding clear axis titles and a figure title.

3. Repeat step 2 for a different grouping variable, such as **soil fertility** (`soil_fertility_index`) or **urban vs rural** (`urban`).

4. In a few sentences, compare the conditional means across groups. Which groups appear to have higher or lower outcomes?
