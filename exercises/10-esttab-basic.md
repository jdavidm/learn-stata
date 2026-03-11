---
layout: exercise
topic: LaTeX Tables
title: Basic `esttab` Table
language: Stata
---

Using `tenuredata.dta` (rice observations only), produce a formatted regression table. 
- Run `reg yield q_f_ha lt_f_ha i.irrig i.tenure, vce(cluster panelid)` a
- Store results as `r1`.
- Display the table with `esttab`:
   ```stata
   esttab      r1, se star(* 0.10 ** 0.05 *** 0.01) ///
                   keep(q_f_ha lt_f_ha 1.irrig 1.tenure) ///
                   label ///
                   title("Rice yield regression") ///
                   stats(N r2, labels("Observations" "R-squared") fmt(0 3))
   ```

---
