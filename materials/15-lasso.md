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
* lasso with cross-validation to predict yield (training set only)
    lasso linear    yield_kg nitrogen_kg seed_kg ///
                        total_labor_days total_hired_labor_days ///
                        plot_area_GPS improved ///
                        used_pesticides organic_fertilizer ///
                        irrigated intercropped ///
                        age_manager female_manager ///
                        formal_education_manager ///
                        hh_size dist_popcenter ///
                        soil_fertility_index ///
                        crop_shock drought_shock ///
                        i.wave i.admin_1 ///
                        if sample == 1
    estimates store     cv
```

Notice two things: we restrict the estimation to the training set with `if sample == 1`, and we use `estimates store` to save the results under the name `cv`. Storing estimates allows us to compare multiple models later.

Stata automatically performs 10-fold cross-validation over a grid of λ values. We can also fit lasso using an alternative selection method — **adaptive lasso** — which uses BIC-like criteria instead of cross-validation:

```stata
* adaptive lasso on the training set
    lasso linear    yield_kg nitrogen_kg seed_kg ///
                        total_labor_days total_hired_labor_days ///
                        plot_area_GPS improved ///
                        used_pesticides organic_fertilizer ///
                        irrigated intercropped ///
                        age_manager female_manager ///
                        formal_education_manager ///
                        hh_size dist_popcenter ///
                        soil_fertility_index ///
                        crop_shock drought_shock ///
                        i.wave i.admin_1 ///
                        if sample == 1, selection(adaptive)
    estimates store     adpt
```

After fitting, we use post-estimation commands to inspect the results:

```stata
* which variables were selected? display nonzero coefficients
    lassocoef cv adpt, display(coef, standardized)

* plot the cross-validation curve (MSE vs. lambda)
    estimates restore   cv
    cvplot
```

`lassocoef` shows which variables survived the penalty — their coefficients are nonzero. Passing both stored model names lets us compare which variables each method selected. `cvplot` graphs the cross-validation MSE against λ, showing the optimal penalty.

#### Evaluating model fit

The key question: how well does each model predict on **data it has never seen**? `lassogof` with the `over()` option computes MSE separately for each group in the split variable — training and testing:

```stata
* compare in-sample and out-of-sample MSE for both models
    lassogof cv adpt, over(sample) postselection
```

`lassogof` reports the MSE for each model in each sample. The `postselection` option uses postselection coefficients (OLS re-estimated on the lasso-selected variables) rather than the penalized coefficients — this often gives better out-of-sample predictions. The MSE for `sample == 2` (the test set) is the out-of-sample MSE — the number that tells us how well the model generalizes.

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
* for ridge regression, set alpha = 0
    elasticnet linear yield_kg nitrogen_kg seed_kg ///
                        total_labor_days total_hired_labor_days ///
                        plot_area_GPS improved ///
                        used_pesticides organic_fertilizer ///
                        irrigated intercropped ///
                        age_manager female_manager ///
                        formal_education_manager ///
                        hh_size dist_popcenter ///
                        soil_fertility_index ///
                        crop_shock drought_shock ///
                        i.wave i.admin_1, ///
                        alpha(0)

* elastic net with alpha = 0.5 (equal blend of lasso and ridge)
    elasticnet linear yield_kg nitrogen_kg seed_kg ///
                        total_labor_days total_hired_labor_days ///
                        plot_area_GPS improved ///
                        used_pesticides organic_fertilizer ///
                        irrigated intercropped ///
                        age_manager female_manager ///
                        formal_education_manager ///
                        hh_size dist_popcenter ///
                        soil_fertility_index ///
                        crop_shock drought_shock ///
                        i.wave i.admin_1, ///
                        alpha(0.5)
```

*Note: When running the elastic net code with `alpha(0.5)`, you may encounter an error stating "No minimum of cross-validation function found" and "No lambda selected." This happens because the optimal penalty for this specific training split is so close to zero that Stata reaches the end of its default search grid without finding a clear turning point in the cross-validation error. Effectively, the model is saying that the "optimal" penalty for this particular training split is close to zero, meaning it basically just wants to run regular OLS without any penalty! To fix this, you can force Stata to search a wider range of smaller penalty values and disable early stopping by adding the options `grid(100, ratio(1e-5)) stop(0)` to the command.*

> Do [Exercise 3 - Elastic Net and Ridge]({{ site.baseurl }}/exercises/15-ml-elasticnet/)

### Summary

- **Lasso** shrinks coefficients and performs variable selection via an L1 penalty; use `lasso linear` in Stata
- **Ridge** shrinks but keeps all variables via an L2 penalty; **elastic net** blends both; use `elasticnet linear` in Stata

Next lecture: Ensemble Trees and Model Interpretation.
