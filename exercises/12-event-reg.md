---
layout: exercise
topic: Event Studies
title: Event Study Regression
language: Stata
---

In this exercise, you'll build an event study from scratch using `panel_gis.dta`. The goal is to trace out the dynamic effect of STRV seed adoption on crop yields over time, using the interaction-weighted estimator from Sun and Abraham (2021).

- Generate a cohort variable that records the first year each district received STRV seed. Create a temporary variable equal to `year` when `seed > 0`, then use `bysort` and `egen min()` to push the earliest adoption year to all observations within each district. Drop the temporary variable.
- Create a relative time variable `ry` equal to `year` minus the cohort variable. Bin any values greater than 10 to 10.
- Identify the control cohort. Generate an indicator for districts that never received seed and a separate indicator for districts that received seed last (in 2019).
- Generate lead dummies using a `forvalues` loop counting down from 16 to 2. Name them `g_k` (e.g., `g_16`, `g_15`, ..., `g_2`), where each equals 1 when `ry == -k`.
- Generate lag dummies using a `forvalues` loop from 0 to 10. Name them `gk` (e.g., `g0`, `g1`, ..., `g10`), where each equals 1 when `ry == k`.
- Add `eventstudyinteract`, `avar`, and `reghdfe` to the package loop in your `project.do` file. Change `$pack` to 1, re-run `project.do`, then change back to 0.
- Run the event study using `eventstudyinteract`. Specify `evi_med` as the outcome, include all lead and lag dummies (`g_* g0-g10`), set the cohort variable with `cohort()`, identify the control cohort with `control_cohort()`, include `fld_cuml` as a covariate with `covariates()`, absorb district and year fixed effects with `absorb(i.district_id i.year)`, and cluster standard errors at the `district_id` level.
- Export the results to a LaTeX table for your Overleaf document using the code block below.

```stata
* export results to latex
   esttab          using "$answ/12-event-reg.tex", replace ///
                       b(4) se(4) ///
                       star(* 0.10 ** 0.05 *** 0.01) ///
                       noobs booktabs nonum nomtitle ///
                       eqlabels(none) collabels(none) ///
                       nobaselevels nogaps fragment label ///
                       title("Event Study: STRV Seed Adoption")
```

1. What does a `ry` of $-3$ mean intuitively in this context?
2. Looking at the lead coefficients, is there evidence of differential pre-trends before seed adoption?
