---
layout: exercise
topic: LaTeX Figures
title: Basic `coefplot`
language: Stata
---

Using `tenuredata.dta` (rice observations only), create a coefficient plot.

1\. Load `tenuredata.dta` and keep only rice (`keep if rice == 1`).
2\. Run a regression of `yield` on `q_f_ha` (fertilizer/ha), `lt_f_ha` (total field labor/ha), `i.irrig`, and `i.tenure`, with standard errors clustered at the household level: `vce(cluster panelid)`.
3\. Create a coefficient plot using `coefplot`:
   - Drop the constant (`drop(_cons)`)
   - Add a vertical reference line at zero (`xline(0)`)
   - Add a title
4\. Export the graph: `graph export "$answ/10-coefplot-rice.png", replace`

---
