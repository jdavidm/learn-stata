---
layout: page
element: notes
title: Regression I — Simple and Multiple Regression
language: Stata
---

In Week 9 we move from **drawing fitted lines** to actually **estimating and interpreting regression models**.

Regression is just a way of summarizing conditional means with a function. In this course we’ll mostly use regression as a tool for:

- describing relationships (prediction / association), and
- estimating causal effects (only when the design supports that interpretation).

These notes follow Chapter 13 of *The Effect* (especially “The Basics of Regression” and “Getting Fancier with Regression”). citeturn10view0  
We’ll also mirror Stata’s “Simple linear regression” walkthrough, but we’ll keep the focus on *interpretation* and *workflow*. citeturn8view1

---

## 1. The regression model, in words

Start with two variables:

- outcome (dependent variable): \(Y\)
- predictor (independent variable): \(X\)

A **simple linear regression** assumes the conditional mean of \(Y\) given \(X\) is a straight line:

\[
E[Y \mid X] = \beta_0 + \beta_1 X
\]

Interpretation:

- \(\beta_0\) is the predicted value of \(Y\) when \(X = 0\) (an intercept; sometimes meaningful, sometimes not).
- \(\beta_1\) is the change in the predicted value of \(Y\) when \(X\) increases by 1.

In Stata, the command is `regress` (abbrev. `reg`).

---

## 2. A basic workflow in Stata

We’ll use the system dataset `nlsw88` (same dataset we used for distributions earlier).

```stata
* load example data
    sysuse          nlsw88, clear

* quick look
    describe
    sum             wage grade age ttl_exp
```

### 2.1 Visualize first: scatter + fitted line

```stata
* scatter with fitted line (connect to last week)
    twoway          (scatter wage grade) ///
                    (lfit    wage grade), ///
                        title("Wage vs education") ///
                        xtitle("Years of schooling (grade)") ///
                        ytitle("Hourly wage (1988 dollars)")
```

This is the same idea as Stata’s official example: look at the cloud of points before you fit the line. citeturn8view1

### 2.2 Estimate the line

```stata
* simple regression: wage on grade
    regress         wage grade
```

Read the coefficient table:

- The row for `grade` is your \(\hat\beta_1\) (“slope”).
- The row for `_cons` is your \(\hat\beta_0\) (“intercept”).

---

## 3. Interpreting coefficients

Suppose Stata reports:

- `grade` coefficient = 0.5

Then (association interpretation):

> Each additional year of schooling is associated with about **$0.50 higher hourly wage**, on average.

Key habit:

- **Always include units** (dollars/hour, years, kg, hectares, etc.)
- **Always say “associated with”** unless you’ve argued for a causal interpretation.

---

## 4. Multiple regression (a.k.a. “adjusting for controls”)

Most applied work uses multiple regression:

\[
E[Y \mid X, Z] = \beta_0 + \beta_1 X + \beta_2 Z
\]

Now \(\beta_1\) is the change in predicted \(Y\) when \(X\) increases by 1 **holding \(Z\) fixed**.

This “holding fixed” interpretation is what *The Effect* motivates as **statistical adjustment** (often called “controlling for” variables). citeturn10view0

### 4.1 Example: add experience as a control

```stata
* multiple regression: adjust for experience
    regress         wage grade ttl_exp
```

Interpretation of `grade` coefficient now:

> The association between schooling and wage **among people with the same experience**.

This does **not** automatically make the coefficient causal. “Control variables” help only if they close relevant back doors (causal paths) and don’t open new problems.

---

## 5. Categorical controls: factor variables (`i.`)

When a variable is categorical (race, region, treatment group), you usually want indicator (dummy) variables.

In Stata you almost never hand-make dummies. Use **factor-variable notation**:

```stata
* adjust for race as a set of indicators
    regress         wage grade ttl_exp i.race
```

Stata will:

- pick a reference category (baseline),
- include indicator variables for the other categories,
- and report each category’s difference from the baseline.

---

## 6. “Getting fancier”: interactions and polynomials

Chapter 13 spends a lot of time on “getting fancier,” mostly because **the coefficients stop being interpretable one-at-a-time** once you add nonlinear terms and interactions. citeturn10view0

### 6.1 Quadratic (polynomial) terms

If the relationship bends (not a straight line), add powers of \(X\).

```stata
* quadratic in experience (ttl_exp)
    regress         wage grade c.ttl_exp##c.ttl_exp
```

Notes:

- `c.` tells Stata the variable is continuous.
- `##` includes: `ttl_exp`, `ttl_exp^2`, and (if interacting) both main effects.

Interpretation:

- the effect of `ttl_exp` now depends on the value of `ttl_exp`.

### 6.2 Interactions (effect differs by group)

Example: education returns differ by union status.

```stata
* interaction between grade and union
    regress         wage c.grade##i.union ttl_exp
```

Interpretation idea:

- `grade` effect for the baseline group is the `grade` coefficient.
- the interaction term is the *difference* in the `grade` effect between union and non-union.

A safer workflow than “reading the coefficients” is to use `margins`:

```stata
* predicted wage at different grade values by union status
    margins         union, at(grade=(8(2)18)) 

* plot those predictions
    marginsplot, ///
        title("Predicted wage by education, by union status") ///
        xtitle("Grade") ytitle("Predicted wage")
```

---

## 7. Prediction: fitted values and residuals

After any regression:

- `predict` gives you fitted values \(\hat{Y}\) and residuals \(\hat{u}\).

```stata
* predict fitted values and residuals
    predict         wage_hat
    predict         u_hat, resid

* check residual spread
    sum             u_hat
```

Residuals are the part of the outcome that your model did not explain.

---

## 8. A regression checklist (what you should be able to do)

By the end of this lecture, you should be comfortable with:

1. Running a simple regression with `regress y x`
2. Interpreting the slope and intercept with units
3. Adding controls: `regress y x z`
4. Using factor variables: `i.var` and `c.var`
5. Using interactions/polynomials with `##`
6. Using `margins` / `marginsplot` for interpretation

Next lecture: **standard errors** — what they are, where they come from, and why the defaults are often wrong.
