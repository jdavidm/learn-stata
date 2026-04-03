---
layout: exercise
topic: Difference-in-Differences
title: Continuous Treatment DiD
language: Stata
---

We will use `panel_gis.dta` to estimate the effect of STRV seed adoption on crop yields (`evi_med`) in flooded environments. The data is from Bangaldesh and is at the district level for the whole country. All data except the `seed` data is measured using remote sensing and a deep learning algorithm. The data is from [Impact evaluations in data-scarce environments: The case of stress-tolerant rice varieties in Bangladesh](https://doi.org/10.1016/j.jdeveco.2025.103648), which was a former student's MS thesis.

In the data, the treatment metric `seed` is uniquely continuous—it captures the combined cumulative availability of the seed in each district (`district_id`) over time (`year`).

- Regress the yield measure (`evi_med`) on the continuous treatment (`seed`) interacted with `year`. Cluster your standard errors at the `district_id` level.
    - Save the results using `eststo` calling it `did1`
- Repeat the regression but this time using `didregress`. Cluster your standard errors at the `district_id` level.
    - Save the results using `eststo` calling it `did2`
- Use `esttab` to create a table of results using the following table structure and place the table into Overleaf:

```stata
   esttab      did1 did2 using "$answ/12-did.tex", replace ///
                    b(4) se(4) ///
                    rename(seed "STRV Seed") ///
                    keep("STRV Seed") ///
                    star(* 0.10 ** 0.05 *** 0.01) ///
                    stats(N r2, labels("Observations" "R-squared") ///
                    noobs booktabs nonum nomtitle eqlabels(none) ///
                    collabels(none) fmt(0 3))  ///
                    nobaselevels nogaps fragment label ///
                    prehead("\begin{tabular}{l*{2}{c}} " ///
                      "\\[-1.8ex]\hline \hline \\[-1.8ex] " ///
                      "& \multicolumn{1}{c}{xtreg} & " ///
                      "\multicolumn{1}{c}{didreg} \\ \midrule") ///
                    postfoot("\hline \hline \\[-1.8ex] " ///
                      "\multicolumn{3}{p{\linewidth}}{\small " ///
                      "\noindent \textit{Note}: Dependent variable " ///
                      "is median EVI. All models use " ///
                      "standard errors clustered at the " ///
                      "household level (in parentheses). " ///
                      "* p$<$0.10, ** p$<$0.05, *** p$<$0.01.} " ///
                      "\end{tabular}")
```
