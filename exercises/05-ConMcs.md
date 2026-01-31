---
layout: exercise
topic: Data Analysis
title: Conditional Means (Continuous)
language: Stata
---

Using the `eth_allrounds_final` data, now consider how an outcome varies with a **continuous** household-level variable by binning it.

1. Use `xtile` to create quartiles of **household asset index** (`hh_asset_index`):

    ```stata
    xtile asset_q = hh_asset_index, nq(4)
    ```

2. For each asset quartile, compute the **mean harvest value** (`harvest_value_USD`) and the number of observations (e.g., using `tabstat`).

3. Make a graph showing the mean harvest value by asset quartile:
   - You can use `graph bar (mean) harvest_value_USD, over(asset_q)`  
   - Add informative titles and axis labels.

4. Briefly describe how mean harvest value changes across asset quartiles. Does higher asset index appear to be associated with higher harvest value?
