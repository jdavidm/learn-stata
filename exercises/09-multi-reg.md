---
layout: exercise
topic: Regression
title: Multivariate Regression
language: Stata
---

This exercise guides you through adding control variables to a regression.

### Tasks

1. Open your do-file and load `eth_allrounds_final.dta` if you haven't already.
2. Recall your simple regression from previous exercises:
   ```stata
   regress yield_kg nitrogen_kg
   ```
3. Now, suppose we are worried about omitted variable bias. We know that irrigation (`irr`) and plot area (`plot_area_GPS`) are likely confounders. Run a multivariate regression of `yield_kg` on `nitrogen_kg`, controlling for `i.irr` and `plot_area_GPS`.
4. In comments, answer the following:
   - What is the new coefficient on `nitrogen_kg`? How did it change compared to the simple regression?
   - How do you carefully interpret the coefficient on `nitrogen_kg` now that controls are included? (Hint: use the phrase "holding fixed...").
   - What is the coefficient on `1.irr`? Explain it as a difference in averages.
5. In comments, draw a simple DAG showing the relationship between nitrogen, yield, and irrigation. Based on your DAG, explain why we needed to control for irrigation to get closer to the causal effect of nitrogen on yield.
