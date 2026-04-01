---
layout: exercise
topic: Event Studies
title: Event Study Regression
language: Stata
---

In this exercise, you'll create event time indicators from scratch and then run an event study regression using `panel_gis.dta`.

- Working with your `panel_gis.dta` data, define an "event time" for when a district first crossed an arbitrary cumulative seed distribution threshold. Generate `first_adopt = year` if `seed > 0.5`. 
- Push this year down to all observations: `bysort district_id: egen adopt_year = min(first_adopt)`. Replace with `0` for districts that never adopt heavily.
- Create a relative event time variable: `gen rel_time = year - adopt_year if adopt_year > 0`.
- Now "bin" observations that are too far in the past or future. Create a `rel_time_binned` variable that limits `rel_time` to $[-3, 5]$, mapping anything `<-3` to `-3` and anything `>5` to `5`.
- Shift this range so all numbers are strictly positive (e.g., `gen event_factor = rel_time_binned + 10`). Look at `tab event_factor` — 7 corresponds to -3 years, and 9 corresponds to -1 year.
- Run a Two-Way Fixed Effects regression of `evi_med` on the `event_factor` dummies using `ib9.event_factor` (to set $t=-1$ as the omitted baseline category). Also include `i.year` for time fixed effects. Cluster standard errors at the `district_id`.

1. What does a `rel_time` of `-3` mean intuitively in this context?
2. Which relative year has the most statistically significant effect?
