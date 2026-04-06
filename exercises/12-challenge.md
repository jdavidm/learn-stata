---
layout: exercise
topic: Difference-in-Differences
title: Challenge 12
language: Stata
---

This challenge combines Difference-in-Differences with a Monte Carlo (MC) simulation and ridgeline plots to explore how measurement error attenuates regression estimates. The data is also from the [Impact evaluations in data-scarce environments](https://doi.org/10.1016/j.jdeveco.2025.103648) paper though it is a different dataset. By the end of the exercise you will have replicated Figure 2 in that paper. First, you will estimate a baseline model, add simulated noise to a continuous variable, and visualize the loss of statistical significance using `joyplot`.

#### Challenge 12.1 — Baseline Regression and Coefplot

- Load the simulation dataset: `use "$import/mc_data.dta", clear`.
- Run the following regression, which estimates the impact of submergence duration (`durflood`) on yield:
   ```stata
   reg     yield sub omv trv durflood subfld trvfld omvfld ///
               fld_12 sub_12 i.bl_fe, vce(cluster village_id)
   ```
- Store the results using `eststo baseline`.
- Use `coefplot` to visualize the coefficients. Keep only the variables `durflood subfld trvfld omvfld fld_12 sub_12`. Format the plot cleanly, include a vertical reference line at $0$, and export it as `"$answ/challenge-coefplot.png"`.

#### Challenge 12.2 — Monte Carlo Simulation (Measurement Error)

Now, we will test how robust the `subfld` coefficient is if we assume the continuous outcome variable (`yield`) is measured with error.

- Set up a program called `yld_reg` that accepts a noise parameter `np` (e.g. `0.05` for 5% noise). Within the program:
  1. Calculate the mean and standard deviation of `yield`. Multiply these by `np` to get the error mean and standard deviation.
  2. Add normally distributed noise to `yield` using these parameters, and replace `yield` with $0$ if it falls below zero.
  3. Run the exact same baseline regression from Part 12.1.
- Write a simulation loop using `forvalues j = 0/20` to loop through noise levels from 0% to 20% by increments of 1%. For each loop:
  - Run `simulate _b _se dfr=(e(df_r)), reps(100): yld_reg ...` to run 100 regressions on that specific noise level.
  - Save each loop's results to temporary files, and append them all together to form a master dataset of simulation results.

#### Challenge 12.3 — Visualize P-Value Attenuation

- In your appended dataset of 2,100 simulated results, calculate the t-statistic (`_b_subfld / _se_subfld`) and two-tailed p-value (`2 * ttail(dfr, abs(t_subfld))`) for each iteration.
- Generate an indicator `sig` equal to 1 if the p-value is $\le 0.05$, and 0 otherwise.
- Use `joyplot` to visualize the distribution of `p_subfld` grouped by the `noise` level. Add a vertical line at 0.05 (`xline(0.05, lcolor(maroon))`) so that we can see what portion of the distribution falls outside significance.
- Format the plot nicely (using the `white_tableau` scheme or similar) and export your ridgeline plot as `"$answ/challenge-mc.png"`.

1. Looking at your final ridgeline plot, as the amount of added noise to the yield measure increases, what happens to the distribution of p-values? At approximately what percentage of added noise do we entirely lose statistical significance at the 5% level?

---
