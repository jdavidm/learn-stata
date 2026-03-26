---
layout: exercise
topic: Two-Way Fixed Effects
title: Staggered Adoption Cohorts
language: Stata
---

Using `mm.dta`, we want to evaluate the effect of improved chickpea adoption (`icp`) on yield. However, parcels adopt improved chickpeas at different times. We need to create a variable that stores the *first year* a parcel ever had `icp == 1`.
- Sort the data by `qnno` and `year`.
- Create a variable `first_icp` that equals `year` if `icp == 1`, and missing otherwise.
- Use `bysort qnno:` to replace `first_icp` with the minimum value of `first_icp` for that parcel across all years (`egen ... = min()`).
- For parcels that *never* adopted improved chickpeas, replace `first_icp` = 0.

You now have the exact cohort group variable needed for modern TWFE estimators. Run a TWFE regression using either `xtreg` with year dummies or `reghdfe` and use `eststo` to save the result. What is the coefficient on improved chickpea adoption?
