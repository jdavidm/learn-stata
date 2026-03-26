---
layout: exercise
topic: LaTeX Figures
title: Multi-Model `coefplot`
language: Stata
---

Using `tenuredata.dta`, compare the fertilizer and labor coefficients across multiple specifications.
- Run and store three regressions, all with `vce(cluster panelid)`:
   - **m1**: `yield` on `q_f_ha lt_f_ha i.irrig i.tenure`
   - **m2**: `yield` on `q_f_ha lt_f_ha i.irrig i.tenure i.site`
   - **m3**: `yield` on `q_f_ha lt_f_ha i.irrig i.tenure i.site i.year`
- Create a multi-model coefplot showing only `q_f_ha` and `lt_f_ha`:

   ```stata
   coefplot    (m1, label("Baseline") ) ///
               (m2, label("+ Tenure/Irrig") ) ///
               (m3, label("+ Village/Year FE") ), ///
                  keep(q_f_ha lt_f_ha) xline(0) ///
                  xtitle("Coefficient size")
   ```

- Export the graph: `graph export "$answ/10-coefplot-multi.png", replace`
- In your `lastname.tex`, include the graph using `\includegraphics[width=0.8\textwidth]{10-coefplot-multi.png}`

---
