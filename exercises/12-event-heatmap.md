---
layout: exercise
topic: Event Studies
title: Treatment Adoption Heatmap
language: Stata
---

In lecture we visualized the Castle Doctrine's staggered rollout with a heatmap. Now create one for STRV seed adoption in `panel_gis.dta`.

- Using `panel_gis.dta`, create the binary treatment indicator `post_adopt` from the `adopt_year` variable you built in Exercise 4: `gen post_adopt = (year >= adopt_year) & (adopt_year > 0)`.
- Use `heatplot` to create a treatment adoption heatmap with districts on the y-axis and years on the x-axis:
   ```stata
   heatplot    post_adopt i.district_id i.year, ///
                   colors(white dkgreen) ///
                   ylabel(, labsize(tiny) angle(0)) ///
                   xlabel(, labsize(small) angle(45)) ///
                   ytitle("District") xtitle("Year") ///
                   title("STRV Seed Adoption Timing") ///
                   legend(order(1 "No Seed" 2 "Seed Adopted")) ///
                   graphregion(color(white))
   ```
- Export the heatmap as a `.png` and input it into your Overleaf document.

1. Is the adoption pattern more or less staggered than the Castle Doctrine example from lecture? What does this imply for the reliability of a TWFE estimate?
2. Are there districts that never adopt? What role do they play in the event study design?
