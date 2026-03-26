---
layout: exercise
topic: Two-Way Fixed Effects
title: Modern TWFE Estimators
language: Stata
---

Let's do a Bacon decomposition and then apply Callaway & Sant'Anna's modern robust estimator to `tenuredata.dta` using the `first_irrig` cohort variable we just built.

1\. Run `bacondecomp yield irrig, ddetail`. Save the resulting figure as a `.png` file and import it into your `lastname.tex` under Assignment 11. Give it the caption `Bacon Decomposition` and label it `fig:bacon`.

2\. Now run `csdid yield, ivar(panelid) time(year) gvar(first_irrig) tr(irrig)`. Calculate the aggregated overall ATT by running `estat event` and use `eststo` to save the result. Then use `esttab` to create a table of the results from this model and the TWFE model you estimated in the last exercise.

3\. How do these results compare to the standard Two-Way Fixed Effects estimate you found in the last exercise?
