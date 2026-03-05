---
layout: exercise
topic: Research design
title: Collider Bias Simulation
language: Stata
---

**Story:** You want the causal effect of training on wages. You've collected data on people who are employed. Both training and wages affect whether someone is employed. What is the causal effect of training on wages?

Copy the following code into your `.do` file:

```stata
* simulate collider dgp
	clear		all
	set			seed 24684
	set			obs 50000

* train and wage are independent in the population
	gen			train = (runiform() < 0.5)
	gen			wage  = rnormal(0, 1)

* collider: inclusion depends on both train and wage
	gen			emp_lat = -0.3 + 0.7*train + 0.7*wage + rnormal(0, 1)
	gen			employed = (emp_lat > 0)

* labels
	lab var		train "training (randomized)"
	lab var		wage "wage (independent of training in population)"
	lab var		employed "observed in sample (collider)"

	lab def		yesno 0 "no" 1 "yes", replace
	lab val		train yesno
	lab val		employed yesno
```

1\. What is the true causal effect of training on wages?

2\. What is the naive difference in mean wages by training status among the employed?
   - Compute the difference in mean `wage` by `train` using only observations with `employed == 1`

3\. What is the mean probability of being employed with and without training (selection on employment)?
   - Report the mean of `employed` by `train`

4\. What is the difference in mean wages by training status in the full sample (unconditional)?
   - Report the difference in mean wage by `train` using the full dataset

---
