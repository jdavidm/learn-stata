---
layout: exercise
topic: Producing Results
title: Basic esttab Table
language: Stata
---

Using `tenuredata.dta` (rice observations only), produce a formatted regression table.

1\. Load `tenuredata.dta` and keep only rice (`keep if rice == 1`).
2\. Run `reg yield q_f_ha lt_f_ha i.irrig i.tenure, vce(cluster panelid)` and store as `r1`.
3\. Display the table with `esttab`:
   ```stata
   esttab      r1, se star(* 0.10 ** 0.05 *** 0.01) ///
                   keep(q_f_ha lt_f_ha 1.irrig 1.tenure) ///
                   label ///
                   title("Rice yield regression") ///
                   stats(N r2, labels("Observations" "R-squared") fmt(0 3))
   ```
4\. In comments: what do the stars on each coefficient mean?

---
