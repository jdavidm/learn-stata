---
layout: exercise
topic: Fixed Effects
title: Challenge 11
language: Stata
---

This challenge combines everything you've learned about Fixed Effects, `estout`, and `coefplot` to test the sensitivity of the `icp` coefficient across multiple Fixed Effect specifications.
- Load the `mm.dta` dataset.
- Run the following four models and store their estimates (e.g., `eststo c1`, etc.):
   - **Model 1**: Pooled OLS (`reg`). Regress `yield` on `icp totfertcostha totchemcostha`.
   - **Model 2**: Time Fixed Effects (`reg`). Add `i.tindex` to Model 1.
   - **Model 3**: One-Way Fixed Effects (`xtreg, fe`). Add `xtset` and run the model without time dummies.
   - **Model 4**: Two-Way Fixed Effects (`xtreg, fe`). Add `i.tindex` to Model 3.
- For all 4 models, cluster the standard errors by `qnno`.

1. Use `esttab` to create a table of the coefficient on `icp` across all four models. Adapt the table structure from Week 10, Exercise 4 to create a table of results. In your lastname.tex, include the table using `\input{11-challenge-regs.tex}` inside a table environment that I provide for Assignment 11 in Overleaf. Give the table a caption and label.
2. Use `coefplot` to graph the coefficient on `icp` across all four models. Adapt the figure structure from Week 10, Exercise 7 to create a single figure of results. Add a horizontal line at 0 (`xline(0)`) and customize the legend to cleanly label the four models. In your lastname.tex, include the graph using `\includegraphics[width=0.8\textwidth]{11-challenge-coefplot.png}` inside a figure environment. Give the graph a caption and label.

---
