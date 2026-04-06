---
layout: exercise
topic: Instrumental Variables
title: Comparing IV to OLS
language: Stata
---

Doing 2SLS by hand is intuitively useful, but it fundamentally miscalculates the standard errors in the second stage, because Stata doesn't know that `educ_hat` is an estimated instrument rather than a completely deterministic variable.

Instead, we use Stata's built-in `ivregress` command, which automatically handles the two stages and properly adjusts the standard errors.

- Using `Mroz.dta`, run the `ivregress` command:

```stata
* run automatic 2sls
	ivregress       2sls lwage exper expersq (educ = motheduc fatheduc), vce(robust)
```

1. Is the coefficient on `educ` identical to the one you found manually using the two-step prediction method?
2. Are the standard errors the same as your manual two-step process? *(They shouldn't be! Notice how Stata corrects them).*

---
