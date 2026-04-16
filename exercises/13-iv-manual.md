---
layout: exercise
topic: Instrumental Variables
title: Manual 2SLS
language: Stata
---

In this week's exercises, you will be using data from [Michler et al. (2019)](https://www.sciencedirect.com/science/article/pii/S0095069617307532), which studies the impact of conservation agriculture (CA) on crop yields in Zimbabwe. CA adoption (`CA`) is endogenous — farmers who adopt CA may differ systematically from those who don't. In the paper, we instrument CA adoption using `wardNGO`, the number of other households in the same ward that received NGO support for CA.

- Load `"$data/Michler_JEEM.dta"` and keep only maize observations (`keep if crops == 1`).
- Run a naive **OLS** regression of `lnyield` on `CA` with the following controls: `lnbasal lntop lnseed lnaream2 pdate pdate2 i.year`, clustering standard errors at the `rc` level. Store the results as `ols`.
- Run the **First Stage**: Regress the endogenous variable (`CA`) on the instrument (`wardNGO`) and all the same controls (`lnbasal lntop lnseed lnaream2 pdate pdate2 i.year`), clustering at `rc`. Store as `first`.
- Generate the predicted fitted values from the first stage using `predict CA_hat, xb`.
- Run the **Second Stage**: Regress `lnyield` on `CA_hat` and the same controls, clustering at `rc`. Store as `manual`.


1\. Export a two-column table comparing OLS and Manual 2SLS and put it in your Overleaf file:

```stata
* compare ols and manual 2sls
	esttab          ols manual using "$answ/13-iv-manual.tex", replace ///
	                    b(3) se(3) ///
	                    keep(CA) rename(CA_hat CA) nodepvars ///
	                    star(* 0.10 ** 0.05 *** 0.01) ///
	                    nomtitles ///
	                    stats(N r2, labels("Observations" "R-squared") ///
	                          fmt(0 3)) ///
	                    noobs booktabs nonum collabels(none) ///
	                    nobaselevels nogaps fragment label ///
	                    prehead("\begin{tabular}{l*{2}{c}} " ///
	                        "\\[-1.8ex]\hline \hline \\[-1.8ex] " ///
	                        "& \multicolumn{1}{c}{OLS} & " ///
	                        "\multicolumn{1}{c}{Manual 2SLS} " ///
	                        "\\ \midrule") ///
	                    postfoot("\hline \hline \\[-1.8ex] " ///
	                        "\multicolumn{3}{p{\linewidth}}{\small " ///
	                        "\noindent \textit{Note}: Dependent var. " ///
	                        "is log maize yield. Standard errors " ///
	                        "clustered at household level in " ///
	                        "parentheses. Manual 2SLS standard errors " ///
	                        "are incorrect. " ///
	                        "* p$<$0.10, ** p$<$0.05, *** p$<$0.01.} " ///
	                        "\end{tabular}")
```

2\. Does the coefficient on CA increase or decrease when you move from OLS to the manual 2SLS? What does this tell you about the direction of the selection bias?

---
