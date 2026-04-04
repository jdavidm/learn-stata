---
layout: exercise
topic: Event Studies
title: Event Study Regression
language: Stata
---

In this exercise, you'll create event time indicators and run an event study regression using `panel_gis.dta`. The goal is to trace out the dynamic effect of STRV seed adoption on crop yields over time relative to each district's first adoption.

- Working with your `panel_gis.dta` data, define an "event time" for when a district first received STRV seed.
    - Generate `first_adopt = year` if `seed > 0`.
    - Push this down to all observations within each district: `bysort district_id: egen adopt_year = min(first_adopt)`.
    - Replace `adopt_year` with `0` for districts that never adopt.
- Create a relative event time variable: `gen rel_time = year - adopt_year if adopt_year > 0`.
- Shift this range so all values are strictly positive and call this new variable `event_factor`.
- Run a Two-Way Fixed Effects regression of `evi_med` on the interaction `ib0.event_factor##c.bin_max_60_611`, including `i.year` for time fixed effects. Cluster standard errors at the `district_id` level.

1. What does a `rel_time` of $-3$ mean intuitively in this context?
2. Looking at the interaction terms, does the relationship between flooding and yields change after adoption?
