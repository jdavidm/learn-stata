---
layout: page
element: notes
title: Standard Errors
language: Stata
---

In the previous lecture we focused on regression **coefficients** — the point estimates of relationships. This lecture focuses on how much those estimates wiggle from sample to sample, i.e., **standard errors**.

This lecture covers:
- Predicting values and residuals  
- Why default (OLS) standard errors are often wrong  
- Heteroskedasticity and robust standard errors  
- Clustered standard errors  
- Bootstrap standard errors  
- Stata syntax for each approach

We'll continue with simulated yield, fertilizer, and soil quality data so we can visualize what different error structures look like.

### Why standard errors matter

A coefficient tells you the estimated effect size. In the previous lecture and last week's lectures on identification we focused on **bias** in estimating the causal effect. Today we are going to focus on the standard error, which tells you how precise that estimate is. This is known as **inference**. Together they give you:

- **t-statistic** = coefficient / standard error  
- ***p*-value**: probability of seeing your estimate (or larger) if the true effect were zero  
- **Confidence intervals**: a range of plausible values for the true effect

If the standard error is wrong, then the t-statistic, *p*-value, and confidence interval are all wrong — even if the coefficient itself is fine. So getting standard errors right is essential.

### OLS assumptions about the error term

Recall from the last lecture:

```text
Y = β₀ + β₁X + ε
```

The default OLS standard error formula assumes that the error term ε is **independent and identically distributed (i.i.d.)**:

- **Identically distributed**: every observation's error is drawn from the same distribution (same variance)  
- **Independent**: one observation's error tells you nothing about another's

When these assumptions hold, the default standard errors from `reg` are correct. When they don't, the default standard errors can be too small or too large, leading to misleading inference.

### Predicting values and graphing them

After running a regression, Stata can compute **predicted values** (ŷ) and **residuals** (ê) for every observation:

```text
ŷ = β̂₀ + β̂₁X        (the model's prediction)
ê = Y − ŷ            (what the model didn't explain)
```

Let's set up our simulated data and see this in action:

```stata
* simulate DGP with i.i.d. errors
    clear all
    set             seed 12345
    set             obs 2000

    gen             soil_q = rnormal(0, 1)
    gen             fert = (0.5*soil_q + rnormal(0, 1) > 0)
    gen             eps = rnormal(0, 1)
    gen             yield = 2 + 0.5*fert + 1.0*soil_q + eps

* run regression
    reg             yield fert soil_q

* predict fitted values and residuals
    predict         yhat
    predict         resid, residuals
```

The predicted value `yhat` is the model's best guess for each observation. The residual `resid` is the gap between the actual outcome and the prediction — it's everything the model missed.

```stata
* graph: actual vs predicted values
    twoway          (scatter yield yhat, msymbol(Oh) msize(vsmall)) ///
                    (function y = x, range(0 5)), ///
                        title("Actual vs predicted yield") ///
                        xtitle("Predicted yield (ŷ)") ///
                        ytitle("Actual yield") ///
                        legend(label(1 "Observations") label(2 "45° line"))
```

If the model explained everything, all points would fall on the 45° line. The scatter around that line is the residual variation.

> Do [Exercise 4 - Predicting Values]({{ site.baseurl }}/exercises/09-predict/)

### Quick visual check: i.i.d. errors

With the i.i.d. DGP we just created, the residual plot should look like a **uniform cloud** centered on zero — no fan shapes, no patterns:

```stata
* residuals vs fitted values (i.i.d. errors)
    scatter         resid yhat, ///
                        title("Residuals vs fitted: i.i.d. errors") ///
                        ytitle("Residual") ///
                        xtitle("Fitted value") ///
                        yline(0) msymbol(Oh) msize(vsmall)
```

This is what well-behaved errors look like: the vertical spread of points is roughly constant across the x-axis, and there are no visible patterns or clusters.

### Heteroskedasticity

**Heteroskedasticity** means that the variance of ε changes with the value of the predictors. In other words, the "spread" of data around the regression line differs across the range of X.

Why does this break standard errors? The OLS formula estimates **one** variance for the entire sample. If variance actually differs across observations, that single number misrepresents how much the coefficient estimate wiggles across samples.

Important: heteroskedasticity does **not** bias the coefficients — the point estimate is still fine on average. It only makes the standard errors wrong.

#### Simulating heteroskedastic errors

To see what heteroskedasticity looks like, we modify the DGP so the error variance grows with soil quality:

```stata
* simulate DGP with heteroskedastic errors
    clear all
    set             seed 12345
    set             obs 2000

    gen             soil_q = rnormal(0, 1)
    gen             fert = (0.5*soil_q + rnormal(0, 1) > 0)

* error variance increases with soil quality
    gen             eps = rnormal(0, 1 + abs(soil_q))
    gen             yield = 2 + 0.5*fert + 1.0*soil_q + eps

* run regression and get residuals
    reg             yield fert soil_q
    predict         yhat
    predict         resid, residuals
```

#### Quick visual check: heteroskedasticity

```stata
* residuals vs fitted — look for the "fan" shape
    scatter         resid yhat, ///
                        title("Residuals vs fitted: heteroskedastic errors") ///
                        ytitle("Residual") ///
                        xtitle("Fitted value") ///
                        yline(0) msymbol(Oh) msize(vsmall)
```

If the vertical spread of points changes across the x-axis — a fan or funnel shape — you have heteroskedasticity. Compare this to the i.i.d. residual plot above: the spread here is clearly wider for larger fitted values.

> Do [Exercise 5 - Residual Plots]({{ site.baseurl }}/exercises/09-resid-plot/)

### Robust standard errors

The most common fix for heteroskedasticity is **robust** (Huber-White) standard errors. Instead of assuming the same error variance for everyone, robust standard errors let each observation contribute to the variance estimate according to its own residual.

In Stata, just add `, robust`:

```stata
* default OLS standard errors
    reg             yield fert soil_q

* robust (heteroskedasticity-consistent) standard errors
    reg             yield fert soil_q, robust
```

Notice:
- The **coefficients** are identical — robust standard errors change nothing about the point estimates  
- The **standard errors** (and therefore t-stats, *p*-values, CIs) change  
- Sometimes robust SEs are larger (heteroskedasticity made default SEs too optimistic); sometimes they're smaller

Robust standard errors are so common that many applied economists use them by default.

> Do [Exercise 6 - Robust Standard Errors]({{ site.baseurl }}/exercises/09-robust-se/)

### Clustered standard errors

Robust standard errors handle heteroskedasticity but still assume that errors are **independent** across observations. In many research settings, errors within groups are correlated:

- Students in the same **classroom** share a teacher  
- Plots on the same **farm** share management practices  
- People in the same **village** experience the same weather  
- Observations from the same household over **time**

When observations within a group share unobserved factors, their errors are correlated. This is sometimes called **within-cluster correlation**, **autocorrelation within groups**, or **serial correlation**.

If you ignore this clustering, standard errors tend to be **too small** — you think you have more independent information than you actually do.

#### Simulating clustered errors

To see what clustered errors look like, we create a DGP with village-level shocks:

```stata
* simulate DGP with clustered errors (village-level shocks)
    clear all
    set             seed 11111
    set             obs 2000

* 100 villages, 20 plots each
    gen             village = ceil(_n / 20)

* soil quality
    gen             soil_q = rnormal(0, 1)

* fertilizer adoption
    gen             fert = (0.5*soil_q + rnormal(0, 1) > 0)

* village-level shock (shared by all plots in the village)
    gen             v_shock = rnormal(0, 1.5) if mod(_n, 20) == 1
    bysort          village: replace v_shock = v_shock[1]

* individual-level error
    gen             ind_eps = rnormal(0, 1)

* yield includes both shocks
    gen             yield = 2 + 0.5*fert + 1.0*soil_q + v_shock + ind_eps

* run regression and get residuals
    reg             yield fert soil_q
    predict         yhat
    predict         resid, residuals
```

#### Quick visual check: clustered errors

With clustered errors, you can sometimes see residual "blocks" — groups of observations whose residuals are correlated. A helpful way to visualize this is to plot residuals by cluster:

```stata
* residuals vs fitted values
    scatter         resid yhat, ///
                        title("Residuals vs fitted: clustered errors") ///
                        ytitle("Residual") ///
                        xtitle("Fitted value") ///
                        yline(0) msymbol(Oh) msize(vsmall)

* residuals by village (shows within-cluster correlation)
    scatter         resid village, ///
                        title("Residuals by village") ///
                        ytitle("Residual") ///
                        xtitle("Village") ///
                        yline(0) msymbol(Oh) msize(vsmall)
```

In the second plot, you can see that residuals within the same village tend to be on the same side of zero — that's the village-level shock pulling all plots in a village in the same direction.

#### Syntax

```stata
* cluster standard errors at the village level
    reg             yield fert soil_q, vce(cluster village)
```

`vce(cluster village)` tells Stata to allow arbitrary correlation among errors within each village. This accounts for both heteroskedasticity and within-village correlation.

> Do [Exercise 7 - Clustered Standard Errors]({{ site.baseurl }}/exercises/09-cluster-se/)

#### How to choose the cluster level

Some rules of thumb:

1. **Theoretical**: cluster at the level where you think errors are correlated (classroom, household, village)  
2. **Level of treatment**: if treatment is assigned at the village level, cluster at the village level  
3. **Conservative**: if in doubt, cluster at a broader level (but not so broad that you have few clusters)

Clustered standard errors work well when you have **many clusters** (50+ is a common guideline). With few clusters, they can be unreliable. In that case, you may need wild cluster bootstrap methods (an advanced topic for another time).

### Simulation: seeing the consequences for inference

Let's return to the i.i.d. data and compare how standard errors change across methods:

```stata
* regenerate i.i.d. data for comparison
    clear all
    set             seed 12345
    set             obs 2000

    gen             soil_q = rnormal(0, 1)
    gen             fert = (0.5*soil_q + rnormal(0, 1) > 0)
    gen             eps = rnormal(0, 1)
    gen             yield = 2 + 0.5*fert + 1.0*soil_q + eps

* side-by-side comparison
* 1. default
    reg             yield fert soil_q

* 2. robust
    reg             yield fert soil_q, robust
```

Look at how the standard errors (and therefore *p*-values) on `fert` change. The coefficients stay the same across both — only the uncertainty estimates differ.

### Bootstrap standard errors

An entirely different approach to estimating standard errors is the **bootstrap**. The idea is simple:

1. Take your sample of N observations  
2. Draw a new sample of N observations **with replacement** from the original  
3. Estimate the regression on that new sample  
4. Repeat steps 2–3 many times (e.g., 1,000 times)  
5. The standard deviation of the estimates across repetitions is the bootstrap standard error

The bootstrap is very flexible — it makes almost no assumptions about the error distribution.

```stata
* bootstrap standard errors (1000 repetitions)
    bootstrap       _b, reps(1000) seed(9999): ///
                        reg yield fert soil_q
```

Stata's `bootstrap` prefix re-estimates the regression 1,000 times on resampled data and reports the resulting standard errors.

Bootstrap is especially useful when:
- You're unsure about the error structure  
- You're estimating something more complex than a linear regression coefficient  
- You want a check on your robust/clustered SEs

### Quick reference

| Method | Stata syntax | Use when |
|---|---|---|
| Default OLS | `reg Y X` | Errors are i.i.d. (rare in practice) |
| Robust | `reg Y X, robust` | Heteroskedasticity likely |
| Clustered | `reg Y X, vce(cluster G)` | Errors correlated within groups |
| Bootstrap | `bootstrap _b, reps(N): reg Y X` | Flexible; few assumptions |

### Summary

- Default OLS standard errors assume errors are i.i.d. — this is rarely true in practice  
- **Heteroskedasticity** (changing error variance) makes default SEs wrong → use `robust`  
- **Within-cluster correlation** (shared shocks) makes even robust SEs wrong → use `vce(cluster ...)`  
- **Bootstrap** is an alternative that uses resampling instead of formulas  
- Standard error corrections change inference (*p*-values, CIs) but **never** change the point estimates  
- In applied economics, it is common practice to always use at least robust standard errors

Next lecture: additional regression concerns — weights, collinearity, and measurement error.
