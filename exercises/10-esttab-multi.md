---
layout: exercise
topic: LaTeX
title: Multi-Column Table with Notes
language: Stata
---

Using `tenuredata.dta` (rice observations only), produce a multi-column regression table and export it to LaTeX. Run and store three regressions, all with `vce(cluster panelid)`:

- **r1**: `yield` on `q_f_ha lt_f_ha`
- **r2**: `yield` on `q_f_ha lt_f_ha i.irrig i.tenure`
- **r3**: `yield` on `q_f_ha lt_f_ha i.irrig i.tenure i.site i.year`

Display a three-column table with `esttab` and export it to LaTeX using the `prehead`, `postfoot`, and `fragment` options to create grouped column headers and a detailed note:

```stata
   esttab      r1 r2 r3 using "$answ/10-rice-regs.tex", replace ///
                   b(3) se(3) ///
                   keep(q_f_ha lt_f_ha 1.irrig 1.tenure) ///
                   order(q_f_ha lt_f_ha 1.irrig 1.tenure) ///
                   star(* 0.10 ** 0.05 *** 0.01) ///
                   indicate("Site FE = *.site" "Year FE = *.year") ///
                   stats(N r2, labels("Observations" "R-squared") fmt(0 3)) ///
                   noobs booktabs nonum nomtitle collabels(none) ///
                   nobaselevels nogaps fragment label ///
                   prehead("\begin{tabular}{l*{3}{c}} " ///
                     "\\[-1.8ex]\hline \hline \\[-1.8ex] " ///
                     "& \multicolumn{1}{c}{Baseline} & " ///
                     "\multicolumn{2}{c}{With Controls} \\ " ///
                     "\cline{2-2} \cline{3-4} \\[-1.8ex] " ///
                     "& \multicolumn{1}{c}{(1)} & " ///
                     "\multicolumn{1}{c}{(2)} " ///
                     "& \multicolumn{1}{c}{(3)} \\ \midrule") ///
                   postfoot("\hline \hline \\[-1.8ex] " ///
                     "\multicolumn{4}{p{0.8\linewidth}}{\small " ///
                     "\noindent \textit{Note}: Dependent variable " ///
                     "is rice yield in kg/ha. All models use " ///
                     "OLS with standard errors clustered at the " ///
                     "household level (in parentheses). " ///
                     "* p$<$0.10, ** p$<$0.05, *** p$<$0.01.} " ///
                     "\end{tabular}")
```

In your `lastname.tex`, include the table using `\input{10-rice-regs.tex}` inside a `table` environment. To get the `***` to render correctly, you'll need to add 
`\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}` to your preamble.

---
