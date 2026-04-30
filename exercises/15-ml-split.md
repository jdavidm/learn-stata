---
layout: exercise
topic: Machine Learning
title: Setup and Train/Test Split
language: Stata
---

Before fitting any ML models, we need to prepare our data and create a proper train/test split. For all exercises this week we use `plot_dataset.dta` — a plot-crop level dataset on agricultural production from Ethiopia, Malawi, Mali, Niger, Nigeria, Tanzania, and Uganda across 8 waves. The unique identifier is `plot_id_obs season`. You can download the data from the [list of datasets page]({{ site.baseurl }}/materials/datasets/).

The prediction task for this week is to forecast **crop yield** (`yield_kg`) using crop type, plot characteristics, input use, manager demographics, soil quality, geography, and shock variables.

- Load `plot_dataset.dta`.

1\. Examine the data. How many observations are there? What is the mean yield?

- Create a random train/test split using `splitsample`. Split 70% training and 30% test, generate a variable called `sample`, and set the random seed to `8675309`. Label the values of `sample` so that 1 is "Training" and 2 is "Testing".

2\. How many observations are in the training set? How many are in the test set? Report the numbers.

---
