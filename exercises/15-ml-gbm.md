---
layout: exercise
topic: Machine Learning
title: Gradient Boosting
language: Stata
---

Gradient boosting builds trees sequentially — each new tree corrects the errors of the ensemble. This exercise uses H2O's `h2oml gbregress` command with `plot_dataset.dta`.

- Fit a gradient boosting model to predict `yield_kg` on the training set. Use 500 trees, a maximum depth of 5, a learning rate of 0.05, and 5-fold cross-validation:

```stata
* fit gradient boosting model
    h2oml gbregress yield_kg plot_area_GPS seed_kg ///
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
                        ntrees(500) maxdepth(5) ///
                        learnrate(0.05) cv(5)
```

- Evaluate the out-of-sample MSE on the testing frame using `h2omlgof`.

1. Report the out-of-sample MSE. Compare it to the random forest MSE from Exercise 4. Which model performs better?

2. Gradient boosting uses shallower trees (`maxdepth(5)`) than random forest (`maxdepth(10)`). Why? How does boosting compensate for using simpler individual trees?

3. Re-run the model with a higher learning rate: `learnrate(0.3)`. What happens to the out-of-sample MSE? Why does a smaller learning rate often produce better predictions, even though it requires more trees?

---
