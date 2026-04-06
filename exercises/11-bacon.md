---
layout: exercise
topic: Two-Way Fixed Effects
title: Modern TWFE Estimators
language: Stata
---

Let's do a [Bacon decomposition](https://doi.org/10.1016/j.jeconom.2021.03.014) and then apply [Callaway & Sant'Anna's](https://doi.org/10.1016/j.jeconom.2020.12.001) modern robust estimator to `mm.dta` using the `first_icp` cohort variable we just built.

1. Run `bacondecomp yield icp, ddetail`. Save the resulting figure as a `.png` file and import it into your `lastname.tex` under Assignment 11. Give it the caption `Bacon Decomposition` and label it `fig:bacon`.
2. Now run `csdid yield, ivar(qnno) time(tindex) gvar(first_icp) tr(icp)`. Calculate the aggregated overall ATT by running `estat event` and use `eststo` to save the result. Then use `esttab` to create a table of the results from this model and the TWFE model you estimated in the last exercise.
3. How do these results compare to the standard Two-Way Fixed Effects estimate you found in the last exercise?

---
