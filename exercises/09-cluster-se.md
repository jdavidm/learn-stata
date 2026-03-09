---
layout: exercise
topic: Regression
title: Clustered Standard Errors
language: Stata
---

Using `eth_allrounds_final.dta`, cluster standard errors at the household level and compare.

1\. Run `reg yield_kg nitrogen_kg i.irr plot_area_GPS, robust`.
2\. Now run the same regression with clustered standard errors: `reg yield_kg nitrogen_kg i.irr plot_area_GPS, vce(cluster hhid)`.
3\. In comments, answer:
   - How did the standard error on `nitrogen_kg` change when moving from robust to clustered?
   - Why does clustering at the household level make sense for plot-level data?

[Relevant lecture section]({{ site.baseurl }}/materials/09-std-errors/#clustered-standard-errors)
