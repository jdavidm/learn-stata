---
layout: exercise
topic: Research Design
title: Simulating a Confounded DGP
language: Stata
---

In this exercise we are going to practice simulating a confounded DGP and diagnosing bias.
- Set the random seed to `24601` and simulate 30,000 observations.
- Generate an unobserved confounder called `ability` that is distributed Normal(0, 1)
- Generate a variable called `p_train` using a probability rule (`invlogit`) that increases with ability: `invlogit(-0.2 + 1.0*ability)`
- Then assign training as a Bernoulli draw `train = (runiform() < p_train)`
- Create a variable `eps ~ rnormal(0, 3)` so there is meaningful noise
- Generate wages so that the true causal effect of training be **+2** and ability raises wages by **+4** while wages without training (`train = 0`) or ability (`ability = 0`) is **10**
- Add noise to the wage equation so that `wage_lat = 10 + 2*train + 4*ability + eps`
- Enforce `wage >= 0` by truncating at 0 using `max(wage_lat, 0)`
- Add variable labels to all variables and value labels for `train` (0 = no, 1 = yes)

1\. What is the naive difference in means by training status and is it larger or smaller than the true causal effect?
- Compute the naive difference in means using `sum, meanonly`
- store mean wage for `train==0` in scalar `w0`  
- store mean wage for `train==1` in scalar `w1`  
- display `w1 - w0` with a formatted display statement

2\. Show that selection is happening by showing that `ability` differs by training status.
- report mean `ability` by `train` (use `tabstat` or `summarize` with `if`)

---