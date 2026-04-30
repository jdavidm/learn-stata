---
layout: exercise
topic: Machine Learning
title: Lasso for Prediction
language: Stata
---

Use Stata's native `lasso linear` command to predict crop yield using a large set of covariates from `plot_dataset.dta`. The lasso will automatically select which variables to keep by shrinking unimportant coefficients to zero.

- Using the training set only (`if sample == 1`), run `lasso linear` to predict `yield_kg` using the following covariates: `plot_area_GPS`, `seed_kg`, `nitrogen_kg`, `total_labor_days`, `total_hired_labor_days`, `improved`, `used_pesticides`, `organic_fertilizer`, `irrigated`, `intercropped`, `age_manager`, `female_manager`, `formal_education_manager`, `plot_slope`, `elevation`, `dist_market`, `dist_popcenter`, `soil_fertility_index`, `crop_shock`, `drought_shock`, and factor variables `i.wave` and `i.admin_1`.

1\. Inspect the selected variables with `lassocoef, display(coef, standardized)`. Which variables did lasso select?

2\. Plot the cross-validation curve with `cvplot`. Export the graph to Overleaf.

- Generate predictions for the full dataset with `predict yhat_lasso`.
- Compute the out-of-sample MSE on the test set (`sample == 0`). And calculate the mean.
- Use `lassogof` to report the MSE for the training set.


3\. Report the out-of-sample MSE for both models. Which model does better predicting out of sample?

---
