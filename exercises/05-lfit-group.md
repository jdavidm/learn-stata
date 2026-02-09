---
layout: exercise
topic: Graphing
title: Fitted Lines by Group
language: Stata
---

Using the `eth_allrounds_final` data, connect the fitted line on a scatter plot to the underlying regression.

1\. Create a scatter plot with harvest value (`harvest_value_USD`) on the y-axis and farm size (`farm_size`) on the y-axis.
   - Add a fitted line with a confidence band using `lfitci` in a `twoway` graph.
   - Place the legend on the bottom (`pos`) in three columns (`col`).
   - Use very small, hollow circular markers for the points.
   - Change the color of the line to `maroon` and the pattern of the line to be solid.
   - Make the color of confidence band gray and partially transparent (`gray%50`) so the points and line remain visible.
   - Make the color of the confidence interval lines marron and partially transparent (`maroon%25`) so the points and line remain visible (use `alcolor`).
   - Label the x-axis "Inorganic Fertilizer (USD)" and the y-axis as "Maize Yield (kg)"

2\. Run the corresponding regression:

```stata
   regress        harvest_value_USD farm_size
```

   1\. What does a one-unit increase in farm size represent?  
   2\. How much does harvest value change, on average, for a one-unit increase in farm size ?
   3\. Is the relationship between harvest value and farm size statistically significant?

3\. Now let the relationship differ by whether the household is using traditional seed (`improved == 0`) or improved seed (`improved == 1`). The easiest way to do this is copy the code that makes the graph in problem 1 and then edit it as follows:
   - Change the scatter plot to display only traditional seed and change the marker color to be `maroon%50`.
   - Add a new scatter plot that displays only improved seed and change the marker color to be `navy%50`.
   - Change the fitted line so that it only fits to observations of traditional seeds.
   - Add a new fitted line that fits to observations of improved seed.
   - Using `lcolor`, change the color of the fitted line so that it matches the color of the corresponding markers (so traditional is `maroon` and improved is `navy`).
   - Using `alcolor`, change the color and transparency of the confidence interval lines so that the correspond to the markers and are transparent at `%25`.
   - Change the legend so it is in two columns. Use `order` to restrict the legend to only printing the third and fifth item in the legend and label them as `3 "Traditional Seeds"` and  `5 "Improved Seeds"`

   4\. Run a regression that allows interacts farm size with improved see:

```stata
   regress        harvest_value_USD c.farm_size#i.improved
```

   1\. How much does harvest value change, on average, for a one-unit increase in farm size when traditional seed is used?
   2\. How much does harvest value change, on average, for a one-unit increase in farm size when improved seed is used?
   3\. Are these relationships between harvest value and farm size-seed type statistically significant?

---
