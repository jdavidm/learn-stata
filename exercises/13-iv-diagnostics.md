---
layout: exercise
topic: Instrumental Variables
title: Instrument Diagnostics
language: Stata
---

Before trusting any IV estimate, we must test whether our instrument is actually valid. In this exercise you will run the standard battery of diagnostic tests on the `Michler_JEEM.dta` conservation agriculture IV specification.

- Using `Michler_JEEM.dta` (maize only), run `xtivreg2` with clustered standard errors
	- Add the `first` option to display both first- and second-stage results
	- Add the `endog(CA)` option to display the Durbin-Wu-Hausman Test

1. Does `wardNGO` pass the standard rule-of-thumb threshold of $F > 10$ for instrument strength using the Kleibergen-Paap F-statistic?
2. Based on the endogeneity test, is `CA` statistically endogenous?
3. We have exactly one instrument (`wardNGO`) for one endogenous variable (`CA`). What does the Stata output say about the Hansen J-statistic?

---
