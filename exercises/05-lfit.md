---
layout: exercise
topic: Graphing
title: Fitted Lines
language: Stata
---

Using the `eth_allrounds_final` data, add a fitted line and confidence interval to a scatter plot, and adjust the appearance.

1. Make a scatter plot of **household consumption** (`totcons_USD`) versus **household asset index** (`hh_asset_index`).

2. Add a fitted line **with** a confidence band using `lfitci` in a `twoway` graph.

3. Modify the graph to:
   - Use smaller, hollow markers for the points.  
   - Change the color or pattern of the fitted line.  
   - Make the confidence band lighter or partially transparent so the points and line remain visible.

4. Based on the final graph, describe whether consumption appears to increase with the asset index, and whether the relationship looks roughly linear.
