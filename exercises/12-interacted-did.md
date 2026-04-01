---
layout: exercise
topic: Difference-in-Differences
title: Continuous Interacted DiD
language: Stata
---

The true value of Swarna-Sub1 (the STRV seed) is measured when districts flood. Let's interact the continuous `seed` treatment with the flood index `c.bin_max_60_611`. 

- Run a regression of `evi_med` against the interaction of our two continuous variables `c.seed##c.bin_max_60_611` using fully specified Two-Way Fixed Effects (i.e., `xtreg` with `, fe` and `i.year`).
- Cluster your standard errors at the `district_id` level.
- Save the results using `eststo` and call it `did3`.

1. Adapt the table code from Exercise 1 to add one more column (for `did3`) and place the table into Overleaf:
2. In the relevant section/subsection of your Overleaf file, evaluate the coefficient of the interaction term `c.seed#c.bin_max_60_611`. What does a positive or negative sign tell us about how the seed mediates the impact of floods on yield?
