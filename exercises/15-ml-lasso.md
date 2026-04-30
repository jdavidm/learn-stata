---
layout: exercise
topic: Machine Learning
title: Lasso for Prediction
language: Stata
---

Use Stata's native `lasso linear` command to predict crop yield using a large set of covariates from `plot_dataset.dta`. The lasso will automatically select which variables to keep by shrinking unimportant coefficients to zero.

- Using the training set only (`if sample == 1`), run `lasso linear` to predict `yield_kg` using the following covariates: `plot_area_GPS`, `seed_kg`, `nitrogen_kg`, `total_labor_days`, `total_hired_labor_days`, `improved`, `used_pesticides`, `organic_fertilizer`, `irrigated`, `intercropped`, `age_manager`, `female_manager`, `formal_education_manager`, `plot_slope`, `elevation`, `dist_market`, `dist_popcenter`, `soil_fertility_index`, `crop_shock`, `drought_shock`, and factor variables `i.crop`, `1.agro_ecological_zone`, `i.wave` and `i.country`.
- Store the estimates from this model (e.g., `estimates store cv`).
- Run a second model on the same training set using adaptive lasso by adding the `selection(adaptive)` option to the previous command.
- Store the estimates from the adaptive lasso model (e.g., `estimates store adpt`).

1\. Compare the selected variables using `lassocoef` for both stored models. Which coefficients are in the standard lasso but not in the adaptive lasso? Which ones are in the adaptive lasso but not in the standard lasso?

2\. Create cross-validation plots for both models using `cvplot` (remember to use `estimates restore` before plotting each one). Export the graphs to Overleaf.

- Compare the in-sample and out-of-sample MSE for both models using `lassogof` with the `over(sample)` and `postselection` options.

3\. Which model does best at out-of-sample prediction?

---
