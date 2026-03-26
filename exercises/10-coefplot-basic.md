---
layout: exercise
topic: LaTeX Figures
title: Basic `coefplot`
language: Stata
---

Using `tenuredata.dta`, create a coefficient plot.
- Run a regression of `yield` on `q_f_ha`, `lt_f_ha`, `i.irrig`, and `i.tenure`, with standard errors clustered at the household level: `vce(cluster panelid)`.
- Create a coefficient plot using `coefplot`:
   - Drop the constant (`drop(_cons)`)
   - Add a vertical reference line at zero (`xline(0)`)
   - Relabel the coefficients to be more descriptive
   - Add a `title` and an `xtitle`
- Export the graph: `graph export "$answ/10-coefplot-basic.png", replace`

---
