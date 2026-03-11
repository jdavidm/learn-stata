---
layout: exercise
topic: Producing Results
title: Inserting a Stata Table
language: Stata
---

Using `tenuredata.dta`, create a summary statistics table in Stata and include it in your LaTeX document. Start by loading `tenuredata.dta` and keep only rice observations (`keep if rice == 1`).

1. Use `estpost summarize` to compute summary statistics for: `yield`, `q_f_ha`, `lt_f_ha`, and `area`. Export it to LaTeX (`using "$answ/10-latex-table.tex"`) with the `booktabs` and `label` options.
2. In your `lastname.tex` under Assignment 10, include the table using `\input{}` inside a `table` environment. Give it the caption `Summary statistics for rice parcels` and label it `tab:sumstats_rice`.

---
