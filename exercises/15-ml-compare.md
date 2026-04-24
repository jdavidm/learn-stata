---
layout: exercise
topic: Machine Learning
title: Model Comparison
language: Stata
---

Now that you have fit OLS, lasso, elastic net, random forest, and gradient boosting on `plot_dataset.dta`, it is time to compare them systematically on out-of-sample performance.

- First, if you haven't already, run a plain OLS regression on the training set using the same covariates and generate predictions:

```stata
* OLS on training data
    reg             yield_kg plot_area_GPS seed_kg ///
                        nitrogen_kg total_labor_days ///
                        total_hired_labor_days improved ///
                        used_pesticides organic_fertilizer ///
                        irrigated intercropped ///
                        age_manager female_manager ///
                        formal_education_manager ///
                        plot_slope elevation ///
                        dist_market dist_popcenter ///
                        soil_fertility_index ///
                        crop_shock drought_shock ///
                        i.wave i.admin_1 ///
                        if sample == 1
    predict         yhat_ols
    gen             sq_err_ols = (yield_kg - yhat_ols)^2
```

- Collect the out-of-sample MSE for each model. Use the squared error variables you've computed in previous exercises (`sq_err_ols`, `sq_err_lasso`, `sq_err_rf`, `sq_err_gbm`, plus any elastic net variants).

- Create a comparison table. Store the MSE values in a matrix and display them:

```stata
* collect results
    matrix          compare = J(5, 2, .)
    matrix rownames compare = OLS Lasso ElasticNet RF GBM
    matrix colnames compare = MSE RMSE

    local           row = 1
    foreach model in ols lasso enet rf gbm {
        sum         sq_err_`model' if sample == 0
        matrix      compare[`row', 1] = r(mean)
        matrix      compare[`row', 2] = sqrt(r(mean))
        local       ++row
    }
    matrix list     compare, format(%12.1f)
```

- Export a LaTeX table of the results:

```stata
* create a dataset from the matrix for export
    preserve
    clear
    svmat           compare
    gen             model = ""
    replace         model = "OLS" in 1
    replace         model = "Lasso" in 2
    replace         model = "Elastic Net" in 3
    replace         model = "Random Forest" in 4
    replace         model = "Gradient Boosting" in 5
    order           model
    rename          (compare1 compare2) (mse rmse)
    export delimited "$answ/15-ml-compare.csv", replace
    restore
```

1. Rank the five models from best (lowest MSE) to worst. Which model wins? By how much does it improve over OLS?

2. Create a bar chart showing the out-of-sample MSE for each model. Export and import into your Overleaf document.

3. Does the ranking of models surprise you? In what types of datasets might OLS or lasso outperform tree-based methods?

---
