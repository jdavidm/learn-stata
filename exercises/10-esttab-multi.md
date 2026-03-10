---
layout: exercise
topic: Producing Results
title: Multi-Column Table with Notes
language: Stata
---

Using `tenuredata.dta` (rice observations only), produce a multi-column regression table and export it to LaTeX.

1\. Load `tenuredata.dta` and keep only rice (`keep if rice == 1`).
2\. Run and store three regressions, all with `vce(cluster panelid)`:
   - **r1**: `yield` on `q_f_ha lt_f_ha`
   - **r2**: `yield` on `q_f_ha lt_f_ha i.irrig i.tenure`
   - **r3**: `yield` on `q_f_ha lt_f_ha i.irrig i.tenure i.site i.year`
3\. Display a three-column table with `esttab`:
   ```stata
   esttab      r1 r2 r3, ///
                   se star(* 0.10 ** 0.05 *** 0.01) ///
                   keep(q_f_ha lt_f_ha 1.irrig 1.tenure) ///
                   order(q_f_ha lt_f_ha 1.irrig 1.tenure) ///
                   label ///
                   mtitles("(1)" "(2)" "(3)") ///
                   indicate("Site FE = *.site" "Year FE = *.year") ///
                   stats(N r2, labels("Observations" "R-squared") fmt(0 3)) ///
                   note("Clustered SEs at household level." ///
                        "* p<0.10, ** p<0.05, *** p<0.01")
   ```
4\. Export to LaTeX:
   ```stata
   esttab      r1 r2 r3 using "$answ/10-rice-regs.tex", replace ///
                   se star(* 0.10 ** 0.05 *** 0.01) ///
                   keep(q_f_ha lt_f_ha 1.irrig 1.tenure) ///
                   order(q_f_ha lt_f_ha 1.irrig 1.tenure) ///
                   label booktabs ///
                   mtitles("(1)" "(2)" "(3)") ///
                   indicate("Site FE = *.site" "Year FE = *.year") ///
                   stats(N r2, labels("Observations" "R-squared") fmt(0 3)) ///
                   note("Clustered SEs at household level." ///
                        "\sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)")
   ```
5\. In your `lastname.tex`, include the table using `\input{10-rice-regs.tex}` inside a `table` environment.

---
