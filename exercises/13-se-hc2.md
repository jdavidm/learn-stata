---
layout: exercise
topic: Standard Errors & Inference
title: HC2 and Clustered Standard Errors
language: Stata
---

In this exercise you will compare different approaches to calculating standard errors for the conservation agriculture IV regression from `Michler_JEEM.dta`. The base specification is a panel IV model using `xtivreg2` with household fixed effects.

- Load `"$data/Michler_JEEM.dta"` and keep only maize observations (`keep if crops == 1`).
- Declare the panel structure: `xtset rc year`.
- Run the panel IV regression with default robust standard errors:

```stata
* panel iv with default robust ses
	xtivreg2        lnyield lnbasal lntop lnseed lnaream2 pdate pdate2 ///
	                    i.year (CA = wardNGO), fe robust
	eststo          robust
```

- Run the same specification but with **clustered** standard errors at the household (`rc`) level:

```stata
* panel iv with clustered ses
	xtivreg2        lnyield lnbasal lntop lnseed lnaream2 pdate pdate2 ///
	                    i.year (CA = wardNGO), fe cluster(rc)
	eststo          clustered
```

- Now run a cross-sectional version using `ivreg2` to access HC2 and Bell-McCaffrey corrections (which are not available with `xtivreg2`):

```stata
* cross-sectional iv with hc1
	ivreg2          lnyield lnbasal lntop lnseed lnaream2 ///
	                    pdate pdate2 i.year (CA = wardNGO), robust
	eststo          hc1

* cross-sectional iv with hc2
	ivreg2          lnyield lnbasal lntop lnseed lnaream2 ///
	                    pdate pdate2 i.year (CA = wardNGO), ///
	                    bw(1) kernel(tru)
	eststo          hc2
```

- Export a four-column comparison table:

```stata
* compare standard error methods
	esttab          hc1 hc2 robust clustered ///
	                    using "$answ/13-se-hc2.tex", replace ///
	                    b(3) se(3) ///
	                    keep(CA) ///
	                    star(* 0.10 ** 0.05 *** 0.01) ///
	                    mtitles("HC1" "HC2" "FE Robust" "FE Clustered") ///
	                    stats(N, labels("Observations") fmt(0)) ///
	                    noobs booktabs nonum collabels(none) ///
	                    nobaselevels nogaps fragment label ///
	                    prehead("\begin{tabular}{l*{4}{c}} " ///
	                        "\\[-1.8ex]\hline \hline \\[-1.8ex] " ///
	                        "& \multicolumn{2}{c}{Cross-Section} & " ///
	                        "\multicolumn{2}{c}{Panel FE} " ///
	                        "\\ \cline{2-3} \cline{4-5} \\[-1.8ex]" ///
	                        "& \multicolumn{1}{c}{(1)} & " ///
	                        "\multicolumn{1}{c}{(2)} & " ///
	                        "\multicolumn{1}{c}{(3)} & " ///
	                        "\multicolumn{1}{c}{(4)} \\ \midrule") ///
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
