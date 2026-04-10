---
layout: page
element: notes
title: Single and Multivariate Regression
language: Stata
---

Last week we used simulations and conditional means to think about identification. This week we formalize that work with **regression**, the most widely used tool for statistical adjustment in the social sciences.

This lecture covers:
- The `regress` (`reg`) command for simple (single-variable) regression  
- Interpreting coefficients, standard errors, and *p*-values  
- Adding controls (multivariate regression)  
- Connecting regression to the DAG / identification ideas from Week 8  
- Getting fancier: factor variables, interactions, and polynomials

We'll work with simulated data on yield, fertilizer, and soil quality — the same DGP from Week 8.

### Setting up the simulated data

We begin by generating a dataset where we **know the truth**. The DGP is the same `yield ← soil → fertilizer` from the identification lecture:

```stata
* simulate DGP: yield, fertilizer, and soil quality
    clear           all
    set             seed 12345
    set             obs 20000

* soil quality (confounder, continuous)
    gen             soil_q = rnormal(0, 1)

* fertilizer adoption (correlated with soil quality)
    gen             fert = (0.5*soil_q + rnormal(0, 1) > 0)
    label           define fertlbl 0 "no fertilizer" 1 "fertilizer"
    label           values fert fertlbl

* yield: true effect of fert = 0.5, soil_q effect = 1.0
    gen             eps = rnormal(0, 1)
    gen             yield = 2 + 0.5*fert + 1.0*soil_q + eps

* soil quality categories (for later use)
    xtile           soil_cat = soil_q, nq(4)
    label           define soilcatlbl 1 "worst" 2 "low" 3 "high" 4 "best"
    label           values soil_cat soilcatlbl
```

Because we built this data, we know:

- True causal effect of fertilizer on yield: **0.5**  
- Effect of soil quality on yield: **1.0**  
- `fert` is **not** randomly assigned — better soil → more fertilizer

### From fitted lines to `reg`

In Week 5 we added fitted lines to scatter plots with `lfit`. Under the hood, that line comes from an OLS regression.

```stata
* scatter with fitted line (Week 5 review)
    twoway          (scatter yield soil_q) ///
                    (lfit    yield soil_q), ///
                        title("Yield vs soil quality") ///
                        xtitle("Soil quality") ///
                        ytitle("Yield")

* the regression behind that line
    reg             yield soil_q
```

The regression tells Stata to fit the line that minimizes the sum of squared vertical distances from each point to the line.

### Interpreting the slope

The slope coefficient β₁ in

```text
yield = β₀ + β₁ · soil_q + ε
```

Tells us: "a one-unit increase in X is associated with a β₁-unit change in Y." Since we know the true coefficient on `soil_q` is 1.0, the regression should recover approximately that value.

Two important caveats:

1. **Association, not causation** — unless we've identified the effect (Week 8)  
2. **Linear approximation** — OLS picks the best straight line, which may or may not describe the true relationship well

> Do [Exercise 1 - Simple Regression]({{ site.baseurl }}/exercises/09-simple-reg/)

### The error term

OLS fits:

```text
Y = β₀ + β₁X + ε
```

Everything that determines Y but is not X lives in the error term ε. This includes:

- Omitted variables (fertilizer use, management practices)  
- Measurement noise  
- Random variation

For OLS to give us the causal effect of X, we need X to be **uncorrelated** with ε. This is the **exogeneity assumption** — the regression version of closing all back-door paths.

If there is a confounder in ε that is correlated with X, the coefficient on X is biased. This is **omitted variable bias**.

### Multivariate regression: adding controls

Recall from Week 8 that conditioning on a confounder can block a back-door path. Regression does this automatically when we add control variables.

```stata
* naive regression (omits confounder): biased
    reg             yield fert

* multivariate: control for soil quality
    reg             yield fert soil_q
```

In the first regression, `soil_q` is in the error term and correlated with `fert`, so the coefficient on `fert` is biased upward. The second regression controls for `soil_q`, blocking the backdoor path and recovering the true effect (≈ 0.5).

#### General syntax for controls

```stata
* add multiple controls
    reg             yield fert soil_q i.soil_cat
```

Each control variable's coefficient gives its partial association with the outcome, holding everything else in the model fixed.

> Do [Exercise 2 - Multivariate Regression]({{ site.baseurl }}/exercises/09-multi-reg/)

### Connecting regression to DAGs

The workflow from Week 8, now with regression:

1. Draw a DAG for your causal question  
2. Use the DAG to identify which variables are confounders, mediators, and colliders  
3. Include confounders as controls in the regression  
4. Do **not** control for colliders or (usually) mediators  

```stata
* suppose the DAG says soil quality confounds fert → yield
    reg             yield fert soil_q
```

This is the same logic as conditioning on soil quality quartiles in Week 8, but regression does it more efficiently and allows for continuous controls.

### Getting fancier: factor variables and interactions

#### Factor (categorical) variables

Many controls are categorical (region, crop type, soil category). Use the `i.` prefix:

```stata
* control for soil quality category fixed effects
    reg             yield fert i.soil_cat
```

Stata creates a set of indicator variables for each level of the factor, omitting one reference category to avoid perfect collinearity. The coefficient on each level is the difference relative to the omitted category, holding everything else fixed.

#### Interaction terms

Sometimes the effect of X on Y **differs by group**. An interaction term captures this:

```stata
* does the fertilizer-yield relationship differ by soil category?
    reg             yield c.fert##i.soil_cat
```

The `##` operator includes:
- `fert` (main effect)  
- `soil_cat` (main effect)  
- `fert × soil_cat` (interaction)

Interpretation:
- Coefficient on `fert`: effect for the reference group (worst soil)  
- Coefficient on `2.soil_cat`: level shift for "low" soil at fert = 0  
- Coefficient on `2.soil_cat#c.fert`: **how much the fertilizer effect differs** for "low" soil vs "worst" soil

The `c.` prefix tells Stata that `fert` is being treated as continuous.

#### Polynomials

If the relationship between X and Y is nonlinear, you can add polynomial terms:

```stata
* quadratic relationship between soil quality and yield
    reg             yield c.soil_q##c.soil_q fert
```

This fits:

```text
yield = β₀ + β₁ · soil_q + β₂ · soil_q² + β₃ · fert + ε
```

A negative β₂ (diminishing returns) is common with agricultural inputs.

> Do [Exercise 3 - Factor Variables and Interactions]({{ site.baseurl }}/exercises/09-factor-vars/)

### Reading `reg` output: a checklist

When you run `reg`, look at:

| Item | Where | What it tells you |
|---|---|---|
| Coefficients | Bottom table | Direction and magnitude of each relationship |
| Std. err. | Bottom table | Precision of each estimate |
| P>\|t\| | Bottom table | Can you reject that the coefficient is zero? |
| R-squared | Top right | Fraction of Y's variance explained by the model |
| F-statistic | Top right | Are the predictors jointly significant? |
| N (obs) | Top right | Sample size used (watch for dropped observations) |

### Summary

- `reg Y X` fits a straight line through Y and X, minimizing squared residuals  
- Adding controls (`reg Y X Z`) is the regression version of conditioning  
- Use DAGs (Week 8) to decide **what** to control for  
- Factor variables (`i.`), interactions (`##`), and polynomials let you model richer relationships  
- Regression coefficients are causal only when the exogeneity assumption holds — identification still comes from research design, not from the regression itself

Next lectures this week: correcting standard errors, and additional concerns (weights, collinearity, measurement error).
