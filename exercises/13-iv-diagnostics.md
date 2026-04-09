---
layout: exercise
topic: Instrumental Variables
title: Instrument Diagnostics
language: Stata
---

Before trusting any IV estimate, we must test whether our instrument is actually valid. In this exercise you will run the standard battery of diagnostic tests on the `Michler_JEEM.dta` conservation agriculture IV specification.

- Using `Michler_JEEM.dta` (maize only), run `ivreg2` with robust standard errors and the `first` option to display both first- and second-stage results along with automatic diagnostic statistics:

```stata
* run ivreg2 with diagnostics
	ivreg2          lnyield lnbasal lntop lnseed lnaream2 ///
	                    pdate pdate2 i.year (CA = wardNGO), ///
	                    robust first
```

- Examine the diagnostic statistics reported at the bottom of the `ivreg2` output. These include the **Kleibergen-Paap F-statistic** (testing instrument relevance) and the **endogeneity test** (testing whether IV is necessary).

1\. What is the Kleibergen-Paap F-statistic? Does `wardNGO` pass the standard rule-of-thumb threshold of $F > 10$ for instrument strength? *(Note: `ivreg2` reports this automatically, unlike `ivreg` which requires a separate `estat firststage` command.)*
2\. Based on the endogeneity test, is `CA` statistically endogenous? Is IV justified for this application?
3\. We have exactly one instrument (`wardNGO`) for one endogenous variable (`CA`). This means we are *exactly identified*. Does `ivreg2` report a Hansen J-statistic? Why or why not? *(Hint: the overidentification test requires at least one more instrument than endogenous variables.)*

---
