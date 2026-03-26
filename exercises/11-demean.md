---
layout: exercise
topic: Fixed Effects
title: Demeaning the Data
language: Stata
---

Using `tenuredata.dta` (restricted to `rice == 1`):
- Use `egen` with `bysort panelid:` to calculate the household-specific mean for `yield`.
- Do the same to calculate the household-specific mean for fertilizer application `q_f_ha`.
- Generate demeaned versions of both variables by subtracting the household mean from the original value (e.g., `dm_yield` and `dm_fert`).
- Run a regression of the demeaned yield on the demeaned fertilizer, clustering standard errors by `panelid`.

What is the coefficient on `dm_fert` and how does it compare to the coefficient on `d_fert` from the previous exercise?
