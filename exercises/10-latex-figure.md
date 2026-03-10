---
layout: exercise
topic: Producing Results
title: Inserting a Stata Figure
language: Stata
---

Using `tenuredata.dta`, create a graph in Stata and include it in your LaTeX document.

1\. Load `tenuredata.dta` and keep only rice observations (`keep if rice == 1`).
2\. Create a scatter plot of `yield` against `q_f_ha` (fertilizer per hectare) with a fitted line:
   ```stata
   twoway      (scatter yield q_f_ha, msymbol(oh) msize(vsmall)) ///
               (lfit yield q_f_ha), ///
                   title("Rice yield vs fertilizer") ///
                   xtitle("Fertilizer (kg/ha)") ///
                   ytitle("Yield (kg/ha)")
   ```
3\. Export the graph: `graph export "$answ/10-scatter-rice.png", replace`
4\. In your `lastname.tex` under Assignment 10, include the graph using:
   ```latex
   \begin{figure}[htbp]
       \centering
       \includegraphics[width=0.8\textwidth]{10-scatter-rice.png}
       \caption{Rice yield vs fertilizer application}
       \label{fig:scatter_rice}
   \end{figure}
   ```
5\. Compile in Overleaf and verify the figure appears.

---
