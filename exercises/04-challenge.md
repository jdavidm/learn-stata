---
layout: exercise
topic: Graphing
title: Challenge 4
language: Stata
---

**graphf PDF, draw lines, shade, label regions**

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

4\. Shade the lowest 5% of the distribution

To mimic Figure 3.5 more closely, we want to **shade the bottom 5%** of the distribution (the left tail) and label it.

1. Create a variable for the bottom 5% of the CDF and a zero line for shading:

    ```stata
* create a zero line for shading
    gen             zero = 0

* keep only the part of the CDF up to the 5th percentile
    gen             F_wage_shade = F_wage if wage <= `p5'
    ```

2. Draw a graph that shades the area under the CDF up to the 5th percentile, and overlays the full CDF:

    ```stata
twoway              (rarea F_wage_shade zero wage, sort) ///
                    (line  F_wage       wage, sort), ///
                        yline(0.05, lpattern(dash)) ///
                        title("CDF of wage with shaded bottom 5%") ///
                        xtitle("Hourly wage (1988 dollars)") ///
                        ytitle("Cumulative probability")
    ```

- The shaded area shows the **lowest 5%** of the distribution (the “5% section”).  
- The unshaded part of the curve above that corresponds to the **remaining 95%** of workers.

---

## 5. Label the 5% and 95% regions

Finally, add text labels to clearly mark the “5%” and “95%” regions on your graph.

Add `text()` options to the previous `twoway` command. For example:

```stata
twoway              (rarea F_wage_shade zero wage, sort) ///
                    (line  F_wage       wage, sort), ///
                        yline(0.05, lpattern(dash)) ///
                        title("CDF of wage with shaded bottom 5%") ///
                        xtitle("Hourly wage (1988 dollars)") ///
                        ytitle("Cumulative probability") ///
                        text(0.02 2  "5% of workers") ///
                        text(0.6 15 "95% of workers")
```

- The first number in each `text()` is the **y-coordinate** (cumulative probability).
- The second number is the **x-coordinate** (wage).
- The quoted part is the label that will appear on the graph.

You may need to adjust the x-coordinates (`2`, `15`, etc.) to place the labels somewhere that looks good for your graph.

---

## 6. Export your finished figure

Once you’re happy with your graph, export it to a file (e.g., PNG) in your working directory:

```stata
graph export wage_cdf_percentiles.png, replace
```

Make sure your final figure:

- Shows the **CDF of wage**,
- Has a **horizontal line at 5%**,
- Clearly **shades the lowest 5%** of the distribution,
- Labels the **“5%”** and **“95%”** regions in a way that a reader can immediately understand.
