---
layout: exercise
topic: Regression
title: Multivariate Regression
language: Stata
---

Using `eth_allrounds_final.dta`, add controls to a regression and interpret the results.

1\. Run `reg yield_kg nitrogen_kg` (the simple regression from Exercise 1).
2\. Now run a multivariate regression: `reg yield_kg nitrogen_kg i.irr plot_area_GPS`.
3\. In comments, answer:
   - How did the coefficient on `nitrogen_kg` change compared to the simple regression?
   - Interpret the new coefficient on `nitrogen_kg` using the phrase "holding fixed."
   - What is the coefficient on `1.irr`? Explain it as a difference in averages.

[Relevant lecture section]({{ site.baseurl }}/materials/09-regression/#multivariate-regression-adding-controls)
