---
layout: exercise
topic: Regression
title: Collinearity and VIF
language: Stata
---

Using the **maize only** version of `eth_allrounds_final.dta` with per hectare inputs, diagnose collinearity with the Variance Inflation Factor.
- Run `reg yield_kg fert labor i.irr i.admin_1 seed_value_LCU seed_value_USD`
- Run `estat vif` immediately after the regression

1. Which variables have VIF values above 5? Above 10?
2. Why might the seed variables be collinear?
3. If VIF is high, does that mean the coefficients are biased, or just imprecise?

---