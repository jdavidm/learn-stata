---
layout: page
element: notes
title: Standard Errors
language: Stata
---

In the previous lecture we focused on regression **coefficients** — the point estimates of relationships. This lecture focuses on how much those estimates **wiggle from sample to sample**, i.e., standard errors.

This lecture covers:
- Why default (OLS) standard errors are often wrong  
- Heteroskedasticity and robust standard errors  
- Clustered standard errors  
- Bootstrap standard errors  
- Stata syntax for each approach

We'll keep using the Ethiopia LSMS-ISA plot-level data, `eth_allrounds_final`.

### Why standard errors matter

A coefficient tells you the estimated effect size. The standard error tells you how **precise** that estimate is. Together they give you:

- **t-statistic** = coefficient / standard error  
- **p-value**: probability of seeing your estimate (or larger) if the true effect were zero  
- **Confidence intervals**: a range of plausible values for the true effect

If the standard error is wrong, then the t-statistic, p-value, and confidence interval are all wrong — even if the coefficient itself is fine. So getting standard errors right is essential.

### OLS assumptions about the error term

Recall from the last lecture:

```text
Y = β₀ + β₁X + ε
```

The default OLS standard error formula assumes that the error term ε is **independent and identically distributed (i.i.d.)**:

- **Identically distributed**: every observation's error is drawn from the same distribution (same variance)  
- **Independent**: one observation's error tells you nothing about another's

When these assumptions hold, the default standard errors from `regress` are correct. When they don't, the default standard errors can be too small or too large, leading to misleading inference.

### Heteroskedasticity

**Heteroskedasticity** means that the variance of ε changes with the value of the predictors. In other words, the "spread" of data around the regression line differs across the range of X.

Example: in our plot-level data, small plots may have very consistent yields while large plots have wildly variable yields. The error variance is bigger for large plots.

Why does this break standard errors? The OLS formula estimates **one** variance for the entire sample. If variance actually differs across observations, that single number misrepresents how much the coefficient estimate wiggles across samples.

Important: heteroskedasticity does **not** bias the coefficients — the point estimate is still fine on average. It only makes the standard errors wrong.

#### Quick visual check

Plotting residuals against fitted values can reveal heteroskedasticity:

```stata
* run regression
    regress         yield_kg nitrogen_kg i.irr plot_area_GPS

* predict residuals
    predict         resid, residuals

* predict fitted values
    predict         yhat, xb

* plot residuals vs fitted values
    scatter         resid yhat, ///
                        title("Residuals vs fitted values") ///
                        ytitle("Residual") ///
                        xtitle("Fitted value") ///
                        yline(0) msymbol(Oh) msize(vsmall)
```

If the vertical spread of points changes across the x-axis — a fan or funnel shape — you have heteroskedasticity.

### Robust standard errors

The most common fix for heteroskedasticity is **robust** (Huber-White) standard errors. Instead of assuming the same error variance for everyone, robust standard errors let each observation contribute to the variance estimate according to its own residual.

In Stata, just add `, robust`:

```stata
* default OLS standard errors
    regress         yield_kg nitrogen_kg i.irr plot_area_GPS

* robust (heteroskedasticity-consistent) standard errors
    regress         yield_kg nitrogen_kg i.irr plot_area_GPS, robust
```

Notice:
- The **coefficients** are identical — robust standard errors change nothing about the point estimates  
- The **standard errors** (and therefore t-stats, p-values, CIs) change  
- Sometimes robust SEs are larger (heteroskedasticity made default SEs too optimistic); sometimes they're smaller

Robust standard errors are so common that many applied economists use them by default.

### Clustered standard errors

Robust standard errors handle heteroskedasticity but still assume that errors are **independent** across observations. In many research settings, errors within groups are correlated:

- Students in the same **classroom** share a teacher  
- Plots on the same **farm** share management practices  
- People in the same **village** experience the same weather  

When observations within a group share unobserved factors, their errors are correlated. This is sometimes called **within-cluster correlation** or **autocorrelation within groups**.

If you ignore this clustering, standard errors tend to be **too small** — you think you have more independent information than you actually do.

#### Syntax

```stata
* cluster standard errors at the household level
    regress         yield_kg nitrogen_kg i.irr plot_area_GPS, ///
                        vce(cluster hhid)
```

`vce(cluster hhid)` tells Stata to allow arbitrary correlation among errors within each value of `hhid`. This accounts for both heteroskedasticity and within-household correlation.

#### How to choose the cluster level

Some rules of thumb:

1. **Theoretical**: cluster at the level where you think errors are correlated (classroom, household, village)  
2. **Level of treatment**: if treatment is assigned at the village level, cluster at the village level  
3. **Conservative**: if in doubt, cluster at a broader level (but not so broad that you have few clusters)

Clustered standard errors work well when you have **many clusters** (50+ is a common guideline). With few clusters, they can be unreliable. In that case, you may need wild cluster bootstrap methods (an advanced topic for another time).

### Simulation: seeing why clustering matters

```stata
* simulate data with correlated errors within villages
    clear all
    set             seed 11111
    set             obs 500

* 50 villages, 10 people each
    gen             village = ceil(_n / 10)

* village-level shock (common to everyone in the village)
    gen             v_shock = rnormal(0, 1) if mod(_n, 10) == 1
    bysort          village: replace v_shock = v_shock[1]

* individual-level error
    gen             eps = rnormal(0, 1)

* treatment (randomly assigned)
    gen             treat = (runiform() < 0.5)

* outcome: true effect = 1.0
    gen             Y = 3 + 1.0*treat + v_shock + eps

* default SEs (ignores clustering — too small)
    regress         Y treat

* clustered SEs (accounts for village-level correlation)
    regress         Y treat, vce(cluster village)
```

Compare the standard error on `treat` across the two regressions. The default SE is too small because it treats all 500 observations as independent, when really there are only 50 independent clusters.

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
                        regress yield_kg nitrogen_kg i.irr
```

Stata's `bootstrap` prefix re-estimates the regression 1,000 times on resampled data and reports the resulting standard errors.

Bootstrap is especially useful when:
- You're unsure about the error structure  
- You're estimating something more complex than a linear regression coefficient  
- You want a check on your robust/clustered SEs

### Comparing standard error methods

```stata
* side-by-side comparison
* 1. default
    regress         yield_kg nitrogen_kg i.irr plot_area_GPS

* 2. robust
    regress         yield_kg nitrogen_kg i.irr plot_area_GPS, robust

* 3. clustered
    regress         yield_kg nitrogen_kg i.irr plot_area_GPS, ///
                        vce(cluster hhid)
```

Look at how the standard errors (and therefore p-values) on `nitrogen_kg` change. The coefficients should stay the same or nearly the same across all three.

### Quick reference

| Method | Stata syntax | Use when |
|---|---|---|
| Default OLS | `regress Y X` | Errors are i.i.d. (rare in practice) |
| Robust | `regress Y X, robust` | Heteroskedasticity likely |
| Clustered | `regress Y X, vce(cluster G)` | Errors correlated within groups |
| Bootstrap | `bootstrap _b, reps(N): regress Y X` | Flexible; few assumptions |

### Summary

- Default OLS standard errors assume errors are i.i.d. — this is rarely true in practice  
- **Heteroskedasticity** (changing error variance) makes default SEs wrong → use `robust`  
- **Within-cluster correlation** (shared shocks) makes even robust SEs wrong → use `vce(cluster ...)`  
- **Bootstrap** is an alternative that uses resampling instead of formulas  
- Standard error corrections change inference (p-values, CIs) but **never** change the point estimates  
- In applied economics, it is common practice to always use at least robust standard errors

Next lecture: additional regression concerns — weights, collinearity, and measurement error.
