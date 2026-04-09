---
layout: exercise
topic: Standard Errors & Inference
title: Randomization Inference
language: Stata
---

If standard errors are theoretically messy or you want a fully non-parametric p-value, you can bypass the standard error calculation entirely using Randomization Inference (RI). RI randomly permutes the treatment variable thousands of times, generating a distribution of placebo coefficients. Your actual coefficient is then compared against this distribution.

*(Note: You may need to run `ssc install ritest` first.)*

- Using `Michler_JEEM.dta` (maize only), run Randomization Inference on the `CA` variable. We permute `CA` 1,000 times and capture the coefficient on `CA` from each placebo regression. Note that `ritest` works with standard regression commands, so we include household fixed effects via `i.rc` and year fixed effects via `i.year`:

```stata
* randomization inference for CA
	ritest          CA _b[CA], reps(1000) seed(123) cluster(rc): ///
	                    ivreg2 lnyield lnbasal lntop lnseed ///
	                    lnaream2 pdate pdate2 i.year i.rc ///
	                    (CA = wardNGO), robust
```

1\. What is the RI p-value? What percentage of the placebo coefficients were larger (in absolute value) than the actual coefficient?
2\. How does the RI p-value compare to the p-value from the standard `xtivreg2` regression? Are the conclusions about statistical significance consistent?

---
