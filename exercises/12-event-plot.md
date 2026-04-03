---
layout: exercise
topic: Event Studies
title: Event Plot with coefplot
language: Stata
---

Instead of staring at a giant table of relative year coefficients, we can visualize the dynamic treatment effect path using `coefplot`.

- Run `coefplot` immediately after the regression you ran in the previous exercise, restricting the output to keep only the coefficients on the interaction terms `*.event_factor#c.bin_max_60_611`. Suppress the legend.
- Include the necessary styling options covered in the lecture to make the graph vertically aligned (`vertical`), connect the points (`recast(connected)`), and cap the standard error bands (`ciopts(recast(rcap))`).
- Plot a horizontal reference line at $Y = 0$ (`yline(0)`) and a vertical reference line at the base period.
- Export your `coefplot` to a `.png` file and input it into your Overleaf document.

1. Do the pre-adoption interaction coefficients hover around zero, consistent with parallel trends?
2. After adoption, does the interaction between `event_factor` and `bin_max_60_611` suggest that STRV seed mitigates or exacerbates the impact of flooding on `evi_med`?
