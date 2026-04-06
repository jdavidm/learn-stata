---
layout: exercise
topic: Standard Errors & Inference
title: Evaluating HC2
language: Stata
---

The `lifeexp.dta` dataset contains life expectancy and GNP per capita for various countries. As you might expect, there are massive outliers (like the United States) that act as high leverage points. High leverage points pull standard ordinary least squares estimates violently.

1. Load `lifeexp.dta`.
2. Run Stata's default robust regression (HC1):
   ```stata
   reg lexp gnppc, robust
   ```
3. Run the leverage-adjusted robust regression (HC2) to correct for the outliers:
   ```stata
   reg lexp gnppc, vce(hc2)
   ```
4. Compare the standard error for `gnppc` under HC1 vs HC2. Does adjusting for leverage increase or decrease our confidence (standard error) in the estimate?
