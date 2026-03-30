---
layout: exercise
topic: Difference-in-Differences
title: Challenge 12
language: Stata
---

This challenge combines Continuous Difference-in-Differences and Event Studies using `panel_gis.dta`. Your primary goal is to examine how STRV cumulative seed availability (`seed`) mitigates the negative crop yield (`evi_med`) impacts of major generalized flooding.

1. **Load and Set Data**
   - Use `panel_gis.dta` and `xtset district_id year`.

2. **Continuous TWFE Model**
   - Regress `evi_med` against `seed`, controlling for flooded state `bin_max_60_611` AND their interaction `c.seed##c.bin_max_60_611`. 
   - Control for Two-Way Fixed Effects (Time and District).
   - `eststo` this model as `did1`.
   
3. **Discrete Event Study Metric**
   - Now we want to discretize seed adoption to create an event study.
   - Generate `first_adopt = year` when `seed > 0` for the first time. Apply this across panels using `bysort district_id: egen adopt_year = min(first_adopt)`. Replace with `0` for districts that never adopt. 
   - Generate `rel_time = year - adopt_year` internally. You do not need to bin it for this challenge. Just offset it: `gen event_factor = rel_time + 10`. 
   
4. **Event Regression**
   - Run the event study TWFE regression omitting the period immediately prior to adoption (e.g. `ib9.event_factor`).
   - Store it as `es1`.

5. **Presentation**
   - Use `esttab did1 using "challenge-did.tex"` to export the continuous DiD table with standard robust label options.
   - Use `coefplot` on the event study regression to create a formatted `challenge-es.png`. Use `recast(connected)` and a vertical reference line at the omitted `t=-1` period. 
   - Explain in your comments which method (Continuous DiD vs. Event Study curve) you think tells a more convincing story about the effect of the STRV seed technology on yield, and why. 
