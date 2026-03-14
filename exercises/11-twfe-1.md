---
layout: exercise
topic: Two-Way Fixed Effects
title: 1 - Adding Time Fixed Effects
language: Stata
---

Using `tenuredata.dta` (restricted to `rice == 1`), let's extend our models from the One-Way FE lecture.

1. Ensure your data is `xtset panelid year`.
2. Run a standard Two-Way Fixed Effects model. Regress `yield` on fertilizer (`q_f_ha`) using `xtreg, fe`, but this time include time fixed effects by adding `i.year` to your list of covariates. Note: don't forget to cluster your standard errors by `panelid`!
3. Compare the coefficient on `q_f_ha` to the coefficient you got without `i.year`. Did aggregate time shocks bias the one-way fixed effect estimator?
