---
layout: exercise
topic: Difference-in-Differences
title: Continuous Interacted DiD
language: Stata
---

The true value of Swarna-Sub1 (the STRV seed) is measured when districts flood! Let's interact the continuous `seed` treatment with the flood index `c.bin_max_60_611`. 

### Tasks

1. Let's incorporate the flood metric. Run a regression of `evi_med` against the interaction of our two continuous variables `c.seed##c.bin_max_60_611` using fully specified Two-Way Fixed Effects (i.e., `xtreg` with `, fe` and `i.year`).
2. Be sure to cluster your standard errors at the `district_id` level.
3. Save the results using `eststo`.
4. In comments, evaluate the coefficient of the interaction term `c.seed#c.bin_max_60_611`. What does a positive or negative sign tell us about how the seed mediates the impact of floods on yield?
