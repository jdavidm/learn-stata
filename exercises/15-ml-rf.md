---
layout: exercise
topic: Machine Learning
title: Random Forest
language: Stata
---

Random forest builds many decision trees on random subsets of data and variables, then averages their predictions. This exercise uses H2O's `h2oml rfregress` command with `plot_dataset.dta`. Make sure H2O is initialized and your data is loaded in an H2O frame (from Exercise 1). If you have restarted Stata, re-run `h2o init` and push the training and testing sets to H2O using `_h2oframe put`.

- Initialize the H2O cluster with `h2o init`. If you have not installed Java, follow the instructions on the [Computer Setup]({{ site.baseurl }}/computer-setup/) page first.
- Push the training data to an H2O frame named `train_frame` and make it current. Then push the testing data to an H2O frame named `test_frame`.
- Fit a random forest to predict `yield_kg` on the training set using the same set of predictors as in previous exercises. Use 200 trees, a maximum depth of 10, and 5-fold cross-validation:

*Note: When using `h2oml`, do not include the `i.` prefix for factor variables. H2O handles categorical variables internally. Pass `wave` and `admin_1` without `i.`.* So instead of using the global macro use the following local macro: `local h2o_inputs = subinstr("$inputs", "i.", "", .)`

- Set the testing frame and compute the out-of-sample MSE using `h2omlgof`:

1. Generate a variable importance plot, export it, and import it into Overleaf.

2. What is the out-of-sample MSE? How does it compare to the lasso MSE from Exercise 2?

3. Which three variables are most important according to the variable importance plot? Does this match your economic intuition about what drives crop yield?

- For the final model comparison challenge, you will need the predictions from your random forest model. Use `predict yhat_rf` to generate predictions for the entire dataset before moving on.

---
