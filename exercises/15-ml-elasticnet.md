---
layout: exercise
topic: Machine Learning
title: Elastic Net and Ridge
language: Stata
---

Lasso (α = 1) sets some coefficients to exactly zero. Ridge (α = 0) shrinks all coefficients but keeps every variable. Elastic net blends both. In this exercise, compare all three using `plot_dataset.dta`.

- Using the training set, run `elasticnet linear` with `alpha(1)` (this is lasso — confirm it matches Exercise 2):

```stata
* lasso via elasticnet (alpha = 1)
    elasticnet linear yield_kg plot_area_GPS seed_kg ///
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
                        if sample == 1, alpha(1)
    predict         yhat_a1
```

- Run elastic net with `alpha(0.5)`:

```stata
* elastic net (alpha = 0.5)
    elasticnet linear yield_kg plot_area_GPS seed_kg ///
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
                        if sample == 1, alpha(0.5)
    predict         yhat_a5
```

- Run ridge with `alpha(0)`:

```stata
* ridge (alpha = 0)
    elasticnet linear yield_kg plot_area_GPS seed_kg ///
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
                        if sample == 1, alpha(0)
    predict         yhat_a0
```

- For each model, compute the out-of-sample MSE on the test set.

1. For each α value, use `lassocoef` to count the number of variables with nonzero coefficients. How does the number of selected variables change as α moves from 1 (lasso) to 0.5 (elastic net) to 0 (ridge)?

2. Compare the out-of-sample MSE across the three models. Which performs best? Is the difference large?

3. In what situation would you prefer ridge regression over lasso? Think about what happens when many predictors are correlated.

---
