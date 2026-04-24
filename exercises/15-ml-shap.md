---
layout: exercise
topic: Machine Learning
title: SHAP and Variable Importance
language: Stata
---

ML models are powerful predictors but can be hard to interpret. This exercise uses H2O's interpretation tools to understand *why* the gradient boosting model makes the predictions it does using `plot_dataset.dta`.

Make sure your GBM model from Exercise 5 is the most recently estimated H2O model (the `h2omlgraph` commands operate on the last `h2oml` model). If needed, re-estimate the GBM model.

- Generate a SHAP summary plot:

```stata
* SHAP summary plot
    h2omlgraph shapsummary
    graph export    "$answ/15-ml-shap.png", replace
```

The SHAP summary plot shows each variable on the y-axis. Each dot is one observation. The x-axis shows the SHAP value (how much that variable pushes the prediction up or down for that observation). Color indicates the variable's value (red = high, blue = low).

- Generate partial dependence plots for the two most important predictors identified by the variable importance plot:

```stata
* partial dependence plots for top predictors
    h2omlgraph pdp nitrogen_kg
    graph export    "$answ/15-ml-pdp-nitrogen.png", replace

    h2omlgraph pdp seed_kg
    graph export    "$answ/15-ml-pdp-seed.png", replace
```

- Generate a variable importance plot (if not already done):

```stata
* variable importance for GBM
    h2omlgraph varimp
    graph export    "$answ/15-ml-varimp-gbm.png", replace
```

1. Examine the SHAP summary plot. For the top three variables, describe the relationship between the variable's value (color) and its SHAP value (horizontal position). For example: "Higher nitrogen application (red) is associated with positive SHAP values, meaning it pushes yield predictions upward."

2. Examine the partial dependence plots. Do they reveal any nonlinear relationships? For example, does the effect of nitrogen on yield flatten or reverse at high levels? How would a standard OLS model handle this pattern differently?

3. Compare the variable importance ranking from the GBM model to the set of variables that lasso selected in Exercise 2. Are they similar? Why might they differ?

4. A colleague sees that `nitrogen_kg` has the highest variable importance and concludes that "nitrogen fertilizer causes higher crop yields." Is this interpretation correct? Why or why not? What is the difference between predictive importance and causal effect?

---
