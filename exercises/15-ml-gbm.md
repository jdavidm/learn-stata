---
layout: exercise
topic: Machine Learning
title: Gradient Boosting
language: Stata
---

Gradient boosting builds trees sequentially — each new tree corrects the errors of the ensemble. This exercise uses H2O's `h2oml gbregress` command with `plot_dataset.dta`.

- Fit a gradient boosting model to predict `yield_kg` on the training set using the local macro we created in the previous exercise. Use 500 trees, a maximum depth of 5, a learning rate of 0.05, and 5-fold cross-validation:

1\. What is the out-of-sample MSE on the testing frame using `h2omlgof`?

- For the final model comparison challenge, you will need the predictions from your optimal gradient boosting model. Use `predict yhat_gbm` to generate predictions for the entire dataset before estimating any further models.

2\. Re-run the model with a higher learning rate: `lrate(0.3)`. What happens to the out-of-sample MSE? Why does a smaller learning rate often produce better predictions, even though it requires more trees?


---
