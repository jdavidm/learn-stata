---
layout: exercise
topic: Research design
title: Mediation and Conditional Means
language: Stata
---

**Story:** You want the causal effect of training on wages. Training increases productivity, and productivity increases wages. So training can raise wages directly and also indirectly by raising productivity. What is the causal effect of training on wages?

Copy the following code into your `.do` file:

```stata
* simulate mediation dgp
	clear			all
	set				seed 13579
	set				obs 50000

* randomized training
	gen				train = (runiform() < 0.5)

* mediator: productivity increases with training
	gen				u_p = rnormal(0, 2)
	gen				productivity = 5 + 1.2*train + u_p

* outcome: wage depends on training directly and indirectly via productivity
	gen				u_w = rnormal(0, 5)
	gen				wage_lat = 25 + 1.0*train + 2.5*productivity + u_w
	gen				wage = max(wage_lat, 0)
	drop			wage_lat

* labels
	lab var			train			"training (randomized)"
	lab var			productivity	"productivity (mediator)"
	lab var			wage			"wage"

	lab def			yesno 0 "no" 1 "yes", replace
	lab val			train yesno
```

1\. What is the true direct causal effect of training on wages?

2\. What is the naive difference in mean wages by training status (total effect)?
   - Compute the difference in mean `wage` by `train`
   - Save this value (the difference) as a scalar called `total_hat`

3\.  What is the indirect effect of training on wages through productivity?
   - Compute the difference in mean `productivity` by `train`
   - Save this value (the difference) as a scalar called `delta_p`
   - Calculate the indirect effect as `2.5*delta_p` (from the DGP)
   - Save this value as a scalar called `indirect_hat`

4\. What is the implied true direct effect once you subtract off the indirect effect from the total effect?
   - Report the direct effect as direct = total − indirect

---

