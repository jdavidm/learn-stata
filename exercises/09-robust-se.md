---
layout: exercise
topic: Regression
title: Robust Standard Errors
language: Stata
---

Using the **maize only** version of `eth_allrounds_final.dta` with per hectare inputs, compare default and robust standard errors.
- Run `reg yield_kg fert labor i.irr i.admin_1` (default standard errors).
- Run the same regression with `, robust` appended.

1. Did the coefficients change?
2. How did the standard error on `fert` change?
3. Did the p-value on `fert` change in a way that would affect your conclusions?

---