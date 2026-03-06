---
layout: exercise
topic: Problem Solving
title: Online Help
language: Stata
---

In this exercise you will practice using online resources (Statalist, Stack Overflow, etc.) to solve a coding problem and adapt example code safely. For exercise 1-3 you developed and partially implemented a plan to turn the plot-level data set into a household-level data set. In laying out that plan you most likely proposed using the `collapse` function to aggregate each row (plot) into a new data set where each row represented a household.

You need to use the Statalist and/or Stack Overflow to find a way to create a data set that allows you to analyze household-level information without losing the plot-level information (as would happen with collapse). Essentially, the `plot_dataset.dta` has a hierarchical structure: plots (level 1, L1) are clustered in households (level 2, L2). We want to analyze the L2 only values (by aggregation of the L1 values) by keeping just one value for each L2 unit without using `collapse` so that we de facto have two datasets in one.

1\. Go to [Statalist](https://www.statalist.org/forums/) and search within the forum for something like:
- `egen tag by group mean`
- `egen tag() keep one per group`
- `egen mean by() tag()`

Find a post where someone demonstrates tagging one row per group (for example, Nick Cox’s example using `egen tag = tag(groupvar)`). Then adapt that code so that you keep the plot-level data set but have mean `yield_USD`, `total_labor_days`, and `nitrogen_kg` for each household and a tag that identifies one value per household. Call these new variables `mean_yield`, `tot_labor`, and `tot_fert`. Then create a variable that tags a single observations per household and call it `tag_hh`. Label all four variables that you created. In addition to your code, add to your `.do` file a short comment block documenting what you used similar to:

```stata
* online search:
* - search terms:
* - website/post used: statalist (general stata discussion)
* - key idea learned: compute group stats with egen, then egen tag = tag(groupvar)
*   and keep only tag==1 to get one row per group
```

How many observations are tagged with a 1?

2\. To verify that you adapted the code correctly, run a regression with the household mean yield on the left-hand side and household total labor days and nitrogen fertilizer on the right-hand side. What are the coefficients on `tot_labor` and `tot_fert`?

---
