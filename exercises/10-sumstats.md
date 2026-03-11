---
layout: exercise
topic: LaTeX Tables
title: Summary Statistics Table
language: Stata
---

Using `tenuredata.dta` (rice observations only), produce a summary statistics table and export it to LaTeX.

1\. Load `tenuredata.dta` and keep only rice (`keep if rice == 1`).
2\. Use `estpost summarize` to compute summary statistics for: `yield`, `q_f_ha`, `lt_f_ha`, `area`, `irrig`, `tenure`.
3\. Display the table with:
   ```stata
   esttab,     cells("count mean sd min max") ///
                   noobs nonumber nomtitle ///
                   title("Summary Statistics — Rice Parcels") ///
                   label
   ```
4\. Export to LaTeX:
   ```stata
   esttab      using "$answ/10-sumstats-rice.tex", replace ///
                   cells("count(fmt(0)) mean(fmt(2)) sd(fmt(2)) min(fmt(1)) max(fmt(1))") ///
                   noobs nonumber nomtitle ///
                   title("Summary Statistics — Rice Parcels") ///
                   booktabs label
   ```
5\. Include the table in your `lastname.tex` using `\input{10-sumstats-rice.tex}`.

---
