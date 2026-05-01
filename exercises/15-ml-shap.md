---
layout: exercise
topic: Machine Learning
title: SHAP and Variable Importance
language: Stata
---

ML models are powerful predictors but can be hard to interpret. This exercise uses H2O's interpretation tools to understand *why* the gradient boosting model makes the predictions it does using `plot_dataset.dta`. Make sure your GBM model from the previous exercise is the most recently estimated H2O model (the `h2omlgraph` commands operate on the last `h2oml` model). If needed, re-estimate the GBM model.

1. Generate a variable importance plot, export it, and import it into Overleaf.

2. Generate partial dependence plots for the two most important predictors identified by the variable importance plot. Export them and import them into Overleaf.

3. Generate a SHAP summary plot, export it, and import it into Overleaf.

4. Examine the SHAP summary plot. For the top three variables, describe the relationship between the variable's value (color) and its SHAP value (horizontal position). For example: "Higher nitrogen application (red) is associated with positive SHAP values, meaning it pushes yield predictions upward."


---
