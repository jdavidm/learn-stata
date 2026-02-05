---
layout: exercise
topic: Data Management
title: Create Variables
language: Stata
---

Using the World Bank's LSMS data, 

1\. Create a new variable called `tot_plots` that combines cultivated and fallow plots using `egen`. Label the new variable with "Total number of plots under household management". What is the mean number of plots owned by a household?

2\. Compute the mean total consumption in dollars (`meancons_USD`) for each consumption quintile using the `by()` option along with `egen`. Label the new variable with "Mean consumption per quntile (USD)". Using `tab`, what is the mean consumption for the highest and lowest quintile?

3\. Find the maximum household dietary diversity score (`hdds`) separately for households with and without electricity access. Call this new variable `max_hdds` and label it "Max HDDS by electricity access". (To get this, use `sum` and and the `bysort` prefix, which can be abbreviated `bys`. So, the line of code would start `bys hh_electricity_access: sum`).

---
