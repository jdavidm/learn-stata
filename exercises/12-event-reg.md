---
layout: exercise
topic: Event Studies
title: Event Study Regression
language: Stata
---

In this exercise, you'll build an event study from scratch using `panel_gis.dta`. The goal is to trace out the dynamic effect of STRV seed adoption on crop yields over time, using the interaction-weighted estimator from [Sun and Abraham (2021)](https://doi.org/10.1016/j.jeconom.2020.09.006).

- Generate a cohort variable that records the first year each district received STRV seed. Create a temporary variable equal to `year` when `seed > 0`, then use `bysort` and `egen min()` to create `first_seed` that pushes the earliest adoption year to all observations within each district. Drop the temporary variable.
- Create a relative time variable `ry` equal to `year` minus the cohort variable. Bin any values greater than 10 to 10 by making `ry = 10` when `ry > 10` and also not missing (remember, Stata treats `.` as infinitely large).
- Identify the control cohort. Generate an indicator for districts that never received seed (`never_seed`) and a separate indicator for districts that received seed last (in 2019) (`last_seed`).
- Generate lead dummies using a `forvalues` loop counting down from 16 to 2. Name them `g_k` (e.g., `g_16`, `g_15`, ..., `g_2`), where each equals 1 when `ry == -k`. Inside the loop, use `label var g_k "-k"` so the variable has a clean name for tables.
- Generate lag dummies using a `forvalues` loop from 0 to 10. Name them `gk` (e.g., `g0`, `g1`, ..., `g10`), where each equals 1 when `ry == k`. Inside the loop, use `label var gk "k"` so it has a clean name for tables.

1\. Run the regression using `xtreg`, specifying `evi_med` as the outcome, include all lead and lag dummies (`g_* g0-g10`), add year fixed effects (`i.year`), specify the `fe` option to absorb district fixed effects, and cluster standard errors at the `district_id` level. Store the event study results by prefixing the regression with `eststo twfe:`.

Now run the robust event study using `eventstudyinteract`. Specify `evi_med` as the outcome, include all lead and lag dummies (`g_* g0-g10`), set the cohort variable with `cohort(first_seed)`, identify the control cohort with `control_cohort(last_seed)`, include `fld_cuml` as a covariate with `covariates()`, absorb district and year fixed effects with `absorb(i.district_id i.year)`, and cluster standard errors at the `district_id` level.

Because `eventstudyinteract` stores its estimates internally in `e(b_iw)` instead of `e(b)`, commands like `esttab` won't find them by default. Before exporting, you must move the results using `erepost` and store them:

```stata
* post results for esttab
	matrix          b_iw = e(b_iw)
	matrix          V_iw = e(V_iw)
	erepost         b = b_iw V = V_iw
	eststo iw
```

Export both stored results to a single LaTeX table using the code block below. Adjust `\scalebox{}` to make the table fit in your document.

```stata
* export results to latex
   esttab       twfe iw using "$answ/12-event-reg.tex", replace ///
                    b(4) se(4) ///
                    drop(*.year _cons) ///
                    star(* 0.10 ** 0.05 *** 0.01) ///
                    mtitles("TWFE" "Interaction-Weighted") ///
                    noobs booktabs nonum ///
                    eqlabels(none) collabels(none) ///
                    nobaselevels nogaps fragment label ///
                    prehead("\begin{tabular}{l*{2}{c}} " ///
                        "\\[-1.8ex]\hline \hline \\[-1.8ex] " ///
                        "& \multicolumn{2}{c}{Event Study} \\ \midrule") ///
                    postfoot("\hline \hline \\[-1.8ex] " ///
                        "\multicolumn{3}{p{\linewidth}}{\small " ///
                        "\noindent \textit{Note}: Dependent variable " ///
                        "is median EVI. Standard errors clustered at the " ///
                        "district level (in parentheses). " ///
                        "* p$<$0.10, ** p$<$0.05, *** p$<$0.01.} " ///
                        "\end{tabular}")
```

2\. Looking at the two columns, do you see evidence of bias in the TWFE pre-trend coefficients (the negative lags) compared to the interaction-weighted estimator?

---
