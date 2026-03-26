---
layout: exercise
topic: Two-Way Fixed Effects
title: Adding Time Fixed Effects
language: Stata
---

Using `tenuredata.dta`, let's extend our models from the One-Way FE lecture.
- Ensure your data is `xtset panelid`.
- Run a standard One-Way Fixed Effects model. Regress `yield` on fertilizer (`q_f_ha`) using `xtreg, fe`.  Cluster standard errors at the `panelid` level.
- Run a standard Two-Way Fixed Effects model. Regress `yield` on fertilizer (`q_f_ha`) using `xtreg, fe`, but this time include time fixed effects by adding `i.year` to your list of covariates.  Cluster standard errors at the `panelid` level.
- Now estimate the exact same model using the `reghdfe` command. Specify `absorb(panelid year)` to absorb both individual and time fixed effects.  Cluster standard errors at the `panelid` level.

1. Use `eststo` to save each of the three results. Then adapt the table structure from the Exercise 1 to create a table of results heading columns with `OWFE`, `TWFE`, and `reghdfe`.
2. How do the estimates on `q_f_ha` compare across the three models? Did aggregate time shocks bias the one-way fixed effect estimator?
