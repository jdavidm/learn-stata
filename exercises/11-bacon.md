---
layout: exercise
topic: Two-Way Fixed Effects
title: Modern TWFE Estimators
language: Stata
---

Let's apply Callaway & Sant'Anna's modern robust estimator to `tenuredata.dta` using the `first_irrig` cohort variable we just built.
- Run `csdid yield, ivar(panelid) time(year) gvar(first_irrig) tr(irrig)`.
- View the group-time average treatment effects.
- Calculate the aggregated overall ATT by running `estat event`.

How does this compare to the standard Two-Way Fixed Effects estimate you found in Exercise 5?
