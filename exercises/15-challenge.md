---
layout: exercise
topic: Machine Learning
title: Challenge 15
language: Stata
---

This challenge asks you to compare the out-of-sample performance of the machine learning models you trained in the previous exercises, select the best one, and then deploy it to impute missing crop yield data. 

#### Part 1 — Model Comparison

Now that you have fit lasso, elastic net, random forest, and gradient boosting on `plot_dataset.dta`, it is time to compare them systematically on out-of-sample performance.

- Create a comparison table. Store the MSE values in a matrix and display them:

```stata
* collect results
    matrix          compare = J(4, 2, .)
    matrix rownames compare = Lasso ElasticNet RF GBM
    matrix colnames compare = MSE RMSE

    local           row = 1
    foreach model in lasso enet rf gbm {
        sum         sq_err_`model' if sample == 2
        matrix      compare[`row', 1] = r(mean)
        matrix      compare[`row', 2] = sqrt(r(mean))
        local       ++row
    }
    matrix list     compare, format(%12.1f)
```

- Export a dataset of the results:

```stata
* create a dataset from the matrix for export
    preserve
    clear
    svmat           compare
    gen             model = ""
    replace         model = "Lasso" in 1
    replace         model = "Elastic Net" in 2
    replace         model = "Random Forest" in 3
    replace         model = "Gradient Boosting" in 4
    order           model
    rename          (compare1 compare2) (mse rmse)
    export delimited "$export/15-ml-compare.csv", replace
    restore
```

1. Rank the four models from best (lowest MSE) to worst. Which model wins? By how much does it improve over the second-best model?

2. Create a bar chart showing the out-of-sample MSE for each model. Export and import into your Overleaf document.

#### Part 2 — Deployment

The dataset `plot_dataset.dta` has 257,154 observations, but only 228,448 observations actually have data on `yield_kg`. The remaining 28,706 observations have missing yield data! The goal of this part is to use the winning machine learning model to predict what the harvest would have been for those plots.

- Make sure your best-performing model is the active model in memory (if it's an H2O model, make sure `train_frame` is active and you've re-estimated it if necessary).
- Generate predictions for the *entire* dataset using `predict`.
- Replace the missing `yield_kg` values with the predicted values.

```stata
* assuming your best model is GBM and it is currently active
* generate predictions for all observations
    predict future_yield

* check how many are missing before
    count if yield_kg == .

* impute missing yields
    replace yield_kg = future_yield if yield_kg == .

* check how many are missing after
    count if yield_kg == .
```

3. How many missing `yield_kg` observations did your model successfully impute? Use `count if yield_kg == .` before and after to verify.

4. Think about the economic implications of what you just did. If you were an agricultural researcher or policymaker, what is one major advantage of using machine learning to impute missing harvest data rather than just dropping those observations from your analysis?

---
