---
layout: exercise
topic: Graphing
title: Grouped Scatter Plots
language: Stata
---


Using the `eth_allrounds_final` data,

1. Make a scatter plot of **harvest value** (`harvest_value_USD`) versus **farm size** (`farm_size`) **by irrigation status** (`irrigated`):

   - First, draw a **single** scatter plot using `twoway`, with different colors for irrigated and rainfed plots on the same axes.
   - Second, use the `by(irrigated)` option on `scatter` to make separate panels for irrigated and rainfed plots.

2. For each approach (overlay vs `by()` panels), answer:
   - Which makes it easier to compare irrigated and rainfed plots?  
   - Which makes it easier to see the overall relationship between farm size and harvest value?

3. Repeat part 1 using **urban vs rural** plots (`urban`) instead of irrigation status.

---

### 3. Conditional distributions

In this exercise you’ll explore how the distribution of an input varies across groups.

1. Pick an input variable such as **total hired labor days** (`total_hired_labor_days`) or **total family labor days** (`total_family_labor_days`).

2. Use `sum, detail` to summarize this variable **separately** for:
   - Plots with **improved** seed (`improved == 1`), and  
   - Plots without improved seed (`improved == 0`).

3. Draw **two histograms** (or kernel densities), one for each group, on the same graph or in separate graphs using `if` conditions.

4. Based on the summaries and graphs, write 2–3 sentences describing how the distribution of labor days differs between plots with improved seed and those without.

---

### 4. Conditional means with discrete variables

Here you’ll look at **mean outcomes by group** for a discrete variable.

1. Choose an outcome variable such as **harvest quantity** (`harvest_kg`) or **harvest value** (`harvest_value_USD`).

2. Compute mean outcomes by **plot ownership** (`plot_owned`) using a table and a graph:
   1. Use `tabstat` (or another summary command) to report mean, standard deviation, and number of observations by `plot_owned`.
   2. Make a `graph bar` of the **mean** outcome by `plot_owned`, adding clear axis titles and a figure title.

3. Repeat step 2 for a different grouping variable, such as **soil fertility** (`soil_fertility_index`) or **urban vs rural** (`urban`).

4. In a few sentences, compare the conditional means across groups. Which groups appear to have higher or lower outcomes?

---

### 5. Conditional means with continuous variables (using bins)

Now consider how an outcome varies with a **continuous** household-level variable by binning it.

1. Use `xtile` to create quartiles of **household asset index** (`hh_asset_index`):

    ```stata
    xtile asset_q = hh_asset_index, nq(4)
    ```

2. For each asset quartile, compute the **mean harvest value** (`harvest_value_USD`) and the number of observations (e.g., using `tabstat`).

3. Make a graph showing the mean harvest value by asset quartile:
   - You can use `graph bar (mean) harvest_value_USD, over(asset_q)`  
   - Add informative titles and axis labels.

4. Briefly describe how mean harvest value changes across asset quartiles. Does higher asset index appear to be associated with higher harvest value?

---

### 6. Scatter plots with fitted lines and confidence intervals

In this exercise you’ll add a fitted line and confidence interval to a scatter plot, and adjust the appearance.

1. Make a scatter plot of **household consumption** (`totcons_USD`) versus **household asset index** (`hh_asset_index`).

2. Add a fitted line **with** a confidence band using `lfitci` in a `twoway` graph.

3. Modify the graph to:
   - Use smaller, hollow markers for the points.  
   - Change the color or pattern of the fitted line.  
   - Make the confidence band lighter or partially transparent so the points and line remain visible.

4. Based on the final graph, describe whether consumption appears to increase with the asset index, and whether the relationship looks roughly linear.

---

### 7. Fitted lines and regression coefficients

Here you’ll connect the fitted line on a scatter plot to the underlying regression.

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
