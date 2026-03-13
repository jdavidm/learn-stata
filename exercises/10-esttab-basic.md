---
layout: exercise
topic: LaTeX Tables
title: Basic `esttab` Table
language: Stata
---

Using `tenuredata.dta` (rice observations only), produce a formatted regression table.

1\. In your `lastname.tex`, include the table using `\input{10-rice-regs.tex}` inside a `table` environment.
- Run `reg yield q_f_ha lt_f_ha, vce(cluster panelid)` a
- Store results as `r1`.
- Display the table with `esttab`:
   ```stata
   esttab      r1 using "$answ/10-esttab-basic-1.tex", replace ///
                   se star(* 0.10 ** 0.05 *** 0.01) ///
                   keep(q_f_ha lt_f_ha) ///
                   label booktabs ///
                   stats(N r2, labels("Observations" "R-squared") fmt(0 3))
  ```
- In your `lastname.tex`, include the table using `\input{10-esttab-basic-1.tex}` inside a `table` environment.

2\.Run and store three regressions, all with `vce(cluster panelid)`:
   - **r2**: `yield` on `q_f_ha lt_f_ha i.irrig i.tenure`
   - **r3**: `yield` on `q_f_ha lt_f_ha i.irrig i.tenure i.site i.year`
- Display a three-column table with `esttab` and export it to LaTeX:

```stata
   esttab      r1 r2 r3 using "$answ/10-esttab-basic-2.tex", replace ///
                   se star(* 0.10 ** 0.05 *** 0.01) ///
                   keep(q_f_ha lt_f_ha 1.irrig 1.tenure) ///
                   order(q_f_ha lt_f_ha 1.irrig 1.tenure) ///
                   label booktabs ///
                   indicate("Site FE = *.site" "Year FE = *.year") ///
                   stats(N r2, labels("Observations" "R-squared") fmt(0 3)) ///
                   note("Clustered SEs at household level." ///
                        "\sym{*} \(p<0.10\), \sym{**} \(p<0.05\), " ///
                        "\sym{***} \(p<0.01\)")
```
- In your `lastname.tex`, include the table using `\input{10-esttab-basic-2.tex}` inside a `table` environment.

---
