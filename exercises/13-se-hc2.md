---
layout: exercise
topic: Standard Errors
title: Robust & Clustered Standard Errors
language: Stata
---

In this exercise you will compare different approaches to calculating standard errors for the conservation agriculture IV regression from `Michler_JEEM.dta`. The base specification is a pooled IV model using `ivreg2` with household fixed effects.


- Run the panel IV regression with default (uncorrected) standard errors.
- Run the same specification but with the `robust` option.
- The `bw(1) kernel(tru)` options require the data to be `tsset`. Since the data has multiple plots per household-year, generate a unique observation ID (`gen obs_id = _n`) and `tsset obs_id` before running this specification.
- Run the same specification but using the Bell-McCaffrey corrections `bw(1) kernel(tru)`.
- Run the same specification but with the standard error option `cluster` at the household (`rc`) level.

1\. Export a four-column comparison table and put it in your Overleaf file:

```stata
* compare standard error methods
	esttab      def robust hc2 cluster ///
	                using "$answ/13-se-hc2.tex", replace ///
	                b(3) se(3) keep(CA) nomtitles ///
	                star(* 0.10 ** 0.05 *** 0.01) ///
	                stats(N, labels("Observations") fmt(0)) ///
	                noobs booktabs nonum collabels(none) ///
	                nobaselevels nogaps fragment label ///
	                prehead("\begin{tabular}{l*{4}{c}} " ///
	                    "\\[-1.8ex]\hline \hline \\[-1.8ex] " ///
	                    "& \multicolumn{1}{c}{Uncorrected} & " ///
	                    "\multicolumn{1}{c}{Robust} & " ///
	                    "\multicolumn{1}{c}{HC2} & " ///
	                    "\multicolumn{1}{c}{Clustered} " ///
	                    "\\ \midrule") ///
	                postfoot("\hline \hline \\[-1.8ex] " ///
	                    "\multicolumn{5}{p{0.9\linewidth}}{\small " ///
	                    "\noindent \textit{Note}: Dependent variable " ///
	                    "is log maize yield. CA instrumented with " ///
	                    "wardNGO. All models include input controls " ///
	                    "and year FE. " ///
	                    "* p$<$0.10, ** p$<$0.05, *** p$<$0.01.} " ///
	                    "\end{tabular}")
```

1\. Compare the standard error on `CA` across HC1, HC2, and the panel FE specifications. Does adjusting for leverage (HC2) increase or decrease the standard error?

2\. How do the clustered standard errors compare to the robust standard errors? What does this suggest about within-household correlation in this panel?

---
