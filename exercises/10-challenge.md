---
layout: exercise
topic: Producing Results
title: Challenge 10
language: Stata
---

This challenge uses `tenuredata.dta` to practice skills from all three lectures (LaTeX, coefplot, estout). You will produce a short results section with a summary statistics table and a coefficient plot — all integrated into your LaTeX document. Reload the `tenuredata.dta` and type `estimates clear`.

1\. Use `estpost sum` to compute summary statistics for: `yield`, `q_f_ha`, `lt_f_ha`, `area`, `irrig`, `tenure`, `educhoh`, `aghoh`. Then export the table to `$answ/10-challenge-sumstats.tex` using `esttab` with `booktabs` and `label`, `posthead`, `postfoot`, `nonum`, `nomtitle`, `nobaselevels`, `nogaps`, and `fragment`.

2\. Create a multi-model coefplot comparing `q_f_ha` across the four regressions with `vce(cluster panelid)`. Then export: `graph export "$answ/10-challenge-coefplot.png", replace`

   - **c1**: `yield` on `q_f_ha lt_f_ha`
   - **c2**: `yield` on `q_f_ha lt_f_ha i.irrig i.tenure`
   - **c3**: `yield` on `q_f_ha lt_f_ha i.irrig i.tenure educhoh agehoh`
   - **c4**: `yield` on `q_f_ha lt_f_ha i.irrig i.tenure educhoh agehoh i.site i.year`

3\. In your `lastname.tex` under Assignment 10, create a short results section that includes:
   - A couple sentences discuss the summary statistics table and referencing the table (use `\ref{}`)
   - The summary statistics table (`\input{10-challenge-sumstats.tex}`) with a title using `\caption{}` and label using `\label{}`
   - A couple sentences discuss the coefficient plot and referencing the figure (use `\ref{}`)
   - The coefficient plot (`\includegraphics{10-challenge-coefplot.png}`) with a title using `\caption{}` and label using `\label{}`
   - Compile and verify everything renders correctly.
