---
layout: exercise
topic: Graphing
title: Percentiles
language: Stata
---


Using the `nlsw88` data,

1\. Use `sum, detail` to get detailed summary statistics for `wage`. Store the value of the 5th and 95th percentile as `locals` called `p5` and `p95`. Finally, tell stata to `display` two lines of text, followed by the actual value of the 5th and 95th using the values stored in `p5` and `p95`:
   1. 5th percentile of wage:
   2. 95th percentile of wage:

When we use `kdensity` we are drawing the **probability density function** (PDF). Sometimes it’s convenient to work with the **cumulative distribution function** (CDF) rather than the density. The CDF shows, for each wage value, the **fraction of workers with wage less than or equal to that value**.

2\. Use the `cumul` command to create the empirical CDF of wage: `cumul wage, gen(F_wage)`. Then draw the CDF using the command `twoway line`. Note that this is our first time graphing more than one variable. You will need to include `F_wage` and then `wage`. You will also need to use the option `sort` to get the smooth CDF that we are looking for.
   - Title the graph "Cumulative distribution of wage"
   - Title the x-axis "Hourly wage (1988 dollars)"
   - Title the y-axis "Cumulative probability"

3\. Now we will add a line to the graph at 5% (0.05 on the y-axis) to mark the 5th percentile using `yline`. Recall in the lecture we added vertical lines using `xline`.
   - Give the line a `dash` pattern
   - Color the line `maroon`
   - Title this new graph "CDF of wage with 5% cutoff"
