---
layout: exercise
topic: LaTeX
title: Specification Chart
language: Stata
---

Using `tenuredata.dta`, build a specification chart that shows how the fertilizer coefficient varies across many specifications. You can do this by adapting the code from the lecture notes, replacing variable names and labels as necessary.
- Use `postfile` to loop over specifications varying the controls, fixed effects, and standard errors (use `lny` as the dependent variable):
   - **Controls** (4 levels): (1) baseline (`lnf lnl lnp`), (2) + plot characteristics (`i.irrig i.tenure`), (3) + assets (`tractor carabao`), (4) + HH characteristics (`hhsize educhoh agehoh`)
   - **Fixed Effects** (3 levels): (1) none, (2) site (`i.site`), (3) site and year (`i.site i.year`)
   - **Standard errors** (2 levels): (1) default, (2) clustered at `panelid`
- Store the coefficient on `lnf`, its SE, and the 95% CI from each specification.
- After the loop, load the results and create significance indicators:
- Sort by `beta` and generate `obs = _n`.
- Stack specification indicators for the bottom panel (controls, FEs, SEs) and adjust your dual y-axis plot to match the 24 regressions and the new categories. Use colors to distinguish significant positive (blue), significant negative (maroon), and not significant (black) results.
- Export: `graph export "$answ/10-spec-chart-rice.png", replace`
- In your `lastname.tex`, include the graph using `\includegraphics[width=0.8\textwidth]{10-spec-chart-rice.png}`

---
