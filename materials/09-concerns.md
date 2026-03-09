---
layout: page
element: notes
title: Weights, Collinearity, and Measurement Error
language: Stata
---

The previous two lectures covered regression mechanics (coefficients, controls) and inference (standard errors). This lecture addresses three additional concerns that come up frequently in applied work:

- **Sample weights** — adjusting for unequal sampling probabilities  
- **Collinearity** — when predictors are too similar to each other  
- **Measurement error** — when the variables you have aren't quite the variables you want

### Sample weights

Most social-science datasets are not simple random samples of the population. Some people (or plots, or firms) are more likely to end up in the sample than others:

- Urban households may be oversampled relative to rural ones  
- Larger firms may be easier to survey  
- Follow-up surveys may lose some respondents (attrition)

If certain groups are over- or under-represented, your unweighted regression describes the **sample** well but may not describe the **population**. Sample weights fix this by giving more importance to under-represented observations and less to over-represented ones.

#### How weights work

In a weighted regression, each observation's contribution to the OLS objective function is scaled by a weight *w*. Observations with higher weights have more influence on the estimated coefficients.

The most common type is **inverse probability weights**: each observation is weighted by the inverse of the probability that it was included in the sample. If urban households had a 20% chance of being sampled and rural households had a 5% chance, then each rural household gets a weight 4× larger than each urban household, restoring population proportions.

Many large surveys (census, DHS, LSMS) come with pre-computed weights. Use them.

#### Stata syntax

Stata has several weight types. The two most relevant for regression are:

```stata
* analytic (aweight): weighted least squares
    reg             yield fert [aweight = plot_weight]

* frequency/probability (pweight): survey sampling weights
    reg             yield fert [pweight = hh_weight], robust
```

- `aweight` treats the weight as an importance measure (weighted least squares)  
- `pweight` treats the weight as an inverse probability weight and automatically adjusts the standard errors for the survey design

When using survey weights from a dataset like the LSMS, `pweight` is almost always the correct choice.

#### The `svyset` and `svy:` approach

For surveys with complex designs (stratification, clustering, and weights), Stata has a dedicated survey framework:

```stata
* set the survey design
    svyset          ea_id [pweight = hh_weight], strata(strata_id)

* run a survey-weighted regression
    svy:            reg yield fert soil_q
```

`svyset` tells Stata about the primary sampling unit (`ea_id`), strata, and weights. After that, prefixing any estimation command with `svy:` automatically applies all three design features. This is the gold standard for survey data.

#### When to weight (and when not to)

- **Weight** when you want your estimates to represent a well-defined population and your sample is not drawn at random  
- **Don't weight** when your sample is effectively random, or when you are estimating a causal effect and the weighting is not related to treatment or outcome (in that case, weighting adds noise without reducing bias)

When in doubt, run both weighted and unweighted regressions and compare. Large differences signal that sample composition matters for your question.

### Collinearity

Collinearity (sometimes "multicollinearity") means that one predictor in your model is strongly predicted by a linear combination of the other predictors.

**Perfect collinearity**: one variable is an exact linear function of others. Example: including both `Winter` and `NotWinter` in a model with an intercept. Stata will drop one variable automatically and tell you so.

**High collinearity**: predictors are very highly (but not perfectly) correlated. Example: including two fertilizer types that are always applied together, or including age **and** birth year.

#### Why it's a problem

High collinearity inflates standard errors. The intuition:

- OLS identifies each coefficient from the variation in X that is **not** explained by the other predictors  
- If two predictors are nearly identical, there is very little independent variation left for each one  
- Little independent variation → the estimate bounces around a lot from sample to sample → large standard error

Collinearity does **not** bias the coefficients. It just makes them imprecise — wide confidence intervals and low power to detect effects.

#### Diagnosing collinearity in Stata

After running a regression, use `estat vif` to compute the **Variance Inflation Factor** (VIF):

```stata
* simulate two highly correlated predictors
    clear all
    set             seed 77777
    set             obs 500

    gen             x1 = rnormal(0, 1)
    gen             x2 = x1 + rnormal(0, 0.1)   // almost the same as x1

* outcome depends on x1 only (true β₁ = 2, true β₂ = 0)
    gen             yield = 1 + 2*x1 + 0*x2 + rnormal(0, 1)

* regression with both: huge standard errors
    reg             yield x1 x2
    estat           vif
```

- VIF = 1: no collinearity  
- VIF > 5–10: concerning  
- VIF = ∞: perfect collinearity (Stata will have dropped a variable)

> Do [Exercise 8 - Collinearity and VIF]({{ site.baseurl }}/exercises/09-vif/)

#### What to do about collinearity

1. **Drop one of the collinear variables**. If `x1` and `x2` are nearly identical, include just one  
2. **Combine variables**. Create an index or total  
3. **Accept it**. If you must include both variables for theoretical reasons, acknowledge that individual coefficients are imprecise but note that the **joint** effect may still be well-estimated (test joint significance with `test x1 x2`)

#### Simulation: collinearity in action

```stata
* drop the redundant predictor: precise estimate
    reg             yield x1
```

Notice that the coefficients on `x1` and `x2` in the first regression are wildly imprecise and may not individually be significant, even though their true joint effect is strong. The second regression, with only `x1`, recovers the true effect precisely.

### Measurement error

In practice, the variables in your dataset are rarely exact. Common sources of imprecision:

- **Rounding** — a height recorded as "6 feet" is really 5 feet 11.3 inches  
- **Recall error** — a respondent reports last month's expenditure from memory  
- **Proxy variables** — you want to measure "ability" but you observe a test score, which is ability plus noise

All of these are forms of **measurement error** (also called errors-in-variables): what you measure is the true value plus some noise.

```text
X_observed = X_true + noise
```

#### Classical measurement error

The simplest case is **classical measurement error**, where the noise is independent of the true value. When this happens:

- Measurement error in Y (the outcome) is mostly harmless — it increases residual variance but does not bias coefficients  
- Measurement error in X (a predictor) **biases the coefficient toward zero** — this is called **attenuation bias**

If X is measured with noise, some of the variation in X is random and unrelated to Y. OLS attributes all of X's variation to the coefficient, dragging the estimated slope toward zero because the noisy part isn't related to Y.

##### Simulation: attenuation bias

```stata
* simulate classical measurement error
    clear all
    set             seed 88888
    set             obs 1000

* true predictor
    gen             soil_q_true = rnormal(0, 1)

* outcome (true beta = 3)
    gen             yield = 1 + 3*soil_q_true + rnormal(0, 1)

* measured predictor with noise
    gen             soil_q_noisy = soil_q_true + rnormal(0, 1)

* regression with true X: recovers β ≈ 3
    reg             yield soil_q_true

* regression with noisy X: β shrinks toward 0
    reg             yield soil_q_noisy
```

The second regression gives a coefficient noticeably smaller than 3. This is attenuation bias.

#### Non-classical measurement error

When the measurement error is **related to the true value**, things get worse. The bias can go in any direction — toward zero, away from zero, or even flip sign.

Examples of non-classical measurement error:

- **Self-reported income**: low-income respondents may round up, high-income respondents may round down  
- **Binary mismeasurement**: if the true variable is 0/1, the error can only be 0, +1, or −1, and which is possible depends on the true value

Non-classical measurement error is harder to diagnose and harder to fix. The main takeaway: **think carefully about how your variables were measured** and whether the noise is likely to be related to the true value.

#### What to do about measurement error

| Situation | Practical response |
|---|---|
| Classical ME in Y | Mostly harmless — note reduced R² |
| Classical ME in X | Coefficients are attenuated; treat estimate as a **lower bound** on the true effect |
| Non-classical ME | Bias direction unknown; think hard about the measurement process |
| You have a better measure | Use it! Even a noisy improvement helps |
| You have multiple measures | Average or combine them to reduce noise |

In most applied work, researchers acknowledge measurement error and interpret attenuated coefficients as conservative (lower-bound) estimates. More advanced fixes (instrumental variables, errors-in-variables estimators) exist but are beyond this course.

### Summary

- **Sample weights** correct for non-random sampling so estimates represent the population; use `pweight` or `svy:` in Stata when working with survey data  
- **Collinearity** inflates standard errors (but does not bias coefficients); diagnose with `estat vif` and consider dropping or combining redundant predictors  
- **Measurement error** in a predictor attenuates the coefficient toward zero (classical case) or causes unpredictable bias (non-classical case); think carefully about data quality

These three topics round out our introduction to regression. Together with the previous lectures on coefficients, controls, and standard errors, you now have the core toolkit for applied regression analysis in Stata.
