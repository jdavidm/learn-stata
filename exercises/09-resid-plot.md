---
layout: exercise
topic: Regression
title: Residual Plots
language: Stata
---

Using `eth_allrounds_final.dta`, make a residual-vs-fitted plot and check for heteroskedasticity.

1\. Run `reg yield_kg nitrogen_kg i.irr plot_area_GPS`.
2\. Generate predicted values (`predict yhat`) and residuals (`predict resid, residuals`).
3\. Create a scatter plot of `resid` against `yhat` with a horizontal line at zero (`yline(0)`).
4\. In comments: does the vertical spread of residuals change across the x-axis? What does this suggest about heteroskedasticity?

[Relevant lecture section]({{ site.baseurl }}/materials/09-std-errors/#quick-visual-check-iid-errors)
