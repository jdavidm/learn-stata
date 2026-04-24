---
layout: exercise
topic: Machine Learning
title: Setup and Train/Test Split
language: Stata
---

Before fitting any ML models, we need to prepare our data and create a proper train/test split. For all exercises this week we use `plot_dataset.dta` — a plot-crop level dataset on agricultural production from Ethiopia, Malawi, Mali, Niger, Nigeria, Tanzania, and Uganda. It contains 257,145 observations across 8 waves. The unique identifier is `plot_id_obs season`. You can download the data from the [list of datasets page]({{ site.baseurl }}/materials/datasets/).

The prediction task for this week is to forecast **crop yield** (`yield_kg`) using plot characteristics, input use, manager demographics, soil quality, geography, and shock variables.

- Load `plot_dataset.dta`.
- Examine the data. How many countries are represented? How many observations are there? What is the mean yield?

```stata
* load data
    use             "$data/plot_dataset.dta", clear

* examine the data
    tab             country
    sum             yield_kg, detail
```

- Create a random train/test split. Set a seed for reproducibility, generate a uniform random variable, and define the training set as observations where the random value is below 0.70 (70% training, 30% test):

```stata
* set seed for reproducibility
    set seed        597

* create random split variable
    gen             u = runiform()
    gen             sample = (u < 0.70)
    *** sample == 1 is training, sample == 0 is test
    drop            u
    tab             sample
```

- Initialize the H2O cluster with `h2o init`. If you have not installed Java, follow the instructions on the [Computer Setup]({{ site.baseurl }}/computer-setup/) page first.
- Push the dataset to an H2O frame with `_h2oframe put, replace`.

1. How many observations are in the training set? How many are in the test set? Report the numbers.

2. Why do we set a seed before generating the random split? What would happen if we didn't?

---
