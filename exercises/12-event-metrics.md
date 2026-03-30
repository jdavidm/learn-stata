---
layout: exercise
topic: Event Studies
title: Generating Event Time Metrics
language: Stata
---

Event study regressions rely entirely on mapping the calendar `year` relative to the policy intervention (e.g., the first year the STRV seed was heavily adopted in a district). 

### Tasks

1. Working with your `panel_gis.dta` data, let's artificially define an "event time" for when a district first crossed an arbitrary cumulative seed distribution threshold (e.g., `seed > 0.5`). 
2. Create `first_adopt = year` if `seed > 0.5`. 
3. Use `bysort district_id: egen adopt_year = min(first_adopt)` to push this year down to all observations for each district. Use `replace adopt_year = 0 if adopt_year == .` for districts that never adopt heavily.
4. Create a relative event time variable: `gen rel_time = year - adopt_year if adopt_year > 0`. 
5. What does a `rel_time` of `-3` mean intuitively in this context? Explain in a comment.
