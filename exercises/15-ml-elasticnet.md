---
layout: exercise
topic: Machine Learning
title: Elastic Net and Ridge
language: Stata
---

Lasso (α = 1) sets some coefficients to exactly zero. Ridge (α = 0) shrinks all coefficients but keeps every variable. Elastic net blends both. In this exercise, compare all three using `plot_dataset.dta`.

- Using the training set and the global macro `$inputs`, run `elasticnet linear` with `alpha(1)` (this is lasso — confirm it matches Exercise 2). Save results as `alph1`.
- Run elastic net with `alpha(0.5)`. Save results as `alph5`.
- Run ridge with `alpha(0)`. Save results as `alph0`.
- Compare results using `lassocoef`.

*If a model does not converge, remember you can change the search space and/or the stopping rule.*

1. How many variables with nonzero coefficients are in each model?

2. How does the number of selected variables change as α moves from 1 (lasso) to 0.5 (elastic net) to 0 (ridge)? Why?

3. Compare the out-of-sample MSE across the three models. Which performs best? Is the difference large?

- For the final model comparison challenge, you will need the predictions from your best-performing elastic net model. Assume `alpha(0.5)` is the best. Use `estimates restore alph5` and then use `predict yhat_enet` to generate predictions for the entire dataset.

---
