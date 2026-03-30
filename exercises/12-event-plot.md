---
layout: exercise
topic: Event Studies
title: Event Plot with coefplot
language: Stata
---

Instead of staring at a giant table of relative year coefficients, we can visualize the dynamic treatment effect path using `coefplot`.

### Tasks

1. Re-run your fixed effect regression from Exercise 6 (on `panel_gis.dta` using `ib9.event_factor` and `i.year`).
2. Run `coefplot` immediately afterward, restricting the output to keep only the coefficients associated with `*.event_factor`. Use `rename(*.event_factor = "")` to clean up the legend labels.
3. Include the necessary styling options covered in the lecture to make the graph vertically aligned (`vertical`), connect the points (`recast(connected)`), cap the standard error bands (`ciopts(recast(rcap))`).
4. Most crucially, plot a horizontal reference line at $Y=0$ (`yline(0)`), and a vertical reference line at $X=9$ (`xline(9)`) representing your $t=-1$ base period.
5. Export your `coefplot` to a `.png` file. Does `evi_med` visually jump up sharply at adoption (time $0$), or does it drift upward over time? Respond in comments.
