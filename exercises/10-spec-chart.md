---
layout: exercise
topic: LaTeX Figures
title: Specification Chart
language: Stata
---

Using `tenuredata.dta` (rice observations only), build a specification chart that shows how the fertilizer coefficient varies across many specifications.

1\. Load `tenuredata.dta` and keep only rice (`keep if rice == 1`). Generate `ln_yield = ln(yield)`.
2\. Use `postfile` to loop over specifications varying:
   - **Dependent variable**: `yield` vs `ln_yield` (indicator: 1 = yield, 2 = ln_yield)
   - **Controls**: (1) baseline (`q_f_ha lt_f_ha`), (2) + tenure/irrigation (`i.irrig i.tenure`), (3) + site and year FE (`i.site i.year`)
   - **Standard errors**: (1) default, (2) clustered at `panelid`
3\. Store the coefficient on `q_f_ha`, its SE, and the 95% CI from each specification.
4\. After the loop, load the results. Create significance indicators:
   ```stata
   gen     b_sig = beta if (ci_lo > 0 | ci_up < 0)
   gen     b_ns  = beta if b_sig == .
   ```
5\. Sort by `beta` and generate `obs = _n`.
6\. Stack specification indicators for the bottom panel (dep var, controls, SEs).
7\. Plot using a dual y-axis: indicators on the left axis, coefficients and CIs on the right. Use colors to distinguish significant positive (blue), significant negative (maroon), and not significant (black) results.
8\. Export: `graph export "$answ/10-spec-chart-rice.png", replace`

---
