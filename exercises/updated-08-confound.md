---
layout: exercise
topic: Research design
title: Confounding and Conditional Means
language: Stata
---

**Story:** You want the causal effect of training on wages. Higher-ability workers are more likely to enroll in training, and ability also raises wages. So trained workers earn more partly because of training and partly because they have higher ability. What is the causal effect of training on wages?

Copy the following code into your `.do` file:

```stata
* simulate confounding dgp
	clear			all
	set				seed 314159
	set				obs 25000

* confounder
	gen				ability = rnormal(0, 1)

* training selection depends on ability (different rule than earlier exercise)
	gen				p_train = invlogit(-0.5 + 0.8*ability)
	gen				train = (runiform() < p_train)

* wage equation with noise (different levels and effect sizes than earlier exercise)
	gen				eps = rnormal(0, 4)
	gen				wage_lat = 20 + 3.5*train + 6*ability + eps
	gen				wage = max(wage_lat, 0)
	drop			wage_lat

* labels
	lab var			ability	"ability (confounder)"
	lab var			p_train	"p(train=1)"
	lab var			train	"training (selected, not randomized)"
	lab var			eps		"wage shock"
	lab var			wage	"wage"

	lab def			yesno 0 "no" 1 "yes", replace
	lab val			train yesno
```

1\. What is the naive difference in means (confounded)?
   - Compute mean wage by `train`

2\. What is the mean of ability with and without training (show selection)?
   - Report mean `ability` by `train`

3\. What are mean wages in each ability quartile (conditioning)?
   - Create `ability_q4` using `xtile`
   - Report mean wage by training within quartiles

---
