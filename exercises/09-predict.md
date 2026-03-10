---
layout: exercise
topic: Regression
title: Predicting Values
language: Stata
---

Using the **maize only** version of `eth_allrounds_final.dta` with per hectare inputs compute and graph predicted values from a regression.
- Run `reg yield_kg fert labor i.irr i.admin_1`
- Use `predict yhat` to generate predicted values
- Use `twoway scatter` to create the scatter plot
- Use `function x = y` to add the 45° reference line

---