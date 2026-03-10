---
layout: exercise
topic: Producing Results
title: Challenge 10
language: Stata
---

This challenge uses `tenuredata.dta` to practice skills from all three lectures (LaTeX, coefplot, estout). You will produce a short results section with a summary statistics table, a regression table, and a coefficient plot — all integrated into your LaTeX document.

### Setup

1\. Load `tenuredata.dta` and keep only rice observations (`keep if rice == 1`).

### Part A: Summary statistics

2\. Use `estpost summarize` to compute summary statistics for: `yield`, `q_f_ha`, `lt_f_ha`, `area`, `irrig`, `tenure`, `educhoh`, `agehoh`.
3\. Export the table to `$answ/10-challenge-sumstats.tex` using `esttab` with `booktabs` and `label`.

### Part B: Regression table

4\. Run and store four regressions with `vce(cluster panelid)`:
   - **c1**: `yield` on `q_f_ha lt_f_ha`
   - **c2**: `yield` on `q_f_ha lt_f_ha i.irrig i.tenure`
   - **c3**: `yield` on `q_f_ha lt_f_ha i.irrig i.tenure educhoh agehoh`
   - **c4**: `yield` on `q_f_ha lt_f_ha i.irrig i.tenure educhoh agehoh i.site i.year`
5\. Produce a four-column table with `esttab`:
   - Show SEs in parentheses and stars at 10/5/1%
   - Keep only `q_f_ha`, `lt_f_ha`, `1.irrig`, `1.tenure`, `educhoh`, `agehoh`
   - Use `indicate` to show "Site FE" and "Year FE" rows
   - Add `stats(N r2)` and a note about clustering
6\. Export to `$answ/10-challenge-regs.tex`.

### Part C: Coefficient plot

7\. Create a multi-model coefplot comparing `q_f_ha` across the four specifications.
8\. Export: `graph export "$answ/10-challenge-coefplot.png", replace`

### Part D: LaTeX integration

9\. In your `lastname.tex` under Assignment 10, create a short results section that includes:
   - A sentence referencing Table 1 and Figure 1 (use `\ref{}`)
   - The summary statistics table (`\input{10-challenge-sumstats.tex}`)
   - The regression table (`\input{10-challenge-regs.tex}`)
   - The coefficient plot (`\includegraphics{10-challenge-coefplot.png}`)
10\. Compile and verify everything renders correctly.
