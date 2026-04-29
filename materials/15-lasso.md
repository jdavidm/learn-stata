---
layout: page
element: notes
title: Lasso, Ridge, and Elastic Net
language: Stata
---

This lecture introduces penalized regression methods — lasso, ridge, and elastic net — which extend OLS by adding a penalty that prevents overfitting. These are the simplest ML algorithms and a natural bridge between the regression models from earlier in the course and the tree-based methods in the next lecture.

This lecture covers:
- Lasso regression for prediction and variable selection
- Ridge regression and elastic net as extensions of lasso

We continue using `eth_allrounds_final.dta` and the train/test split from Exercise 1.

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

- **Lasso** shrinks coefficients and performs variable selection via an L1 penalty; use `lasso linear` in Stata
- **Ridge** shrinks but keeps all variables via an L2 penalty; **elastic net** blends both; use `elasticnet linear` in Stata
- **H2O** provides access to ensemble tree methods (random forest, gradient boosting) through Stata 19's `h2oml` commands — we will use these in the next lecture

Next lecture: Ensemble Trees and Model Interpretation.
