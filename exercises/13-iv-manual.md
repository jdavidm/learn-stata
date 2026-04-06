---
layout: exercise
topic: Instrumental Variables
title: Manual 2SLS
language: Stata
---

Let's perform Two-Stage Least Squares (2SLS) by hand using `Mroz.dta` to understand the mechanics! We are interested in estimating the returns to education (`educ`) on log wages (`lwage`), but `educ` is endogenous due to omitted variable bias (e.g., unobserved ambition or ability). 

To solve this we will use instruments: mother's education (`motheduc`) and father's education (`fatheduc`).

1. Open a new script and load `"$data/Mroz.dta"`.
2. Run the **First Stage**: Regress your endogenous right-hand side variable (`educ`) on your instruments (`motheduc` and `fatheduc`) and all other exogenous controls (`exper` and `expersq`).
3. Immediately after, generate the predicted fitted values using `predict educ_hat, xb`.
4. Run the **Second Stage**: Regress your outcome variable `lwage` on your predicted treatment `educ_hat` alongside your initial exogenous controls (`exper` and `expersq`).
5. Run the naive OLS regression (`reg lwage educ exper expersq`) to compare. 

Did the returns to education coefficient go up or down compared to the naive OLS?

---
