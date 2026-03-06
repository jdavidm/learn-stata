---
layout: exercise
topic: Regression
title: Challenge 9
language: Stata
---

In this challenge, we will verify that multivariate regression works as expected by running regressions on a simulated Data Generating Process (DGP) where we know the true causal effects.

This DGP features a **confounder** (`ability`), a **mediator** (`productivity`), and a **collider** (`employed`).

### Tasks

1. First, set up the simulation. Copy and run the following code in your do-file:

```stata
* simulate one dgp with confounding + mediation + selection
clear all
set seed 80808
set obs 80000

* confounder
gen ability = rnormal(0, 1)

* training selection depends on ability (confounding)
gen p_train = invlogit(-0.3 + 0.9*ability)
gen train = (runiform() < p_train)

* mediator: productivity increases with training and ability
gen u_p = rnormal(0, 2)
gen productivity = 10 + 1.5*train + 1.0*ability + u_p

* outcome: wage depends on training (direct), productivity (indirect), and ability
gen u_w = rnormal(0, 6)
gen wage_lat = 30 + 1.2*train + 1.8*productivity + 2.0*ability + u_w
gen wage = max(wage_lat, 0)
drop wage_lat

* collider: employed depends on training and wage
gen emp_lat = -1.0 + 0.6*train + 0.05*wage + rnormal(0, 1)
gen employed = (emp_lat > 0)
drop emp_lat
```

2. What is the **true total effect** of `train` on `wage` in this DGP?
   - The direct effect is the coefficient on `train` in the `wage_lat` equation (1.2).
   - The indirect effect is the effect of `train` on `productivity` (1.5) times the effect of `productivity` on `wage` (1.8).
   - In comments, write down the true direct, indirect, and total effects.

3. **Naive Regression (Confounded)**
   - Regress `wage` on `train` with no other controls.
   - Record the coefficient on `train`. Does this naive regression overestimate or underestimate the true total effect? Why?

4. **Controlling for the Confounder**
   - Regress `wage` on `train` and `ability`.
   - Record the coefficient on `train`. How close is it to the true total effect you calculated in Task 2? Have you successfully closed the back-door path?

5. **Controlling for the Mediator (Over-controlling)**
   - Now regress `wage` on `train`, `ability`, and `productivity`.
   - Record the coefficient on `train`. Which part of the effect does this represent (direct, indirect, or total)? Is `productivity` a good control if you want the total effect of training?

6. **Collider Bias**
   - Finally, regress `wage` on `train` and `ability`, but restrict the sample to only those who are employed by adding `if employed == 1` to the end of your regress command.
   - Compare the coefficient on `train` here to your estimate in Task 4. Explain why conditioning on the collider (`employed`) introduces bias.
