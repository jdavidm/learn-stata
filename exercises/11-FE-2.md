---
layout: exercise
topic: Fixed Effects
title: 2 - Demeaning the Data
language: Stata
---

Using `tenuredata.dta` (restricted to `rice == 1`):

1. Use `egen` with `bysort panelid:` to calculate the household-specific mean for `yield`.
2. Do the same to calculate the household-specific mean for fertilizer application `q_f_ha`.
3. Generate demeaned versions of both variables by subtracting the household mean from the original value (e.g., `dm_yield` and `dm_fert`).
4. Run a regression of the demeaned yield on the demeaned fertilizer, clustering standard errors by `panelid`.
5. Note how the coefficient on `dm_fert` compares to the coefficient on `d_fert` from the previous exercise.
