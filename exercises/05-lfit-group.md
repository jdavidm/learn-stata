---
layout: exercise
topic: Graphing
title: Fitted Lines by Group
language: Stata
---

Using the `eth_allrounds_final` data, connect the fitted line on a scatter plot to the underlying regression.

1. Create a scatter plot of **harvest value** (`harvest_value_USD`) versus **farm size** (`farm_size`), and add a fitted line using `lfit` in a `twoway` graph.

2. Run the corresponding regression:

    ```stata
    regress harvest_value_USD farm_size
    ```

   - Record the estimated intercept and slope.

3. Explain how the regression slope relates to the line in your scatter plot:
   - What does a one-unit increase in farm size represent?  
   - How much does harvest value change, on average, for a one-unit increase in farm size according to the fitted line?

4. Now let the relationship differ by **irrigation status**:
   1. Draw a scatter plot with separate fitted lines for irrigated and rainfed plots (using `if irrigated == 1` and `if irrigated == 0` in `twoway`).
   2. Run a regression that allows different intercepts by irrigation status:

        ```stata
        regress harvest_value_USD farm_size i.irrigated
        ```

   3. Compare the intercepts from the regression output with the two fitted lines. What does the coefficient on `1.irrigated` tell you about differences in harvest value between irrigated and rainfed plots, holding farm size fixed?

---
