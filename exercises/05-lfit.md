---
layout: exercise
topic: Graphing
title: Fitted Lines
language: Stata
---

Using the `eth_allrounds_final` data, add a fitted line and confidence interval to a scatter plot, and adjust the appearance.
1. Make a scatter plot with yield (`yield_kg`) on the y-axis and inorganic fertilizer (`inorganic_fertilizer_value_USD`) on the x-axis, restricting observations to only maize (`crop == 3`).
   - Add a fitted line with a confidence band using `lfitci` in a `twoway` graph.
   - Place the legend on the bottom (`pos`) in three columns (`col`).
   - Use very small, hollow circular markers for the points.
   - Change the color of the line to `maroon` and the pattern of the line to be solid (use `lcolor` and `lpattern`).
   - Make the color of confidence band gray and partially transparent (`gray%50`) so the points and line remain visible (use `fcolor`).
   - Label the x-axis "Inorganic Fertilizer (USD)" and the y-axis as "Maize Yield (kg)"

2. What is the relationship between yield and fertilizer use? Positive? Negative? No relationship?

---
