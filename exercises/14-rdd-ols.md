---
layout: exercise
topic: Regression Discontinuity
title: Reduced-Form RD
language: Stata
---

In this exercise you will estimate a reduced-form (sharp) regression discontinuity using OLS. The Garg et al. (2021) data includes pre-computed linear terms for the RD polynomial: `left` captures the slope of the running variable below the cutoff and `right` captures the slope above the cutoff. The threshold indicator `t` equals 1 for villages above the population cutoff.

- Run a reduced-form regression of `fires10km` on `t left right`, absorbing district-threshold (`dist_thresh_id`) and year (`year`) fixed effects using `reghdfe`, and clustering standard errors at the `village_id` level. Store as `rf1`.
- Re-run the same regression but add triangular kernel weights `[aw = kernel_tri_ik]`. Store as `rf2`.
- Run the kernel-weighted specification again but with `pm25` as the outcome (add `pm25_bl2001` as a baseline control). Store as `rf3`.

1\. Export a three-column table to LaTeX:

```stata
* export reduced-form table
    esttab      rf1 rf2 rf3 using "$answ/14-rdd-ols.tex", replace ///
                    b(3) se(3) ///
                    keep(t) coeflabels(t "Above threshold") ///
                    star(* 0.10 ** 0.05 *** 0.01) ///
                    mtitles("Fires" "Fires (wt)" "PM 2.5 (wt)") ///
                    stats(N r2, labels("Observations" "R-squared") ///
                        fmt(0 3)) ///
                    noobs booktabs nonum collabels(none) ///
                    nobaselevels nogaps fragment label ///
                    prehead("\begin{tabular}{l*{3}{c}} " ///
                        "\\[-1.8ex]\hline \hline \\[-1.8ex] " ///
                        "& \multicolumn{3}{c}{Reduced-Form RD}" ///
                        " \\ \midrule") ///
                    postfoot("\hline \hline \\[-1.8ex] " ///
                        "\multicolumn{4}{p{\linewidth}}{\small " ///
                        "\noindent \textit{Note}: Dependent " ///
                        "variable indicated in column header. " ///
                        "All models include district-threshold " ///
                        "and year FE. Columns 2--3 use " ///
                        "triangular kernel weights. Std.\ errors " ///
                        "clustered at village level. " ///
                        "* p$<$0.10, ** p$<$0.05, " ///
                        "*** p$<$0.01.} " ///
                        "\end{tabular}")
```

2\. Interpret the coefficient on `t` (the threshold) in the unweighted fires regression. What does it mean substantively?

3\. How does adding kernel weights change the estimate? Why might this happen?

---
