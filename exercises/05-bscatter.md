---
layout: exercise
topic: Graphing
title: Basic Scatter Plots
language: Stata
---

Using the `eth_allrounds_final` data,

1. Make a scatter plot of **harvest value** versus **farm size**:

    ```stata
    scatter harvest_value_USD farm_size
    ```

   - Which variable is on the x-axis? Which is on the y-axis?

2. Redraw the same scatter plot with informative labels and a title:

    ```stata
    scatter harvest_value_USD farm_size, ///
        title("Harvest value vs farm size") ///
        xtitle("Farm size") ///
        ytitle("Harvest value (USD)")
    ```

3. Change the appearance of the markers:
   1. Use hollow circles and smaller points.  
   2. Try tiny solid points.

   For each version, briefly note which is easier to read and why.
