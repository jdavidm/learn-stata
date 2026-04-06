---
layout: exercise
topic: Event Studies
title: Ridgeline Plot
language: Stata
---

In lecture we used a ridgeline (joy) plot to visualize how the distribution of homicide rates shifted across event time. Now apply the same technique to STRV seed adoption and crop yields in `panel_gis.dta`.

- Using `panel_gis.dta`, restrict your sample to districts that adopted seed (`first_seed != .`) and to relative times between $-3$ and $5$.
- Use `joyplot` to plot the distribution of `evi_med` by `ry`:
   ```stata
   joyplot     evi_med if inrange(ry, -3, 5) ///
                   & first_seed != ., ///
                   by(ry) droplow ///
                   palette(CET C1) ///
                   lcolor(white) lwidth(0.2) ///
                   ytitle("Relative Time") ///
                   xtitle("EVI (Yield Index)") ///
                   title("Yield Distribution by Event Time")
   ```
- Export the ridgeline plot as a `.png` and input it into your Overleaf document.

1. Do the pre-adoption ridges (negative `ry`) look similar to each other? What does this suggest about parallel trends?
2. After adoption, does the distribution shift, change shape, or spread out? What might each pattern mean for the effectiveness of STRV seed?
