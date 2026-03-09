---
layout: exercise
topic: Regression
title: Predicting Values
language: Stata
---

Using `eth_allrounds_final.dta`, compute and graph predicted values from a regression.

1\. Run `reg yield_kg nitrogen_kg i.irr plot_area_GPS`.
2\. Use `predict yhat` to generate predicted values.
3\. Use `predict resid, residuals` to generate residuals.
4\. Create a scatter plot of actual yield (`yield_kg`) against predicted yield (`yhat`) and add a 45° reference line. In comments, describe what the scatter tells you about model fit.

[Relevant lecture section]({{ site.baseurl }}/materials/09-std-errors/#predicting-values-and-graphing-them)
