---
layout: exercise
topic: Producing Results
title: Multi-Model Coefplot
language: Stata
---

Using `tenuredata.dta` (rice observations only), compare the fertilizer coefficient across multiple specifications.

1\. Load `tenuredata.dta` and keep only rice (`keep if rice == 1`).
2\. Run and store three regressions, all with `vce(cluster panelid)`:
   - **m1**: `yield` on `q_f_ha lt_f_ha`
   - **m2**: `yield` on `q_f_ha lt_f_ha i.irrig i.tenure`
   - **m3**: `yield` on `q_f_ha lt_f_ha i.irrig i.tenure i.site i.year`
3\. Create a multi-model coefplot showing only `q_f_ha`:
   ```stata
   coefplot    m1 m2 m3, keep(q_f_ha) xline(0) ///
                   title("Fertilizer coefficient across specifications") ///
                   legend(order(2 "Baseline" 4 "+ Tenure/Irrig" 6 "+ FE"))
   ```
4\. Export the graph: `graph export "$answ/10-coefplot-multi.png", replace`
5\. In comments: is the fertilizer coefficient stable across specifications?

---
