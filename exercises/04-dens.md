---
layout: exercise
topic: Graphing
title: Density Functions
language: Stata
---

Using the `nlsw88` data,

1\. Draw a kernel density of total work experience.

2\. Draw a version with **less smoothing**.

3\. Draw a version with **more smoothing**.

Stata can overlay a **normal density curve** with the same mean and variance as your data on top of the kernel density estimate. This lets you visually compare your distribution to a smooth, bell-shaped curve (we are *not* doing formal hypothesis tests here).

4\. Draw a kernel density of `ttl_exp` using the `normal` option.

5\. Finally, we will put it all together by drawing a **histogram and a kernel density** for `ttl_exp` on the same plot and make the graph presentation-quality.
   - First, choose reasonable binning (20) for `ttl_exp` and draw a histogram with percent on the y-axis:
   - Next create a combined graph with both the histogram and the kernel density. Use `twoway` to overlay them:
   - Modify the graph by adding the `color(%60)` option, which makes the bars lighter (60% of full opacity) so the density line stands out.  
   - Change the `title()` of the graph to be "Distribution of total work experience"
   - Change the x-axis title to "Total work experience (years)" and the y-axis title to "Percent of workers"
   - Finally, create a legend and place it below the graph (`pos`) and in two columns (`col`). Label the shaded area using `1 "Histogram"` and the line using `2 "Kernel density"`.
