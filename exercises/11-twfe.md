---
layout: exercise
topic: Two-Way Fixed Effects
title: Adding Time Fixed Effects
language: Stata
---

Using `tenuredata.dta` (restricted to `rice == 1`), let's extend our models from the One-Way FE lecture.
- Ensure your data is `xtset panelid year`.
- Run a standard Two-Way Fixed Effects model. Regress `yield` on fertilizer (`q_f_ha`) using `xtreg, fe`, but this time include time fixed effects by adding `i.year` to your list of covariates. Note: don't forget to cluster your standard errors by `panelid`!
- Now estimate the exact same model using the `reghdfe` command. Specify `absorb(panelid year)` to absorb both individual and time fixed effects. Remember to cluster standard errors.

1. Compare the estimates between the two models. Are they identical? What is the coefficient on `q_f_ha1`?
2. Compare that coefficient to the coefficient you got without `i.year`. Did aggregate time shocks bias the one-way fixed effect estimator?
