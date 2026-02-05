---
layout: exercise
topic: Data Analysis
title: Conditional Means (Continuous)
language: Stata
---

Using the `eth_allrounds_final` data, now consider how an outcome varies with a continuous household-level variable by binning it.

1. Use `xtile` to create quartiles (`asset_q`) of household asset index (`hh_asset_index`). Label the variable as "Asset Quartiles". For each asset quartile, use `bys` and `sum` to compute the mean harvest value (`harvest_value_USD`). Which quartile has the higest mean value of harvest?

2. Make a bar graph using `hbar` showing the mean harvest value (`harvest_value_USD`) `over` both asset quartile (`asset_q`) and `over` if the household experienced a shock to their crops (`crop_shock`).
    1. Add an informative title and axis label. 
    2. Tell Stata to treat the categories as if the first category are variables on y-axis (`asyvar`). This will allow us to change the color of each bar.
    3. Set the color and intensity of bar 1 as `navy*3`
    4. Color bar 2 `forest_green`, bar 3 `sienna`, and bar 4 `maroon`
    5. Place the legend on the bottom of the graph (`pos`) in four column (`col`)
    6. Label group 1 "lowest", group 2 as "Lower Middle", group 3 as "Upper Middle", and group 4 as "Highest"

---
