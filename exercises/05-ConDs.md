---
layout: exercise
topic: Data Analysis
title: Conditional Distributions
language: Stata
---

Using the `eth_allrounds_final` data, explore how the distribution of an input varies across groups.

1. Pick an input variable such as **total hired labor days** (`total_hired_labor_days`) or **total family labor days** (`total_family_labor_days`).

2. Use `sum, detail` to summarize this variable **separately** for:
   - Plots with **improved** seed (`improved == 1`), and  
   - Plots without improved seed (`improved == 0`).

3. Draw **two histograms** (or kernel densities), one for each group, on the same graph or in separate graphs using `if` conditions.

4. Based on the summaries and graphs, write 2–3 sentences describing how the distribution of labor days differs between plots with improved seed and those without.
