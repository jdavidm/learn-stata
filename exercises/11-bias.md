---
layout: exercise
topic: Two-Way Fixed Effects
title: Staggered Adoption Cohorts
language: Stata
---

Modern TWFE estimators (like `csdid`) require that we identify exactly *when* an individual first received a treatment.

Using `tenuredata.dta` (`keep if rice == 1`), we want to evaluate the effect of irrigation (`irrig`) on yield. However, parcels adopt irrigation at different times. We need to create a variable that stores the *first year* a parcel ever had `irrig == 1`.
- Sort the data by `panelid` and `year`.
- Create a variable `first_irrig` that equals `year` if `irrig == 1`, and missing otherwise.
- Use `bysort panelid:` to replace `first_irrig` with the minimum value of `first_irrig` for that parcel across all years (`egen ... = min()`).
- For parcels that *never* received irrigation, replace `first_irrig` = 0.

You now have the exact cohort group variable needed for modern TWFE estimators. Run a TWFE regression using either `xtreg` with year dummies or `reghdfe`. What is the coefficient on irrigation?
