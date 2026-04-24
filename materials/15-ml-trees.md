---
layout: page
element: notes
title: Ensemble Trees and Model Interpretation
language: Stata
---

In the previous lecture we introduced lasso, ridge, and elastic net — all of which are extensions of linear regression. This lecture moves beyond linearity. **Tree-based methods** can capture complex nonlinear relationships and interactions automatically, without the researcher having to specify them. We then discuss how to compare models, interpret ML predictions, and connect ML back to the causal-inference work from earlier in the course.

This lecture covers:
- Decision trees and why single trees overfit
- Random forests (bagging + random feature selection)
- Gradient boosting (sequential error correction)
- Comparing OLS, lasso, random forest, and GBM on held-out test data
- Model interpretation: variable importance, partial dependence plots, and SHAP values
- When to use ML in economics

We continue using `eth_allrounds_final.dta` and the train/test split from Exercise 1.

### Decision trees

A **decision tree** recursively partitions the data based on the variable and split point that best separates the outcome. At each node, the algorithm asks: "Which variable, split at which value, produces the biggest reduction in prediction error?" It keeps splitting until some stopping rule is met (e.g., a minimum number of observations per leaf, or a maximum tree depth).

The result is a tree-shaped set of if/then rules:

```text
Is rainfall > 800mm?
├── Yes: Is nitrogen > 50 kg/ha?
│   ├── Yes: predict yield = 2,400 kg/ha
│   └── No:  predict yield = 1,600 kg/ha
└── No:  Is plot_area > 2 ha?
    ├── Yes: predict yield = 900 kg/ha
    └── No:  predict yield = 1,100 kg/ha
```

Trees are powerful because they automatically capture **nonlinearities** (the effect of nitrogen depends on rainfall) and **interactions** (the split structure creates implicit interactions). No need to specify `c.rain##c.nitrogen` — the tree finds it.

But single trees have a fatal flaw: they **overfit aggressively**. A deep tree can create a separate leaf for nearly every observation, memorizing the training data perfectly but performing terribly on new data. This is the extreme high-variance end of the bias-variance tradeoff.

The solution: don't use one tree — use hundreds. This is the idea behind **ensemble methods**.

### Random forest

A **random forest** builds many decision trees and averages their predictions. Each tree is intentionally different, created using two sources of randomness:

1. **Bootstrap sampling (bagging)**: Each tree is trained on a random subset of the data, drawn with replacement. Some observations are included multiple times, others are left out.
2. **Random feature selection**: At each split, the algorithm considers only a random subset of the available variables. This prevents every tree from splitting on the same dominant predictor.

By averaging many diverse trees, the random forest dramatically reduces variance (overfitting) while preserving the ability to capture nonlinear patterns. Individual trees may overfit, but their errors are uncorrelated — so they cancel out when averaged.

#### Using `h2oml rfregress` in Stata

H2O's random forest command in Stata is `h2oml rfregress`. Before using it, make sure H2O is initialized and your data is pushed to an H2O frame (see Exercise 1).

```stata
* fit a random forest
    h2oml rfregress yield_kg rain_total rain_season ///
                        rain_dev nitrogen phosphorus ///
                        pesticide_any organic_fert ///
                        plot_area_GPS dist_road ///
                        hh_size age_head educ_head ///
                        female_head extension_visit ///
                        round region, ///
                        ntrees(200) maxdepth(10) cv(5)
```

Key options:
- `ntrees()`: Number of trees in the forest. More trees generally improve accuracy but increase computation time. Diminishing returns above ~200–500.
- `maxdepth()`: Maximum depth of each tree. Deeper trees are more flexible but more prone to overfitting.
- `cv()`: Number of cross-validation folds. H2O performs internal k-fold CV and reports the CV MSE.

After fitting, generate predictions:

```stata
* generate predictions on the full dataset
    predict         yhat_rf

* compute out-of-sample MSE
    gen             sq_err_rf = (yield_kg - yhat_rf)^2
    sum             sq_err_rf if sample == 0
```

> Do [Exercise 4 - Random Forest]({{ site.baseurl }}/exercises/15-ml-rf/)

### Gradient boosting

**Gradient boosting** takes a different approach to building an ensemble. Instead of training many independent trees in parallel (like random forest), gradient boosting trains trees **sequentially**, where each new tree corrects the errors of the previous ensemble.

The algorithm:
1. Start with a simple prediction (e.g., the mean of y).
2. Compute the residuals (errors).
3. Fit a small tree to predict those residuals.
4. Add the new tree's predictions to the ensemble (scaled by a learning rate).
5. Repeat steps 2–4 for many iterations.

Each successive tree focuses on the observations where the current ensemble performs worst. The **learning rate** (also called shrinkage) controls how much each new tree contributes — smaller values require more trees but often produce better models because they allow finer corrections.

Gradient boosting is often the best-performing ML algorithm for tabular data (the kind economists typically work with). It consistently wins ML competitions (Kaggle) and is widely used in industry and applied research.

#### Using `h2oml gbregress` in Stata

```stata
* fit a gradient boosting model
    h2oml gbregress yield_kg rain_total rain_season ///
                        rain_dev nitrogen phosphorus ///
                        pesticide_any organic_fert ///
                        plot_area_GPS dist_road ///
                        hh_size age_head educ_head ///
                        female_head extension_visit ///
                        round region, ///
                        ntrees(500) maxdepth(5) ///
                        learnrate(0.05) cv(5)
```

Key options:
- `ntrees()`: Number of boosting iterations (trees). More trees allow finer corrections. Too many can overfit, but the learning rate mitigates this.
- `maxdepth()`: Depth of each individual tree. GBM typically uses *shallower* trees than random forest (depth 3–8 is common) because complexity comes from the ensemble, not individual trees.
- `learnrate()`: How much each tree contributes. Typical values: 0.01–0.1. Lower values require more trees but tend to generalize better.
- `cv()`: Cross-validation folds for internal evaluation.

```stata
* generate predictions
    predict         yhat_gbm

* compute out-of-sample MSE
    gen             sq_err_gbm = (yield_kg - yhat_gbm)^2
    sum             sq_err_gbm if sample == 0
```

> Do [Exercise 5 - Gradient Boosting]({{ site.baseurl }}/exercises/15-ml-gbm/)

### Model comparison

After fitting multiple models, we need a principled way to compare them. The key metric is **out-of-sample MSE** — prediction error on data the model has never seen. Lower MSE means better prediction.

We compare five models:
1. **OLS** — plain linear regression with all covariates
2. **Lasso** — penalized linear regression with variable selection
3. **Elastic net** — blended L1/L2 penalty
4. **Random forest** — ensemble of independent trees
5. **Gradient boosting** — ensemble of sequential trees

```stata
* collect out-of-sample MSE for each model
    foreach model in ols lasso enet rf gbm {
        sum         sq_err_`model' if sample == 0
        local       mse_`model' = r(mean)
    }

* display comparison
    di as text "Model Comparison (Out-of-Sample MSE)"
    di as text "OLS:          " as result %12.1f `mse_ols'
    di as text "Lasso:        " as result %12.1f `mse_lasso'
    di as text "Elastic Net:  " as result %12.1f `mse_enet'
    di as text "Random Forest:" as result %12.1f `mse_rf'
    di as text "GBM:          " as result %12.1f `mse_gbm'
```

Typically, gradient boosting and random forest outperform lasso and OLS for prediction, especially when there are nonlinearities and interactions in the data. But this is not guaranteed — the relative performance depends on the data-generating process. If the true relationship is approximately linear, lasso may perform nearly as well with a much simpler model.

> Do [Exercise 6 - Model Comparison]({{ site.baseurl }}/exercises/15-ml-compare/)

### Model interpretation

A common criticism of ML models — especially tree ensembles — is that they are "black boxes." We get predictions, but we don't understand *why* the model predicts what it does. Fortunately, modern ML has developed powerful interpretation tools.

#### Variable importance

**Variable importance** measures how much each variable contributes to the model's predictions. For tree-based models, this is typically based on how much each variable reduces prediction error across all splits in all trees.

```stata
* variable importance plot for the GBM model
    h2omlgraph varimp
```

This produces a bar chart ranking variables by their importance. The most important variable contributed the most to reducing MSE across the ensemble.

#### Partial dependence plots

**Partial dependence plots (PDPs)** show the marginal effect of one variable on the predicted outcome, averaging over all other variables. They answer: "Holding everything else constant (on average), how does changing this variable affect the prediction?"

```stata
* partial dependence plot for the top predictor
    h2omlgraph pdp rain_total
    h2omlgraph pdp nitrogen
```

PDPs can reveal nonlinear relationships that OLS would miss. For example, the effect of nitrogen on yield might be positive up to 100 kg/ha and then flatten — a pattern that a tree ensemble captures automatically.

#### SHAP values

**SHAP (SHapley Additive exPlanations)** values go further than variable importance. For each observation, SHAP values decompose the prediction into the contribution of each variable. This tells us not just *which* variables matter overall, but *how* they matter for each individual prediction.

```stata
* SHAP summary plot for the GBM model
    h2omlgraph shapsummary
```

The SHAP summary plot shows every variable on the y-axis. For each variable, each dot represents one observation. The horizontal position shows the SHAP value (positive = pushes prediction up, negative = pushes prediction down). The color shows the variable's value (red = high, blue = low). This gives a rich picture of the model's behavior:

- If high values of rainfall (red dots) cluster on the right (positive SHAP), rainfall increases predicted yield.
- If the dots spread widely, the variable's effect varies across observations (potential heterogeneity).

> Do [Exercise 7 - SHAP and Variable Importance]({{ site.baseurl }}/exercises/15-ml-shap/)

### When to use ML in economics

ML is a powerful prediction tool, but it does not replace causal inference. Here is a framework for thinking about when ML is and isn't appropriate in applied economics research:

#### ML is the right tool when:

1. **The research question is about prediction**: Targeting programs, risk scoring, nowcasting, prediction policy problems.
2. **Variable selection is needed**: When you have many potential controls and no clear theoretical guidance, lasso can select a parsimonious set.
3. **Flexible functional forms**: When the true relationship between covariates and outcome may be nonlinear and involve complex interactions.

#### ML complements causal inference when:

1. **Double/debiased machine learning (DML)**: Use ML to flexibly control for confounders in the first stage of a partially linear model. The `ddml` package in Stata implements this. DML uses lasso or random forest to partial out the effect of controls on both treatment and outcome, then estimates the causal effect in a second step.
2. **Heterogeneous treatment effects**: After establishing a causal effect with RCT or quasi-experiment, use ML (causal forests) to explore which subgroups experience larger or smaller effects.
3. **Covariate selection for causal models**: Use lasso to select controls in a regression, then run OLS with the selected variables. (But be careful — naive post-lasso OLS can have bad statistical properties; use `dsregress` in Stata for correct inference.)

#### ML is the wrong tool when:

1. **You want a causal estimate**: Lasso, RF, and GBM estimate associations, not causal effects. A high variable importance score does not mean a variable *causes* the outcome.
2. **Interpretability is paramount**: While SHAP and PDPs help, a well-specified OLS model is often more transparent and easier to communicate to policymakers.

### Summary

- **Decision trees** recursively partition data but overfit badly on their own
- **Random forest** reduces overfitting by averaging many diverse trees built on bootstrap samples with random feature subsets; use `h2oml rfregress`
- **Gradient boosting** builds trees sequentially, each correcting the errors of the ensemble; use `h2oml gbregress` — often the best predictor for tabular data
- **Compare models** on out-of-sample MSE using a held-out test set
- **Interpret** ML models with variable importance (`h2omlgraph varimp`), partial dependence plots (`h2omlgraph pdp`), and SHAP values (`h2omlgraph shapsummary`)
- ML is for prediction; use causal-inference tools (Weeks 8–14) for estimating treatment effects — but the two can complement each other through methods like double ML
