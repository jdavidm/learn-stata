---
layout: page
element: notes
title: Setup, Prediction, and Lasso
language: Stata
---

For fourteen weeks we have built a causal-inference toolkit: fixed effects, difference-in-differences, instrumental variables, regression discontinuity. Every one of those tools is designed to answer a *why* question — does X cause Y? This week we shift to a fundamentally different question: **can we predict Y well?**

Prediction problems are everywhere in applied economics. Which households are most likely to fall into poverty? Where should a government target an agricultural extension program? Which loan applicants will default? In each case, the goal is not to estimate a causal effect but to make an accurate forecast using whatever variables are available — even variables that would be "bad controls" in a causal model.

Machine learning (ML) gives us a family of algorithms designed to maximize prediction accuracy while guarding against **overfitting** — the tendency of a model to memorize the training data at the expense of performance on new data. This lecture introduces the core ideas and the first set of ML tools in Stata.

This lecture covers:
- When prediction (rather than causal inference) is the right goal
- The bias-variance tradeoff and overfitting
- Train/test splits and cross-validation
- Setting up H2O in Stata for advanced ML algorithms
- Lasso regression for prediction and variable selection
- Ridge regression and elastic net as extensions of lasso

We will use `eth_allrounds_final.dta` — the Ethiopia maize panel data from Weeks 11–13 — as our running example in the lecture. The task: **predict maize yield** (`yield_kg`) using household, plot, and weather variables. Students already know this data, so we can focus on the new methods rather than data cleaning. For the exercises, you will work with a larger, multi-country dataset (`plot_dataset.dta`) described in the first exercise.

### Prediction vs. causal inference

In causal inference (Weeks 8–14), we care about isolating the effect of one specific variable. We worry about omitted variable bias, exclusion restrictions, and parallel trends. We deliberately *exclude* variables that could be "bad controls" (post-treatment variables, mediators, colliders).

In prediction, **none of that matters**. We want the best possible forecast of the outcome, so we throw in every variable that helps — including variables we would never use in a causal model. A variable that is endogenous, post-treatment, or even a mediator can still be a useful predictor.

This distinction matters for how economists use ML in practice:

| | Causal inference | Prediction |
|---|---|---|
| **Goal** | Estimate the effect of X on Y | Forecast Y as accurately as possible |
| **Variable selection** | Guided by theory and DAGs | Guided by predictive power |
| **Overfitting** | Less concern (fixed sample) | Central concern |
| **Standard errors** | Essential | Often secondary |

When is prediction the right goal? Examples from economics:
- **Targeting**: Which farmers should receive subsidized fertilizer? (Predict who benefits most.)
- **Nowcasting**: What is GDP this quarter before official statistics arrive?
- **Risk scoring**: Which microfinance borrowers will default?
- **Prediction policy problems** ([Kleinberg et al., 2015](https://doi.org/10.1257/aer.p20151023)): When should a judge release a defendant before trial? The policy question is fundamentally about predicting future behavior, not estimating a causal effect.

### The bias-variance tradeoff

The central tension in ML is the **bias-variance tradeoff**. A model can fail in two ways:

1. **High bias (underfitting)**: The model is too simple to capture the true relationship. A linear model fit to a nonlinear relationship will systematically miss the pattern, making large errors on both training and test data.

2. **High variance (overfitting)**: The model is too complex — it memorizes the noise in the training data. It fits the training data perfectly but makes poor predictions on new data because it learned idiosyncratic patterns that don't generalize.

The optimal model balances these two sources of error. We want a model complex enough to capture the real signal but simple enough to ignore the noise. Every ML method we study this week is, at its core, a different way of navigating this tradeoff.

How do we know if we're overfitting? We need to evaluate our model on data it has never seen. This brings us to train/test splits.

### Train/test splits and cross-validation

#### The holdout approach

The simplest strategy: randomly split the data into a **training set** (used to fit the model) and a **test set** (used to evaluate it). A common split is 70% training, 30% test. We fit the model on the training set, predict on the test set, and evaluate using a metric like **Mean Squared Error (MSE)**:

$$MSE = \frac{1}{n_{test}} \sum_{i \in test} (y_i - \hat{y}_i)^2$$

A model that overfits will have low MSE on the training set but high MSE on the test set. A model that generalizes well will have similar MSE on both.

#### k-fold cross-validation

The holdout approach wastes data — 30% of our observations are never used for training. **k-fold cross-validation** is more efficient:

1. Split the data into k equal folds (typically k = 5 or 10).
2. For each fold: use k-1 folds for training, predict on the held-out fold.
3. Average the MSE across all k folds.

This uses all the data for both training and evaluation. Stata's `lasso` and `elasticnet` commands use cross-validation internally to choose their tuning parameters. H2O's ML algorithms also support k-fold CV through the `cv()` option.

### Setting up H2O in Stata

Stata 19 introduced deep integration with [H2O](https://h2o.ai/), an open-source ML platform. H2O runs as a separate Java process — Stata sends data to H2O, H2O fits the model, and Stata retrieves the results. This architecture lets us use powerful ML algorithms (random forest, gradient boosting) that are not natively available in Stata.

> [!IMPORTANT]
> H2O requires **Stata 19** and a **Java Runtime Environment (JRE)** installed on your machine. If you have not already installed Java, follow the instructions on the [Computer Setup]({{ site.baseurl }}/computer-setup/) page. If you encounter errors when initializing H2O, consult Stata's documentation on H2O setup or the [StataCorp YouTube video on H2O setup](https://www.youtube.com/watch?v=Y1aPrScIdtg).

The H2O workflow in Stata has three steps:

```stata
* 1. start the H2O cluster (launches a Java process)
    h2o init

* 2. push your Stata dataset to an H2O frame
    _h2oframe put, replace

* 3. (do your ML work here — random forest, GBM, etc.)

* 4. when finished, shut down the H2O cluster
    h2o shutdown
```

`h2o init` starts a local H2O server. `_h2oframe put` transfers the currently loaded Stata dataset to H2O's memory (as an "H2O frame"). After fitting models, `h2o shutdown` closes the H2O process and frees memory.

For this week we will use H2O only for random forest and gradient boosting (Lecture 2). Lasso and elastic net use Stata's native commands and do not require H2O.

> Do [Exercise 1 - Setup and Train/Test Split]({{ site.baseurl }}/exercises/15-ml-split/)

### Lasso

**Lasso** (Least Absolute Shrinkage and Selection Operator) is a penalized regression method. It starts with ordinary least squares but adds a penalty that **shrinks coefficients toward zero** and can set some coefficients to exactly zero — performing automatic variable selection.

The lasso objective function is:

$$\min_{\beta} \left\{ \frac{1}{N} \sum_{i=1}^{N} (y_i - x_i'\beta)^2 + \lambda \sum_{j=1}^{p} |\beta_j| \right\}$$

The first term is the familiar sum of squared residuals. The second term is the **penalty**: λ (lambda) controls how aggressively we shrink coefficients. When λ = 0, lasso reduces to OLS. As λ increases, more coefficients are set to zero, producing a sparser model. Cross-validation selects the λ that minimizes out-of-sample prediction error.

Why is this useful for economists?
- **Variable selection**: When you have many potential predictors and no clear theory to guide which to include, lasso selects for you.
- **Prediction**: Lasso typically predicts better than OLS when there are many covariates, because shrinking noisy coefficients toward zero reduces variance.
- **Regularization**: Even when the number of predictors exceeds the number of observations (p > n), lasso still works — OLS would be undefined.

#### Using `lasso linear` in Stata

Stata 16+ includes a native `lasso linear` command. The syntax is straightforward:

```stata
* lasso with cross-validation to predict yield
    lasso linear    yield_kg rain_total rain_season ///
                        rain_dev nitrogen phosphorus ///
                        pesticide_any organic_fert ///
                        plot_area_GPS dist_road ///
                        hh_size age_head educ_head ///
                        female_head extension_visit ///
                        i.round i.region
```

Stata automatically performs 10-fold cross-validation over a grid of λ values. After fitting, we use post-estimation commands to inspect the results:

```stata
* which variables were selected? display nonzero coefficients
    lassocoef, display(coef, standardized)

* plot the cross-validation curve (MSE vs. lambda)
    cvplot

* report goodness of fit
    lassogof
```

`lassocoef` shows which variables survived the penalty — their coefficients are nonzero. `cvplot` graphs the cross-validation MSE against λ, showing the optimal penalty. `lassogof` reports in-sample and out-of-sample fit statistics.

#### Generating predictions

To generate predictions for the test set:

```stata
* predict on all observations (lasso uses its selected model)
    predict         yhat_lasso

* compute out-of-sample MSE on the test set
    gen             sq_err_lasso = (yield_kg - yhat_lasso)^2
    sum             sq_err_lasso if sample == 0
    *** the mean of sq_err_lasso is the out-of-sample MSE
```

Here `sample == 0` indicates the test set (we'll create this variable in Exercise 1).

> Do [Exercise 2 - Lasso for Prediction]({{ site.baseurl }}/exercises/15-ml-lasso/)

### Ridge regression and elastic net

Lasso sets some coefficients to exactly zero — it selects variables. But what if many variables are genuinely important and correlated? Lasso tends to pick one variable from a group of correlated predictors and discard the rest. Two extensions address this:

**Ridge regression** replaces the lasso's L1 penalty (sum of absolute values) with an L2 penalty (sum of squared coefficients):

$$\min_{\beta} \left\{ \frac{1}{N} \sum_{i=1}^{N} (y_i - x_i'\beta)^2 + \lambda \sum_{j=1}^{p} \beta_j^2 \right\}$$

Ridge shrinks all coefficients toward zero but never sets any to exactly zero. It keeps all variables in the model. This can be better when you believe all variables are relevant and correlated.

**Elastic net** combines both penalties using a mixing parameter α (alpha):

$$\min_{\beta} \left\{ \frac{1}{N} \sum_{i=1}^{N} (y_i - x_i'\beta)^2 + \lambda \left[ \alpha \sum_{j=1}^{p} |\beta_j| + (1-\alpha) \sum_{j=1}^{p} \beta_j^2 \right] \right\}$$

When α = 1, elastic net is lasso. When α = 0, elastic net is ridge. Values in between (e.g., α = 0.5) blend both properties: some variable selection plus group shrinkage.

#### Using `elasticnet linear` in Stata

```stata
* elastic net with alpha = 0.5 (equal blend of lasso and ridge)
    elasticnet linear yield_kg rain_total rain_season ///
                        rain_dev nitrogen phosphorus ///
                        pesticide_any organic_fert ///
                        plot_area_GPS dist_road ///
                        hh_size age_head educ_head ///
                        female_head extension_visit ///
                        i.round i.region, ///
                        alpha(0.5)

* for ridge regression, set alpha = 0
    elasticnet linear yield_kg rain_total rain_season ///
                        rain_dev nitrogen phosphorus ///
                        pesticide_any organic_fert ///
                        plot_area_GPS dist_road ///
                        hh_size age_head educ_head ///
                        female_head extension_visit ///
                        i.round i.region, ///
                        alpha(0)
```

> Do [Exercise 3 - Elastic Net and Ridge]({{ site.baseurl }}/exercises/15-ml-elasticnet/)

### Summary

- **Prediction vs. causal inference**: ML is for forecasting outcomes, not estimating treatment effects — different goal, different variable selection logic
- **Bias-variance tradeoff**: The central tension in ML — too simple (high bias) vs. too complex (high variance)
- **Train/test splits**: Always evaluate on held-out data to detect overfitting; k-fold CV is more efficient than a single holdout
- **Lasso** shrinks coefficients and performs variable selection via an L1 penalty; use `lasso linear` in Stata
- **Ridge** shrinks but keeps all variables via an L2 penalty; **elastic net** blends both; use `elasticnet linear` in Stata
- **H2O** provides access to ensemble tree methods (random forest, gradient boosting) through Stata 19's `h2oml` commands — we will use these in the next lecture

Next lecture: Ensemble Trees and Model Interpretation.
