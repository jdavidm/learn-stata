---
layout: exercise
topic: Regression
title: Factor Variables and Interactions
language: Stata
---

This exercise covers how to handle categorical controls, interaction terms, and polynomials using Stata's factor variable (`i.`) and continuous variable (`c.`) prefixes.

### Tasks

1. In your do-file, start with a fresh load of `eth_allrounds_final.dta`.
2. First, control for regional differences. Run a regression of `yield_kg` on `nitrogen_kg` and `plot_area_GPS`, including regional fixed effects by adding `i.region` to the list of independent variables.
3. Check the output. Which region is omitted by Stata as the "reference" category? (It will have a coefficient listed as 0 or empty.)
4. Now, test if the relationship between nitrogen and yield differs based on whether the plot is irrigated. Run a regression with an interaction term between nitrogen and irrigation:
   ```stata
   regress yield_kg c.nitrogen_kg##i.irr
   ```
5. In comments, answer the following based on the interaction output:
   - What is the slope of the yield-nitrogen line for rainfed plots (the `0.irr` reference group)?
   - What is the coefficient on the interaction term `1.irr#c.nitrogen_kg`? 
   - Does applying nitrogen have a stronger (steeper slope) or weaker association with yield on irrigated plots compared to rainfed plots?
6. Finally, try fitting a curve. Run a regression with a polynomial term for nitrogen:
   ```stata
   regress yield_kg c.nitrogen_kg##c.nitrogen_kg
   ```
7. Look at the coefficient on the squared term (`c.nitrogen_kg#c.nitrogen_kg`). In comments, explain what its sign (positive or negative) implies about diminishing returns to nitrogen fertilizer.
