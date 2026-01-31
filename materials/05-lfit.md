---
layout: page
element: notes
title: Line Fitting
language: Stata
---

In this lecture, we build on scatter plots and conditional means to **summarize relationships with lines**.

We’ll keep using the Ethiopia LSMS-ISA plot-level data, `eth_allrounds_final`, and focus on:
- Adding fitted lines to scatter plots  
- Interpreting slopes as changes in `Y` per unit of `X`  
- Letting the relationship differ across groups (controlling for a variable)

### Adding a fitted line
We’ll use:
- `yield_kg` – plot-level yield (kg)  
- `nitrogen_kg` – kilograms of nitrogen applied  
- `irrigated` – 1 if plot is irrigated, 0 otherwise  

A basic scatter plot:

```stata
* scatter of yield vs nitrogen
    scatter         yield_kg nitrogen_kg, ///
                        title("Yield vs nitrogen") ///
                        xtitle("Nitrogen (kg)") ///
                        ytitle("Yield (kg)")
```

We can add a straight line summarizing the average relationship between yield and nitrogen using `lfit` in a `twoway` graph:

```stata
* scatter with fitted line
    twoway          (scatter yield_kg nitrogen_kg) ///
                    (lfit    yield_kg nitrogen_kg), ///
                        title("Yield vs nitrogen with fitted line") ///
                        xtitle("Nitrogen (kg)") ///
                        ytitle("Yield (kg)")
```

- The **points** show individual plots.  
- The **line** is the best-fitting straight line (in the least squares sense).

Under the hood this line comes from:

```stata
* regression behind the line
    regress         yield_kg nitrogen_kg
```

From the output:
- Intercept: predicted yield when `nitrogen_kg = 0`  
- Slope: change in predicted yield for a one-unit increase in nitrogen (kg)

You don’t need the full regression course yet; just connect: Fitted line on scatter plot ⇔ simple regression of `Y` on `X`.

You can also add confidence bands using `lfitci` (`ci` for confidence intervals):

```stata
* fitted line with confidence interval
    twoway          (scatter yield_kg nitrogen_kg) ///
                    (lfitci yield_kg nitrogen_kg), ///
                        title("Yield vs nitrogen with CI band")
```

> Do [Exercise 6 - Fitted Line)]({{ site.baseurl }}/exercises/05-lfit/)

### Connecting to conditional means

Another way to summarize the relationship is **conditional means**: average yield for different levels of nitrogen. With lots of distinct nitrogen values, we often **bin** `X`.

Example: create quartiles of nitrogen use and look at mean yield in each bin.

```stata
* create quartiles of nitrogen use
    xtile           nit_q = nitrogen_kg, nq(4)

* mean yield in each nitrogen bin
    tabstat         yield_kg, by(nit_q) stat(mean n)
```

We can plot these conditional means:

```stata
* bar graph of mean yield by nitrogen quartile
    graph bar       (mean) yield_kg, over(nit_q) ///
                        ytitle("Mean yield (kg)") ///
                        xtitle("Nitrogen quartile") ///
                        title("Mean yield by nitrogen use group")
```

Interpretation:

- Each bar is an estimate of \(E[\text{yield} \,|\, \text{nitrogen in bin}]\).  
- The regression **line** is a smooth summary of how those conditional means change with nitrogen.

### Different lines for different groups

Sometimes the relationship between X and Y **differs by group**. For example, the yield–nitrogen relationship may differ between **irrigated** and **rainfed** plots.

We can draw separate fitted lines by group:

```stata
* scatter with separate fitted lines by irrigation status
    twoway          ///
        (scatter yield_kg nitrogen_kg if irrigated == 1, mcolor(blue)) ///
        (lfit    yield_kg nitrogen_kg if irrigated == 1, lcolor(blue)) ///
        (scatter yield_kg nitrogen_kg if irrigated == 0, mcolor(red)) ///
        (lfit    yield_kg nitrogen_kg if irrigated == 0, lcolor(red)), ///
            legend(order(1 "Irrigated plots" 3 "Rainfed plots")) ///
            title("Yield vs nitrogen by irrigation status") ///
            xtitle("Nitrogen (kg)") ///
            ytitle("Yield (kg)")
```

Questions to ask:

- Are the slopes similar for irrigated and rainfed plots?  
- At low nitrogen levels, do the fitted lines give similar yields?  
- At higher nitrogen levels, do irrigated plots gain more?

This is a **visual way** of controlling for a variable: we let the line differ by group.

### Controlling for a variable in a single regression

We can also **control for irrigation** by including it in a regression:

```stata
* regression controlling for irrigation status
    regress         yield_kg nitrogen_kg i.irrigated
```

- The coefficient on `nitrogen_kg` is the **slope**, holding irrigation status fixed.  
- The coefficient on `1.irrigated` is the **difference in intercept** between irrigated and rainfed plots.

We can use these results to draw adjusted lines (optional for now), but the main idea is:

> Adding a group indicator lets the model adjust for level differences between groups while using a common slope.

### A simple workflow for line fitting

When you explore a relationship between two variables:

```stata
* 1. Start with a scatter plot
    scatter         yvar xvar

* 2. Add a fitted line
    twoway          (scatter yvar xvar) (lfit yvar xvar)

* 3. Optionally add a CI band
    twoway          (scatter yvar xvar) (lfitci yvar xvar)

* 4. If you suspect differences by group (e.g., irrigated)
    twoway          (scatter yvar xvar if group == 0) ///
                    (lfit    yvar xvar if group == 0) ///
                    (scatter yvar xvar if group == 1) ///
                    (lfit    yvar xvar if group == 1)
```

In later weeks we’ll build on this to do more formal regression analysis, but for now the goal is to:

- Use lines to summarize **average relationships**, and  
- See how those relationships change **across groups** (controlling for key variables).
