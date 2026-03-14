---
layout: exercise
topic: Fixed Effects
title: Challenge 11
language: Stata
---

This challenge combines everything you've learned about Fixed Effects, `estout`, and `coefplot`.

Using `tenuredata.dta` (restricted to `rice == 1`):

1. We want to test the sensitivity of the `irrig` coefficient across multiple Fixed Effect specifications.
2. Run the following four models and store their estimates (e.g., `eststo c1`, etc.):
   - **Model 1**: Pooled OLS (`reg`). Regress `yield` on `irrig q_f_ha lt_f_ha`.
   - **Model 2**: Time Fixed Effects (`reg`). Add `i.year` to Model 1.
   - **Model 3**: One-Way Fixed Effects (`xtreg, fe`). Add `xtset` and run the model without time dummies.
   - **Model 4**: Two-Way Fixed Effects (`xtreg, fe`). Add `i.year` to Model 3.
3. For all 4 models, tightly cluster the standard errors by `panelid` (where appropriate).
4. Use `coefplot` to graph the coefficient on `irrig` across all four specifications in a single chart.
5. Add a horizontal line at 0 (`xline(0)`), a title, and customize the legend to cleanly label the four models.
6. Export the plot to `$answ/11-challenge-coefplot.png`.
