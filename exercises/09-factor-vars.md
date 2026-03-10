---
layout: exercise
topic: Regression
title: Factor Variables and Interactions
language: Stata
---

Using the **maize only** version of `eth_allrounds_final.dta` with per hectare inputs:

1. Run a regression of `yield_kg` on `fert` and `labor`, adding regional fixed effects with `i.admin_1`. Which region is the omitted reference category?
2. Run a regression with an interaction between fertilizer (`c.fert`) and irrigation (`i.irr`). What is the coefficient on the interaction term? What does the interaction coefficient mean?
3. Fit a quadratic in fertilizer. What does the sign of the squared term tell you about diminishing returns?

---
