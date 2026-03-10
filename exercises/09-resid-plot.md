---
layout: exercise
topic: Regression
title: Residual Plots
language: Stata
---

Using the **maize only** version of `eth_allrounds_final.dta` with per hectare inputs:

1\. Make a residual-vs-fitted plot and check for heteroskedasticity
- Run `reg yield_kg fert labor i.irr i.admin_1`.
- Use `predict yhat` to generate predicted values.
- Use `predict resid, residuals` to generate residuals.
- Use `twoway scatter` to create a scatter plot of `resid` against `yhat` with a horizontal line at zero (`yline(0)`).

2\. Does the vertical spread of residuals change across the x-axis? What does this suggest about heteroskedasticity?

---