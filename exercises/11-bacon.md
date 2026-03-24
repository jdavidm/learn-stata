---
layout: exercise
topic: Two-Way Fixed Effects
title: 3 - Modern Estimators
language: Stata
---

Let's apply Callaway & Sant'Anna's modern robust estimator to `tenuredata.dta` using the `first_irrig` cohort variable we just built.

1. Install the `csdid` package if you haven't already: `net install csdid, from("https://raw.githubusercontent.com/friosavila/csdid_drdid/main/code/") replace`.
2. Run `csdid yield, ivar(panelid) time(year) gname(first_irrig) tr(irrig)`.
3. View the group-time average treatment effects.
4. Calculate the aggregated overall ATT by running `estat event`.
5. How does this compare to the standard Two-Way Fixed Effects estimate you found in Exercise 1?
