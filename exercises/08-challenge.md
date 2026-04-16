---
layout: exercise
topic: Research Design
title: Challenge 8
language: Stata
---

In this challenge you will simulate **one** data generating process (DGP) that contains:
- a **confounder** (`ability`) that affects both training and wages  
- a **mediator** (`productivity`) on the path from training to wages  
- a **collider** (`employed`) that depends on both training and wages
Your job is to use **difference-in-means** and **conditional means** (no regressions) to diagnose the bias created by each structure and show how to recover the target causal effect(s).

Copy the following code into your `.do` file:

```stata
* simulate one dgp with confounding + mediation + selection
	clear		all
	set		seed 80808
	set		obs 80000

* confounder
	gen		ability = rnormal(0, 1)

* training selection depends on ability (confounding)
	gen		p_train = invlogit(-0.3 + 0.9*ability)
	gen		train = (runiform() < p_train)

* mediator: productivity increases with training and ability
	gen		u_p = rnormal(0, 2)
	gen		productivity = 10 + 1.5*train + 1.0*ability + u_p

* outcome: wage depends on training (direct), productivity (indirect), and ability
	gen		u_w = rnormal(0, 6)
	gen		wage_lat = 30 + 1.2*train + 1.8*productivity + 2.0*ability + u_w
	gen		wage = max(wage_lat, 0)
	drop		wage_lat

* collider: employed depends on training and wage
	gen		emp_lat = -1.0 + 0.6*train + 0.05*wage + rnormal(0, 1)
	gen		employed = (emp_lat > 0)
	drop		emp_lat

* labels
	lab var		ability "ability (confounder)"
	lab var		p_train "p(train=1)"
	lab var		train "training (selected)"
	lab var		productivity "productivity (mediator)"
	lab var		wage "wage"
	lab var		employed "employed (collider / sample selection)"

	lab def		yesno 0 "no" 1 "yes", replace
	lab val		train yesno
	lab val		employed yesno
```

1\. True effects from the DGP (do this in comments)
- **true direct effect** of `train` on `wage`  
- **true indirect effect** of `train` on `wage` through `productivity`  
- **true total effect** (= direct + indirect)

*(Hint: use the coefficients in the equations above.)*

2\. Confounding: naive vs conditioned
- Compute the **naive difference in mean wages** by training status (full sample).
- Show selection by reporting **mean ability by training status**.
- Reduce confounding by:
   - creating `ability_q4` using `xtile`
   - reporting the **difference in mean wage by training** within ability quartile 3

3\. Collider bias: what changes when you condition on employment?
- Compute the difference in mean wages by training **among the employed** (`employed == 1`).
- Report the mean probability of being employed by training status.
- Compare your employed-sample wage difference to the full-sample wage difference from Task 2.
- In comments, explain why conditioning on `employed` changes the estimate in this DGP.

4\. Mediation: total vs indirect vs implied direct (no regressions)
- Using the **full sample** (do **not** restrict to employed), compute:
   - `total_hat`: difference in mean wage by training
- Compute:
   - `delta_p`: difference in mean productivity by training
   - `indirect_hat = 1.8 * delta_p` (use the productivity slope from the wage equation)
- Compute:
   - `direct_hat = total_hat - indirect_hat`
- Compare `direct_hat` to the true direct effect you wrote in Task 1.
