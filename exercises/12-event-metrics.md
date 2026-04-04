---
layout: exercise
topic: Event Studies
title: Bacon Decomposition
language: Stata
---

In the lecture we applied the Bacon decomposition to the Castle Doctrine data. Now let's apply it to our own `panel_gis.dta` to see whether the staggered adoption of STRV seed creates bias in a standard TWFE estimate.

- Using `panel_gis.dta`, create a binary treatment variable: `gen icp = (seed > 0)`.
- Use the `adopt_year` variable you created in Exercise 4 to generate a binary post-treatment indicator: `gen post_adopt = (year >= adopt_year) & (adopt_year > 0)`.
- Run a minimal TWFE regression: `areg evi_med c.post_adopt##c.bin_max_60_611 i.year, absorb(district_id) robust`. Note the coefficient on the interaction term `c.post_adopt#c.bin_max_60_611`.
- Run the Bacon decomposition on the simpler model: `bacondecomp evi_med post_adopt, ddetail`.

1. Which type of comparison — "Treated vs Never-Treated," "Earlier vs Later Treated," or "Later vs Earlier Treated" — receives the most weight?
2. Compare the Bacon decomposition scatter plot to the one we saw for Castle Doctrine in lecture. Does the staggered-adoption bias appear to be more or less severe for seed adoption than for the Castle Doctrine? Why might that be?
