---
layout: exercise
topic: Machine Learning
title: Random Forest
language: Stata
---

Random forest builds many decision trees on random subsets of data and variables, then averages their predictions. This exercise uses H2O's `h2oml rfregress` command with `plot_dataset.dta`.

Make sure H2O is initialized and your data is loaded in an H2O frame (from Exercise 1). If you have restarted Stata, re-run `h2o init` and `_h2oframe put, replace`.

- Fit a random forest to predict `yield_kg` on the training set. Use 200 trees, a maximum depth of 10, and 5-fold cross-validation:

```stata
* make sure the training frame is the active frame
    _h2oframe change train_frame

* fit random forest
    h2oml rfregress yield_kg plot_area_GPS seed_kg ///
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
                        crop agro_ecological_zone ///
                        wave country, ///
                        ntrees(200) maxdepth(10) cv(5)
```

Note: When using `h2oml`, do not include the `i.` prefix for factor variables. H2O handles categorical variables internally. Pass `wave` and `admin_1` without `i.`.

- Set the testing frame and compute the out-of-sample MSE using `h2omlgof`:

```stata
* set the testing frame for post-estimation
    h2omlpostestframe test_frame

* report out-of-sample goodness of fit
    h2omlgof
```

- Generate a variable importance plot:

```stata
* variable importance
    h2omlgraph varimp
    graph export    "$answ/15-ml-varimp-rf.png", replace
```

1. Report the out-of-sample MSE. How does it compare to the lasso MSE from Exercise 2?

2. Which three variables are most important according to the variable importance plot? Does this match your economic intuition about what drives crop yield?

3. Try re-running the model with `maxdepth(3)` and `maxdepth(20)`. How does the out-of-sample MSE change? What does this tell you about the bias-variance tradeoff?

---
