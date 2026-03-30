---
layout: exercise
topic: Event Studies
title: Manual Dummies
language: Stata
---

We'll use `panel_gis.dta` to run a manual event study on flooded domains by interacting the generalized time dummies with flood intensity.

### Tasks

1. First, make sure you created your `rel_time` from the prior exercise (where `adopt_year` was crossing `seed > 0.5`). 
2. We must "bin" observations that are too far in the past or future. Create a `rel_time_binned` variable that limits `rel_time` to $[-3, 5]$, mapping anything `<-3` to `-3` and anything `>5` to `5`.
3. Shift this range so all numbers are strictly positive (e.g., `gen event_factor = rel_time_binned + 10`). Look at `tab event_factor`! 7 corresponds to -3 years, and 9 corresponds to -1 year.
4. Run a Two-Way Fixed Effects regression of `evi_med` on the `event_factor` dummies using `ib9.event_factor` (to set $t=-1$ as the omitted baseline category). Also include `i.year` for time fixed effects. Cluster standard errors at the `district_id`.
5. Which relative year has the most statistically significant effect? Write your answer in comments.
