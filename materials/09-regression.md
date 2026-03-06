---
layout: page
element: notes
title: Single and Multivariate Regression
language: Stata
---

Last week we used simulations and conditional means to think about identification. This week we formalize that work with **regression**, the most widely used tool for statistical adjustment in the social sciences.

This lecture covers:
- The `regress` command for simple (single-variable) regression  
- Interpreting coefficients, standard errors, and p-values  
- Adding controls (multivariate regression)  
- Connecting regression to the DAG / identification ideas from Week 8  
- Getting fancier: factor variables, interactions, and polynomials

We'll continue to use the Ethiopia LSMS-ISA plot-level data, `eth_allrounds_final`.

### From fitted lines to `regress`

In Week 5 we added fitted lines to scatter plots with `lfit`. Under the hood, that line comes from an OLS regression.

```stata
* scatter with fitted line (Week 5 review)
    twoway          (scatter yield_kg nitrogen_kg) ///
                    (lfit    yield_kg nitrogen_kg), ///
                        title("Yield vs nitrogen") ///
                        xtitle("Nitrogen (kg)") ///
                        ytitle("Yield (kg)")

* the regression behind that line
    regress         yield_kg nitrogen_kg
```

```text
. reg yield_kg nitrogen_kg

      Source |       SS           df       MS      Number of obs   =    63,411
-------------+----------------------------------   F(1, 63409)     =     16.78
       Model |   947008213         1   947008213   Prob > F        =    0.0000
    Residual |  3.5791e+12    63,409  56444777.9   R-squared       =    0.0003
-------------+----------------------------------   Adj R-squared   =    0.0002
       Total |  3.5801e+12    63,410  56458822.4   Root MSE        =      7513

------------------------------------------------------------------------------
    yield_kg | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
 nitrogen_kg |  -3.170407   .7740162    -4.10   0.000     -4.68748   -1.653334
       _cons |   3218.218   29.92708   107.54   0.000     3159.561    3276.875
------------------------------------------------------------------------------
```

Key parts of the output:

- **Coefficient on `nitrogen_kg`** (the slope): the predicted change in yield for each additional kilogram of nitrogen applied  
- **`_cons`** (the intercept): predicted yield when nitrogen equals zero  
- **Std. err.**: the estimated standard deviation of the sampling distribution of the coefficient  
- **t and P>\|t\|**: t-statistic and p-value testing the null hypothesis that the coefficient equals zero  
- **R-squared**: the fraction of variation in yield explained by nitrogen

### Interpreting the slope

The slope coefficient β₁ in

```text
yield_kg = β₀ + β₁ · nitrogen_kg + ε
```

tells us: "a one-unit increase in X is associated with a β₁-unit change in Y." In our example, the slope is -3.17, then each additional kilogram of nitrogen is associated with 3.17 fewer kilograms of yield.

Two important caveats:

1. **Association, not causation** — unless we've identified the effect (Week 8)  
2. **Linear approximation** — OLS picks the best straight line, which may or may not describe the true relationship well

### The error term

OLS fits:

```text
Y = β₀ + β₁X + ε
```

Everything that determines Y but is not X lives in the error term ε. This includes:

- Omitted variables (soil quality, weather, management)  
- Measurement noise  
- Random variation

For OLS to give us the causal effect of X, we need X to be **uncorrelated** with ε. This is the **exogeneity assumption** — the regression version of closing all back-door paths.

If there is a confounder in ε that is correlated with X, the coefficient on X is biased. This is **omitted variable bias**.

### Multivariate regression: adding controls

Recall from Week 8 that conditioning on a confounder can block a back-door path. Regression does this automatically when we add control variables.

```stata
* single variable regression (potentially confounded)
    regress         yield_kg nitrogen_kg

* multivariate: control for irrigation status
    regress         yield_kg nitrogen_kg i.irr
```

The `i.` prefix tells Stata that `irr` is an indicator (factor) variable. In the second regression:

- The coefficient on `nitrogen_kg` is the slope **holding irrigation status fixed**  
- The coefficient on `1.irr` is the difference in average yield between irrigated and rainfed plots, holding nitrogen fixed

Adding a control is the regression version of "comparing within groups."

#### General syntax for controls

```stata
* add multiple controls
    regress         yield_kg nitrogen_kg i.irr plot_area_GPS total_labor_days
```

Each control variable's coefficient gives its partial association with the outcome, holding everything else in the model fixed.

### Connecting regression to DAGs

The workflow from Week 8, now with regression:

1. Draw a DAG for your causal question  
2. Use the DAG to identify which variables are confounders, mediators, and colliders  
3. Include confounders as controls in the regression  
4. Do **not** control for colliders or (usually) mediators  

```stata
* suppose the DAG says soil quality confounds nitrogen → yield
* and we have a proxy for soil quality: soil_cat
    regress         yield_kg nitrogen_kg i.soil_cat
```

This is the same logic as conditioning on soil quality quartiles in Week 8, but regression does it more efficiently and allows for continuous controls.

### Simulating to verify: regression recovers the causal effect

We can use the simulation skills from Week 8 to check that regression works.

```stata
* simulate DGP with confounding
    clear all
    set             seed 54321
    set             obs 2000

* confounder
    gen             soil_q = rnormal(0, 1)

* treatment (correlated with confounder)
    gen             fert = (0.6*soil_q + rnormal(0, 1) > 0)

* outcome: true effect of fert = 0.5
    gen             yield = 2 + 0.5*fert + 1.0*soil_q + rnormal(0, 1)

* naive regression (omits confounder): biased
    regress         yield fert

* regression with control: should recover ≈ 0.5
    regress         yield fert soil_q
```

The first regression gives a biased estimate because `soil_q` is in the error term and correlated with `fert`. The second regression controls for `soil_q`, blocking the backdoor path and recovering the true effect.

### Getting fancier: factor variables and interactions

#### Factor (categorical) variables

Many controls are categorical (region, crop type, survey round). Use the `i.` prefix:

```stata
* control for region fixed effects
    regress         yield_kg nitrogen_kg i.irr i.region
```

Stata creates a set of indicator variables for each level of the factor, omitting one reference category to avoid perfect collinearity. The coefficient on each level is the difference relative to the omitted category, holding everything else fixed.

#### Interaction terms

Sometimes the effect of X on Y **differs by group**. An interaction term captures this:

```stata
* does the nitrogen-yield relationship differ by irrigation?
    regress         yield_kg c.nitrogen_kg##i.irr
```

The `##` operator includes:
- `nitrogen_kg` (main effect)  
- `irr` (main effect)  
- `nitrogen_kg × irr` (interaction)

Interpretation:
- Coefficient on `nitrogen_kg`: slope for the reference group (rainfed)  
- Coefficient on `1.irr`: level shift for irrigated plots at nitrogen = 0  
- Coefficient on `1.irr#c.nitrogen_kg`: **how much steeper** the slope is for irrigated plots

The `c.` prefix tells Stata that `nitrogen_kg` is continuous (needed inside `##`).

#### Polynomials

If the relationship between X and Y is nonlinear, you can add polynomial terms:

```stata
* quadratic relationship
    regress         yield_kg c.nitrogen_kg##c.nitrogen_kg
```

This fits:

```text
yield = β₀ + β₁ · nitrogen + β₂ · nitrogen² + ε
```

A negative β₂ (diminishing returns) is common with agricultural inputs.

### Reading `regress` output: a checklist

When you run `regress`, look at:

| Item | Where | What it tells you |
|---|---|---|
| Coefficients | Bottom table | Direction and magnitude of each relationship |
| Std. err. | Bottom table | Precision of each estimate |
| P>\|t\| | Bottom table | Can you reject that the coefficient is zero? |
| R-squared | Top right | Fraction of Y's variance explained by the model |
| F-statistic | Top right | Are the predictors jointly significant? |
| N (obs) | Top right | Sample size used (watch for dropped observations) |

### Summary

- `regress Y X` fits a straight line through Y and X, minimizing squared residuals  
- Adding controls (`regress Y X Z`) is the regression version of conditioning  
- Use DAGs (Week 8) to decide **what** to control for  
- Factor variables (`i.`), interactions (`##`), and polynomials let you model richer relationships  
- Regression coefficients are causal only when the exogeneity assumption holds — identification still comes from research design, not from the regression itself

Next lectures this week: correcting standard errors, and additional concerns (weights, collinearity, measurement error).
