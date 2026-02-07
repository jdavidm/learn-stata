---
layout: exercise
topic: Data Analysis
title: Challenge 5
language: Stata
---

For this challenge we are going to switch up the data and use a data set of women’s labor force participation and earnings from 1975. The data comes from the paper [The Sensitivity of an Empirical Model of Married Women's Hours of Work to Economic and Statistical Assumptions](https://doi.org/10.2307/1911029) by Thomas A. Mroz.

Download the `Mroz.dta` file from the [list of data sets](https://jdavidm.github.io/learn-stata/materials/datasets/) on the course website. Load the data using `use`.

We are going to analysis women's income conditional a a number of different variables. Since we want to understand how women's earnings varies based on these other variables, start by using `kkep if` to drop from the data set any woman who does not participate in the labor force.

In the data set, women's earnings have been logged (`lwg`). We want the unlogged version so create a new variable called `earn` that is the unlogged `lwg`. Recall to undo a log we exponentiate the value (`exp()`) using *e*. Also, use `drop if` to drop any values of income (`inc`) that are less than 0.

1\. Draw a `scatter` plot with `earn` on the x-axis and `inc` on the y-axis. Because of the long tail in data like `inc` we want to "normalize" the data a bit by graphing both variables on a log scale. Use the graphing option `yscale(log)` and `xscale(log)`.

2\. Use `tabstat` to get mean (`stat(mean)`) earnings conditional on (`by`) college attendance (`wc`). Are average earnings higher if the wife attended college or did not attend college?

3\. Now, use `egen` with `cut` to create 10 groups (deciles) based on family income `inc`. Use `tabstat` to get mean (`stat(mean)`) earnings conditional on (`by`) being in one of the 10 deciles (`inc_cut`). Do women in households that are in the highest decile (group 10) by family income earn the most money?

4\. Create a new variable called `loginc` that is the logged value (`log()`) of family income (`inc`).
   - Make a scatter plot with log family income (`log_inc`) on the y-axis and log women's earnings (`lwg`) on the x-axis.
   - Change the marker color to gray and make it 50% transparent (`gray%50`).
   - To this scatter plot at a fitted line using `lfit`.
   - Change the color of this line to `navy`, change the pattern to `solid` and change the width of the line to `thick`.
   - Also add a fitted line using `lowess`. This fits a locally weighted non-linear regression line to the data. 
   - Change the color of this line to `maroon`, change the pattern to `solid` and change the width of the line to `thick`.

5\. Run two regressions (`regress`). For the first one, regress the log of women's earnings on the log of family income. For the second one add college attendance (`wc`) as a control. Is the unconditional relationship between family income and women's earnings stronger then that relationship when we condition on college attendance (which regression has the larger co-efficient)?
---
