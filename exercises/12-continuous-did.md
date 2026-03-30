---
layout: exercise
topic: Difference-in-Differences
title: Continuous Treatment DiD
language: Stata
---

We will use `panel_gis.dta` to estimate the effect of STRV seed adoption on crop yields (`evi_med`) in flooded environments. The treatment metric `seed` is uniquely continuous—it captures the combined cumulative availability of the seed in each district (`district_id`) over time (`year`).

### Tasks

1. Create a modern script (do-file) in your standard structure.
2. Load `panel_gis.dta` using your paths.
3. Tell Stata that your dataset is a panel using `xtset`. What is your panel identifier and what is your time variable?
4. Run a Two-Way Fixed Effects regression. Regress the yield measure (`evi_med`) on the continuous treatment (`seed`) using `xtreg, fe`, and strictly control for time effects by adding `i.year`. Cluster your standard errors at the `district_id` level.
5. In comments, how would you interpret the coefficient on `seed`? Does a one-unit increase in cumulative seed availability lead to an increase or decrease in yield across the board?
