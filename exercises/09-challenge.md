---
layout: exercise
topic: Regression
title: Challenge 9
language: Stata
---

This challenge uses the **maize only** version of `eth_allrounds_final.dta` with per hectare inputs to practice skills from all three regression lectures (regression, standard errors, concerns). 
- Start by creating a variable called `seed` that measures the total seed value for each plot in USD per hectare
- Now run a multivariate regression of `yield_kg` on `fert`, `labor`, `seed`, `i.irr`, `i.intercropped`, `i.crop_shock`, `i.admin_1`, and `i.wave`

1\. Interpret the coefficient on `labor` using the phrase "holding fixed"
2\. Run `estat vif`. Which variables, if any, have VIF values above 5? Explain whether collinearity is a concern in this specification
3\. Use predict yhat and predict resid, residuals to generate predicted values and residuals
   - Create a scatter plot of `resid` against `yhat` with `yline(0)`
   - Is there evidence of heteroskedasticity?
4\. Run the same regression three ways (normal s.e., robust s.e., and s.e. clustered at household)
   - What are the standard errors on `fert` each time?
   - Which approach is most appropriate for these data and why?
5\. Run a regression with an interaction between `fert` and `labor`. How do you interpret the coefficient on `fert`, `labor`, and `c.fert##c.labor`?
