---
layout: exercise
topic: Producing Results
title: Inserting a Stata Figure
language: Stata
---

Using `tenuredata.dta`, create a graph in Stata and include it in your LaTeX document. Start by loading `tenuredata.dta` and keep only rice observations (`keep if rice == 1`).

1. Create a scatter plot of `yield` against `q_f_ha` (fertilizer per hectare) with a fitted line (`lfit`). Choose formatting option for the markers, line, and axis titles. Export the graph to `$answ/10-scatter-rice.png`.
2. In your `lastname.tex` under Assignment 10, include the graph. Give it the caption `Rice yield vs fertilizer application` and label it `fig:scatter_rice`.

---
