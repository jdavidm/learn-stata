---
layout: exercise
topic: Standard Errors & Inference
title: Bootstrap Comparisons
language: Stata
---

If we aren't satisfied with algorithmic approximations of our standard errors (like HC2), we can calculate them empirically through Bootstrapping. 

Bootstrapping pulls randomly from our dataset 1,000 times (with replacement), recalculates the regression on each random draw, and gives us exactly the distribution of standard errors dynamically.

1. Run the bootstrap regression on `lifeexp.dta` (this may take a few seconds):
   ```stata
   reg lexp gnppc, vce(bootstrap, reps(1000) seed(123))
   ```
2. How do the standard errors compare to the computationally derived HC2 model from the previous exercise? Are the bootstrapped standard errors tighter or wider?
