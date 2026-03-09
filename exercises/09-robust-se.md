---
layout: exercise
topic: Regression
title: Robust Standard Errors
language: Stata
---

Using `eth_allrounds_final.dta`, compare default and robust standard errors.

1\. Run `reg yield_kg nitrogen_kg i.irr plot_area_GPS` (default standard errors).
2\. Run the same regression with `, robust` appended.
3\. In comments, answer:
   - Did the coefficients change?
   - How did the standard error on `nitrogen_kg` change?
   - Did the p-value on `nitrogen_kg` change in a way that would affect your conclusions?

[Relevant lecture section]({{ site.baseurl }}/materials/09-std-errors/#robust-standard-errors)
