---
layout: exercise
topic: Regression
title: Collinearity and VIF
language: Stata
---

Using `eth_allrounds_final.dta`, diagnose collinearity with the Variance Inflation Factor.

1\. Run `reg yield_kg nitrogen_kg phosphorus_kg potassium_kg i.irr`.
2\. Run `estat vif` immediately after the regression.
3\. In comments, answer:
   - Which variables have VIF values above 5? Above 10?
   - Why might fertilizer types (nitrogen, phosphorus, potassium) be collinear?
   - If VIF is high, does that mean the coefficients are biased, or just imprecise?

[Relevant lecture section]({{ site.baseurl }}/materials/09-concerns/#collinearity)
