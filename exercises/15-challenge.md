---
layout: exercise
topic: Machine Learning
title: Challenge 15
language: Stata
---

This challenge asks you to apply the full ML workflow — from data preparation through model comparison and interpretation — to a new prediction task using `plot_dataset.dta`.

#### Part 1 — New Prediction Target

Instead of predicting `yield_kg`, predict `harvest_value_USD` (the value of the plot harvest in US dollars) using the other available covariates. Predicting the value of agricultural output is a genuine applied problem — for example, in estimating poverty rates or targeting agricultural support programs.

- Using `plot_dataset.dta` with your existing train/test split (the `sample` variable from Exercise 1).
- Run two models on the training set:
  1. **Lasso**: Use `lasso linear` with covariates `plot_area_GPS`, `seed_kg`, `nitrogen_kg`, `total_labor_days`, `total_hired_labor_days`, `improved`, `used_pesticides`, `organic_fertilizer`, `irrigated`, `intercropped`, `nb_seasonal_crop`, `age_manager`, `female_manager`, `formal_education_manager`, `plot_slope`, `elevation`, `dist_market`, `dist_popcenter`, `soil_fertility_index`, `crop_shock`, `drought_shock`, and factor variables `i.wave` and `i.admin_1`.
  2. **Gradient boosting**: Use `h2oml gbregress` with the same covariates (without `i.` prefixes). Use `ntrees(500)`, `maxdepth(5)`, `learnrate(0.05)`, and `cv(5)`.

- Generate predictions from both models and compute the out-of-sample MSE on the test set.

#### Part 2 — Comparison Table

- Create a matrix comparing the out-of-sample MSE and RMSE for lasso and GBM.
- Export the comparison as a LaTeX table to `"$answ/15-challenge-compare.tex"`. Use `esttab` or manually build the table.

#### Part 3 — Interpretation

- Run `h2omlgraph shapsummary` on the GBM model. Export the SHAP summary plot to `"$answ/15-challenge-shap.png"`.
- Import both the comparison table and the SHAP plot into your Overleaf document.

#### Part 4 — Reflection

Answer the following questions in your Overleaf write-up:

1. Which model predicts harvest value better — lasso or GBM? By how much?

2. Examine the SHAP summary plot. Which variables are most important for predicting harvest value? Are any of these variables ones that you would *not* use in a causal regression of harvest value on inputs? Why?

3. The `plot_dataset.dta` contains observations from seven countries. Do you think a single ML model trained on all countries predicts well for each individual country? How might you test this? What are the implications for using ML to target agricultural programs across different contexts?

4. Suppose a development organization wants to identify the poorest farming households (those with the lowest harvest value) for a cash transfer program, but they can only observe plot characteristics and input use — not actual harvest. How could a trained ML model help? Would you use lasso or GBM? Why?

---
