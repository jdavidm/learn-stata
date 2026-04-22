---
layout: exercise
topic: Regression Discontinuity
title: Fuzzy RDD
language: Stata
---

Now we estimate the fuzzy RD — the causal effect of **actually receiving a road** on fire activity and air pollution. Following the IV logic from [Week 13]({{ site.baseurl }}/materials/13-iv/), we use the population threshold `t` as an instrument for `receivedroad`.

- Run the fuzzy RD for fires (`fires10km`) using `ivreghdfe` and instrumenting for `receivedroad` with `t`.
- Include as exogenous left-hand-side variables `left right` and the baseline controls.
- Absorb district-threshold (`dist_thresh_id`) and year (`year`) fixed effects, and clustering standard errors at the `village_id` level. 
- Use triangular kernel weights `[aw = kernel_tri_ik]`. 
- Store results as `iv_fires`.
- Finally, calculate the control group mean for fires within the effective sample (`if e(sample) & t == 0`) and store it as a scalar called `depvarmean`.
- Run the same specification for `pm25` (replace `fires10km` with `pm25` and `fires2001_10km` with `pm25_bl2001` as the baseline control). Store as `iv_pm`. and again calculate the control group mean for pm25 within the effective sample and store it as `depvarmean`.

1\. Export a four-column table. Make sure you still have the reduced-form estimates from Exercise 2 (`rf2`) and the first-stage estimate from Exercise 4 (`fs`) stored.

```stata
* four-column table
    esttab      fs rf2 iv_fires iv_pm ///
                    using "$answ/14-rdd-fuzzy.tex", replace ///
                    b(3) se(3) ///
                    keep(t receivedroad) ///
                    coeflabels(t "Above threshold" ///
                        receivedroad "Road built") ///
                    star(* 0.10 ** 0.05 *** 0.01) ///
                    mtitles("Road" "Fires" "Fires" "PM 2.5") ///
                    stats(N depvarmean, ///
                        labels("Observations" ///
                            "Control group mean") ///
                        fmt(0 2)) ///
                    noobs booktabs nonum collabels(none) ///
                    nobaselevels nogaps fragment label ///
                    prehead("\begin{tabular}{l*{4}{c}} " ///
                        "\\[-1.8ex]\hline \hline \\[-1.8ex] " ///
                        "& \multicolumn{2}{c}{1st Stage} " ///
                        "& \multicolumn{2}{c}{Fuzzy RD (IV)}" ///
                        " \\ \midrule") ///
                    postfoot("\hline \hline \\[-1.8ex] " ///
                        "\multicolumn{5}{p{\linewidth}}{\small " ///
                        "\noindent \textit{Note}: All models " ///
                        "include baseline controls, " ///
                        "district-threshold and year FE, and " ///
                        "triangular kernel weights. Std.\ errors " ///
                        "clustered at village level. " ///
                        "* p$<$0.10, ** p$<$0.05, " ///
                        "*** p$<$0.01.} " ///
                        "\end{tabular}")
```

2\. Does road construction increase or decrease air pollution? Is this consistent with the direction of the fire effect?

---
