---
layout: exercise
topic: Event Studies
title: Treatment Adoption Heatmap
language: Stata
---

In lecture we visualized the Castle Doctrine's staggered rollout with a heatmap. Now create one for STRV seed adoption in `panel_gis.dta`.

- Create the binary treatment indicator `post_adopt` from the `first_seed` variable you built in Exercise 4: `gen post_adopt = (year >= first_seed) & (first_seed != .)`.
- Use `heatplot` to create a treatment adoption heatmap with districts on the y-axis and years on the x-axis:
   ```stata
   heatplot    post_adopt i.district_id i.year, ///
                   colors(white dkgreen) ///
                   ylabel(, labsize(tiny) angle(0)) ///
                   xlabel(, labsize(small) angle(45)) ///
                   ytitle("District") xtitle("Year") ///
                   legend(order(1 "No Seed" 2 "Seed Adopted")) ///
                   graphregion(color(white))
   ```
- Export the heatmap as a `.png` and input it into your Overleaf document.
