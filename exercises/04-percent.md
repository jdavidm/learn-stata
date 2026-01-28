---
layout: exercise
topic: Graphing
title: Percentiles
language: Stata
---

These exercises help you connect **percentiles** (5th and 95th) to the idea of **tail areas**, similar to Figure 3.5 in *The Effect*. You will work with the `nlsw88` data and the `wage` variable.

Work in a **do-file**, and include comments so you can remember what you did when you come back later.

---

## Setup

Start your do-file with:

```stata
* load data for percentile exercise
    sysuse          nlsw88, clear
```

You can then run the code for each part in sequence.

---

## 1. Compute the 5th and 95th percentiles

1. Use `sum, detail` to get detailed summary statistics for `wage`:

    ```stata
    sum             wage, detail
    ```

2. In the output, find the **5th percentile** and **95th percentile** of `wage`.

3. Store these percentiles in local macros so you can use them later:

    ```stata
    sum             wage, detail
    local           p5  = r(p5)
    local           p95 = r(p95)
    ```

4. (Optional) Display them to check:

    ```stata
    display        "5th percentile of wage:  " `p5'
    display        "95th percentile of wage: " `p95'
    ```

In your notes, write a short sentence explaining what the 5th and 95th percentiles mean in words, e.g.:

> “5% of workers earn less than about \$X per hour, and 95% earn less than about \$Y per hour.”

---

## 2. Create the empirical cumulative distribution function (CDF)

To draw something similar to Figure 3.5, it’s convenient to work with the **cumulative distribution function** (CDF) rather than the density. The CDF shows, for each wage value, the **fraction of workers with wage less than or equal to that value**.

1. Use the `cumul` command to create the empirical CDF of wage:

    ```stata
    cumul           wage, gen(F_wage)
    ```

    - `F_wage` will take values between 0 and 1 and represents the cumulative probability.

2. Draw the CDF:

    ```stata
    twoway          (line F_wage wage, sort), ///
                        title("Cumulative distribution of wage") ///
                        xtitle("Hourly wage (1988 dollars)") ///
                        ytitle("Cumulative probability")
    ```

This graph shows, for each wage on the x-axis, the fraction of workers with wage less than or equal to that amount on the y-axis.

---

## 3. Add a horizontal line at 5%

Now add a **horizontal line at 5%** (0.05 on the y-axis) to mark the 5th percentile.

```stata
twoway              (line F_wage wage, sort), ///
                        yline(0.05, lpattern(dash)) ///
                        title("CDF of wage with 5% cutoff") ///
                        xtitle("Hourly wage (1988 dollars)") ///
                        ytitle("Cumulative probability")
```

- The dashed horizontal line at 0.05 shows where **5%** of the distribution lies.
- The point where the CDF crosses that line corresponds to the **5th percentile** of wage.

---

## 4. Shade the lowest 5% of the distribution

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
