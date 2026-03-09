---
layout: exercise
topic: Regression
title: Challenge 9
language: Stata
---

This challenge uses `eth_allrounds_final.dta` to practice skills from all three regression lectures (regression, standard errors, concerns).

### Setup

1\. Load `eth_allrounds_final.dta` using your project paths.

### Part A: Regression and interpretation

2\. Run a multivariate regression of `yield_kg` on `nitrogen_kg`, `i.irr`, `plot_area_GPS`, and `i.region`.
3\. In comments, interpret the coefficient on `nitrogen_kg` using the phrase "holding fixed."
4\. Run `estat vif`. In comments, note any VIF values above 5 and explain whether collinearity is a concern in this specification.

### Part B: Predicted values and residuals

5\. Use `predict yhat` and `predict resid, residuals` to generate predicted values and residuals.
6\. Create a scatter plot of `resid` against `yhat` with `yline(0)`. In comments, describe whether you see evidence of heteroskedasticity.

### Part C: Standard errors

7\. Run the same regression three ways and record the standard error on `nitrogen_kg` each time:
   ```stata
   * default
   reg yield_kg nitrogen_kg i.irr plot_area_GPS i.region

   * robust
   reg yield_kg nitrogen_kg i.irr plot_area_GPS i.region, robust

   * clustered at household
   reg yield_kg nitrogen_kg i.irr plot_area_GPS i.region, vce(cluster hhid)
   ```
8\. In comments: how do the standard errors change across the three approaches? Which approach is most appropriate for these data and why?

### Part D: Getting fancier

9\. Run a regression with an interaction between nitrogen and irrigation:
   ```stata
   reg yield_kg c.nitrogen_kg##i.irr plot_area_GPS i.region, vce(cluster hhid)
   ```
10\. In comments, interpret the interaction: does the association between nitrogen and yield differ for irrigated vs rainfed plots?
