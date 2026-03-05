---
layout: page
element: notes
title: Regression III — Weights, Collinearity, and Measurement Error
language: Stata
---

This lecture covers three “extra” regression concerns that show up constantly in applied work:

1. **weights** (what they mean, and when they matter)
2. **collinearity** (why Stata drops variables, and what to do about it)
3. **measurement error** (why “bad X” biases your coefficients)

These topics correspond to “Additional Regression Concerns” in Chapter 13 of *The Effect*. citeturn10view0

---

## 1. Weights in regression

A “weight” can mean different things depending on the context. In Stata, different weight types exist because the *meaning* matters.

### 1.1 The four Stata weight types (quick intuition)

In Stata, weights are written in square brackets: `[weighttype = weightvar]`.

- `fweight` (frequency weights): each row represents `w` identical observations
- `pweight` (probability weights): inverse probability of selection (survey weights)
- `aweight` (analytic weights): observations are averages with different precision
- `iweight` (importance weights): general-purpose, less common for inference

In most causal/applied survey settings, the relevant one is usually **`pweight`**.

### 1.2 Using probability weights (`pweight`)

```stata
* example syntax: regression with probability weights
    regress         y x z [pweight = w]
```

Interpretation:

- Rows with higher `w` represent more people (or more population weight),
  because they were sampled with lower probability.

Important:

- Using `pweight` changes both coefficient estimates and (especially) standard errors.
- If the data come from a complex survey design, the correct workflow is often `svy:`.

(We’re keeping this light here; you’ll see `svyset` later if the course uses survey datasets.)

### 1.3 A practical rule

- If you see weights in a dataset, don’t guess.
- Find out what type they are (survey probability, frequency, analytic) and why they exist.

---

## 2. Collinearity

**Collinearity** means one predictor is a linear combination of other predictors.

Two levels:

1. **Perfect collinearity** (exact linear relationship)  
   - Stata will *drop* a variable automatically.
2. **Near collinearity** (high correlation)  
   - Stata keeps variables but SEs can get big (imprecise coefficients).

### 2.1 Perfect collinearity: why Stata drops variables

Common causes:

- Including a full set of categories **and** an intercept (dummy variable trap)
- Including a variable twice (or a perfectly redundant transformation)
- Including fixed effects that perfectly absorb another variable

Example (dummy trap):

```stata
* this is fine: Stata uses a baseline category
    regress         wage grade i.race

* this creates redundancy: "no constant" changes the story
    regress         wage grade i.race, noconstant
```

Stata’s factor-variable system is designed to help you avoid the dummy trap by choosing a baseline.

### 2.2 Diagnosing near collinearity: `vif`

After a regression, you can examine variance inflation factors (VIFs):

```stata
    sysuse          nlsw88, clear
    regress         wage grade ttl_exp age
    vif
```

Rules of thumb (not laws):

- VIF around 1–5: usually fine
- VIF 10+: pay attention (often a sign of redundant controls)

But remember:

- high VIF is a *precision* problem (SEs get bigger), not necessarily a *bias* problem.

### 2.3 What to do about collinearity

- Don’t add controls “because you can.” Add controls for a reason (design-based).
- If two controls measure the same thing, consider dropping one.
- For interactions, consider centering continuous variables if interpretation is awkward
  (centering does not fix collinearity by itself, but can help interpret intercepts).

---

## 3. Measurement error

Measurement error is one of the most important “hidden” problems in regression.

### 3.1 Classical measurement error in X (attenuation bias)

Suppose the true regressor is \(X^*\), but you observe \(X = X^* + \text{noise}\).

If the measurement error is “classical” (noise is unrelated to \(X^*\) and other variables), then:

- the slope coefficient on \(X\) is biased toward **zero** (attenuation)
- you understate the real relationship

This is especially common when X is:

- self-reported income
- plot size (self-reported vs GPS)
- “ability” proxies
- noisy index variables

### 3.2 Measurement error in Y

Measurement error in the outcome \(Y\) typically:

- increases residual variance,
- increases SEs,
- but (under classical assumptions) does not bias slopes the way measurement error in X does.

### 3.3 What to do about measurement error (toolbox, not magic)

Options include:

- **better measurement** (best answer, often expensive)
- **multiple measures** (use repeated measurements; compare reliability)
- **proxies** (use a better proxy than the worst measure)
- **instrumental variables** (when you have a valid instrument; later in the course)

A very practical applied habit:

- If you have *two* measures of the same concept (e.g., plot size GPS and plot size self-report),
  run regressions both ways and see how sensitive results are.

---

## 4. Putting it together: “regression hygiene” checklist

Before you trust a regression table, ask:

1. **What is the unit of observation?** person? household? plot-year?
2. **Should SEs be robust or clustered?** (`vce(robust)` / `vce(cluster ...)`)
3. **Are weights required?** If yes, what do they mean (`pweight` vs `fweight`)?
4. **Any obvious collinearity?** Did Stata drop variables? Are VIFs huge?
5. **Any key variables measured with lots of noise?** If yes, interpret cautiously.

These are not “advanced topics.” They are the difference between regression output that is *useful* and regression output that is *misleading*.
