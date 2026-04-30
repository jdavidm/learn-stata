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

- Create a random train/test split. Set a seed for reproducibility (`8675309`), generate a uniform random variable (`runiform()`) called `u`, and generate a variable called `sample` that defines the training set as observations where the random value is below 0.70 (70% training, 30% test).


2\. How many observations are in the training set? How many are in the test set? Report the numbers.

- Initialize the H2O cluster with `h2o init`. If you have not installed Java, follow the instructions on the [Computer Setup]({{ site.baseurl }}/computer-setup/) page first.
- Push the dataset to an H2O frame with using `plot_data` as the *newframename*.

---
