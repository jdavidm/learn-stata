---
layout: page
element: notes
title: Regression II — Standard Errors and Inference
language: Stata
---

Regression gives you coefficient estimates (the “line”), but it also gives you uncertainty measures:

- **standard errors**
- **confidence intervals**
- **t-statistics**
- **p-values**

This lecture is about where those uncertainty numbers come from, and why you should treat the default standard errors as “guilty until proven innocent.”

These notes track the “Your Standard Errors Are Probably Wrong” section of Chapter 13 in *The Effect*. citeturn10view0

---

## 1. What is a standard error?

A **standard error (SE)** is the estimated standard deviation of an estimator’s sampling distribution.

Informally:

- If you could re-draw the sample over and over,
- you’d get different \(\hat\beta\) each time,
- and the SE tells you how much \(\hat\beta\) would typically vary.

Regression output typically reports:

\[
\hat\beta \pm 1.96 \times SE(\hat\beta)
\]

as a 95% confidence interval (large-sample approximation).

---

## 2. Why the default SEs can be wrong

In the simplest regression model, the usual SE formulas assume (among other things):

1. **independent errors** across observations
2. **homoskedasticity**: constant error variance (same spread of residuals for all \(X\))

Those assumptions are often violated in applied work, which means:

- your **standard errors are biased**
- and your hypothesis tests / confidence intervals are unreliable

This is a central warning in *The Effect*: the coefficient estimates might be fine, but the *uncertainty* calculations can be wrong if the error structure is wrong. citeturn10view0

---

## 3. Heteroskedasticity and robust SEs

**Heteroskedasticity** means the variance of the error changes with \(X\) or across groups.

Classic symptom: residuals “fan out” as \(X\) increases.

### 3.1 Diagnose visually (quick-and-dirty)

```stata
* example data
    sysuse          nlsw88, clear

* baseline regression
    regress         wage grade ttl_exp

* residuals vs fitted values
    predict         wage_hat
    predict         u_hat, resid

    twoway          (scatter u_hat wage_hat), ///
                        yline(0) ///
                        title("Residuals vs fitted values")
```

If the residual variance clearly changes with fitted values, homoskedasticity is unlikely.

### 3.2 Use heteroskedasticity-robust SEs

In Stata:

```stata
* heteroskedasticity-robust standard errors
    regress         wage grade ttl_exp, vce(robust)
```

`vce(robust)` computes **Huber–White** (“sandwich”) robust SEs.

Rule of thumb:

- If you do not have a strong reason to believe homoskedasticity,
  use `vce(robust)`.

---

## 4. Clustering: correlated errors within groups

Often observations are independent **across clusters** but correlated **within clusters**, e.g.,

- students within the same school
- individuals within the same household
- plots within the same village
- firms over time (panel data)

If you ignore within-cluster correlation, your SEs are usually **too small** (false precision).

### 4.1 Cluster-robust SEs in Stata

```stata
* cluster by an identifier (example: idcode in nlsw88)
    regress         wage grade ttl_exp, vce(cluster idcode)
```

Interpretation:

- You are allowing arbitrary correlation of errors within `idcode`,
- but assuming independence across different `idcode`.

Practical note:

- Cluster-robust methods work best when you have “enough” clusters (rule-of-thumb: 30+),
  but context matters.

---

## 5. Standard errors for nonlinear functions: use `margins`

When you fit models with:

- interactions
- polynomials
- log transforms
- nonlinear predictions

…the effect you care about is often a function of coefficients, not a single coefficient.

Stata’s `margins` will compute:

- the quantity of interest, and
- a standard error using the delta method (and respecting your chosen `vce()`).

Example: interaction model

```stata
* model with interaction
    regress         wage c.grade##i.union ttl_exp, vce(robust)

* average marginal effect of grade, by union status
    margins         union, dydx(grade)

* plot the marginal effects
    marginsplot, ///
        title("Marginal effect of education, by union status") ///
        ytitle("d(wage)/d(grade)")
```

---

## 6. A decision workflow for SEs

When you run a regression, ask:

1. **Are errors plausibly homoskedastic and independent?**
   - If yes, default SEs might be okay.
   - If no, move to robust/clustered.

2. **Is there clustering or repeated sampling?**
   - If observations share a context (classroom, household, village, firm, county),
     use `vce(cluster cluster_id)`.

3. **Are you using weights or survey design?**
   - Then you may need `pweight` and survey commands (`svy:`), covered next lecture.

Quick summary commands:

```stata
* default (rarely a good idea in applied work)
    regress         y x z

* robust
    regress         y x z, vce(robust)

* cluster-robust
    regress         y x z, vce(cluster cluster_id)
```

Next lecture: **additional concerns** — weights, collinearity, and measurement error.

### Summary

- Standard errors convey the uncertainty surrounding your specific coefficient estimate.
- Default standard errors often rely on theoretically flawed assumptions (like homoskedasticity).
- Consider default assumptions 'guilty until proven innocent' and use modern alternative variances (e.g., robust, clustered).
