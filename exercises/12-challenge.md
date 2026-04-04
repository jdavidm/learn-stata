---
layout: exercise
topic: Difference-in-Differences
title: Challenge 12
language: Stata
---

This challenge combines Continuous Difference-in-Differences and Event Studies using `panel_gis.dta`. Your primary goal is to examine how STRV cumulative seed availability (`seed`) mitigates the negative crop yield (`evi_med`) impacts of major flooding (`bin_max_60_611`).

- Load `panel_gis.dta` and `xtset district_id year`.
- Run a Continuous TWFE model:
    - Regress `evi_med` on the full interaction `c.seed##c.bin_max_60_611`, controlling for Two-Way Fixed Effects (`xtreg` with `, fe` and `i.year`).
    - Cluster standard errors at the `district_id` level.
    - `eststo` this model as `did1`.
- Build the event study scaffolding:
    - Generate `first_adopt = year` when `seed > 0` for the first time. Apply this across panels using `bysort district_id: egen adopt_year = min(first_adopt)`. Replace with `0` for districts that never adopt.
    - Generate `rel_time = year - adopt_year` for adopting districts. Shift it to create `event_factor = rel_time + 10`.
- Run the event study TWFE regression:
    - Regress `evi_med` on `ib9.event_factor##c.bin_max_60_611 i.year`, using `xtreg, fe` with standard errors clustered at the `district_id` level.
    - `eststo` this model as `es1`.
- Present your results:
    - Use `esttab did1 using "$answ/challenge-did.tex"` to export the continuous DiD table with standard robust label options.
    - Use `coefplot` on the event study regression to create a formatted `challenge-es.png`. Keep only the interaction terms `*.event_factor#c.bin_max_60_611`. Use `recast(connected)` and a vertical reference line at the omitted $t = -1$ period.

1. In comments, explain which method — the continuous DiD interaction or the event study interaction curve — you think tells a more convincing story about how STRV seed mediates the impact of flooding on yield, and why.
