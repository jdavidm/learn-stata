---
layout: exercise
topic: Fixed Effects
title: Demeaning the Data
language: Stata
---

Using `mm.dta`:
- Use `egen` with `bysort qnno:` to calculate the household-specific mean for `yield`.
- Do the same to calculate the household-specific mean for fertilizer cost `totfertcostha`.
- Generate demeaned versions of both variables by subtracting the household mean from the original value (e.g., `dm_yield` and `dm_fert`).
- Run a regression of the demeaned yield on the demeaned fertilizer, clustering standard errors by `qnno`.


1\. Use `eststo` to save the demeaned results. Then adapt the table structure from the previous exercise to create a table of results with a third column headed `Demean`.
2\. What is the coefficient on fertilizer cost in the demeaned regression and how does it compare to the coefficients you calculated in Exercises 1?
