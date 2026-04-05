---
layout: exercise
topic: Event Studies
title: Event Plot with coefplot
language: Stata
---

- You already estimated the robust event study in Exercise 4.2 using `eventstudyinteract`. Re-run that exact `eventstudyinteract` command (without the `erepost` part) to ensure the model results are fresh in Stata's memory.
- Extract the interaction-weighted coefficients into a matrix: use `matrix C = e(b_iw)` to grab the point estimates from the stored results.
- The variance-covariance matrix `e(V_iw)` contains the variances on its diagonal. To get standard errors, you need the square root of those diagonal elements. Use `mata` to do this in one line: `mata st_matrix("A", sqrt(diagonal(st_matrix("e(V_iw)"))))`.
- Stack the standard errors below the coefficients: `matrix C = C \ A'`. The backslash (`\`) stacks matrices vertically, and `A'` transposes `A` from a column vector to a row vector so it aligns with `C`. Now row 1 of `C` is the coefficients and row 2 is the standard errors.
- Print the matrix to verify: `matrix list C`. You should see one row of point estimates and one row of standard errors, with columns named after your lead and lag dummies.

1\. How many columns does your matrix `C` have? Does this match the number of lead and lag dummies you created?

2\.Now use `coefplot` to plot directly from the matrix `C`. Build the plot with the following options:

- Source the coefficients from row 1 of `C` using `matrix(C[1])` and pair them with standard errors from row 2 using `se(C[2])`.
- Set the graph region background to white with `graphregion(fcolor(white))`.
- Label the x-axis "Event years" using `xtitle()` with `size(medlarge)`.
- Orient the plot vertically and include the omitted period as a zero with the `vertical` and `omitted` options.
- Use square markers (`msymbol(s)`), colored black (`mc(black)`) with white fill (`mfcolor(white)`).
- Add a horizontal reference line at zero using `yline(0)` with thin black styling.
- Connect the points with thick black lines using `recast(connected)`, `lw(thick)`, and `lc(black)`.
- Display the confidence intervals as dashed lines using `ciopts(recast(rline) lw(thin) lc(black) lp(dash))`.
- Add a vertical treatment reference line at position 16 (where `g_1` would be — the last pre-treatment period) using `xline()` in red.
- Suppress the grid with `ylabel(, angle(0) nogrid)` and keep only the lead/lag coefficients with `keep(g_* g*)`.
- Clean up the coefficient labels using `rename(g_* = "-" g* = "")` so leads show as negative numbers and lags as positive.
- Set the y-axis title to "Median EVI" and manually label the x-axis tick marks at informative intervals (e.g., positions 02, 07, 12, 16, 21, 25 labeled as "-15", "-10", "-5", "0", "5", "10").
- Export the plot as `"$answ/12-event-plot.png"`.

3\. Do the pre-treatment coefficients hover near zero, consistent with parallel trends? After adoption, does the effect of STRV seed on `evi_med` appear to grow over time, or is it immediate and constant?
