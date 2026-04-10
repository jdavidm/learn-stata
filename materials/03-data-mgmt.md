---
layout: page
element: notes
title: Manipulating Data
language: Stata
---

### Manipulating Data

A lot of applied economics work is about **reshaping and combining data** so that you can run the analysis you care about. This can involve:
  * Replacing the value of existing variables (`replace`)
  * Creating new variables (`gen` and `egen`)
  * Aggregating data (`collapse`)
  * Stacking datasets (`append`)
  * Joining datasets (`merge`)
  
These operations are the building blocks for going from raw survey data to analysis-ready panels, combining different data sources, and creating the summary datasets used in tables and figures.

### Creating variables

You already know how to use `gen` to make new variables from existing ones. Stata has an "extended generate" (`egen`) command that comes with a number of built in functions that allow you to create variables using calculations that otherwise would be very tedious and verbose to code up. The big advantage of `egen` is that it:
  * works across **multiple variables in the same row** (e.g., row means),
  * or across **multiple observations** (e.g., group means, counts, ranks).
The general syntax is:

```stata
egen newvar = function(arguments) [if] [in] [, options]
```

Some of the most useful `egen` functions are:

  * `rowmean()` – mean across variables in the same row
  * `rowtotal()` – sum across variables in the same row
  * `mean()` – group-level mean
  * `sum()` – group-level sum
  * `count()` – number of nonmissing values

#### Example: row operations

Suppose you have three exam scores (`test1 test2 test3`) and we wanted to calculate the average (or total) score across all three tests. One way to do this is:


```stata
* create mean test score
  gen           test_mean = (test1 + test2 + test3) / 3

* create total test score
  gen           test_tot = (test1 + test2 + test3)
```

We can do this same operation using `egen`:

```stata
* create mean test score
  egen           test_mean = rowmean(test1 test2 test3)

* create total test score
  egen           test_tot = rowtotal(test1 test2 test3)
```

In this case, the two commands are not that much different. So why use `egen rowmean()` instead of `gen`?
  * `egen` commands like `rowmean()` **ignore missing values** by default (averages over the nonmissing exams).
  * The simple arithmetic version treats missing as missing for the entire expression.

#### Example: group-level statistics with `egen` and `bysort` (`bys`)

Often we want statistics **by group**, but still keep the individual-level data.

Let's say we wanted to calculate the mean wage by industry:

```stata
  bys industry:   egen ind_mean_wage = mean(wage)
```
Now each worker’s row now includes the mean wage for their industry. We could then calculate each worker's wage deviation from the mean for their industry:

```stata
  gen             wage_diff = wage - ind_mean_wage
```

Another useful example is calculating the number of observations per group:

```stata
bys industry:     egen n_industry = count(wage)
```

Now each row contains how many workers are in that industry.

> Do [Exercise 5.1 - Create Variables]({{ site.baseurl }}/exercises/03-gen-var/)


### Aggregating data

`collapse` is used when you want to **replace** your dataset with summary statistics. It takes your current dataset, calculates summary statistics (means, sums, etc.), and **replaces** the data in memory with the aggregated dataset.

This is useful for:
  * Adding up crop-level area data to a plot-level value for the size of the plot
  * Averaging plot-level yield data to a household-level value for average yield
  * Counting household members in individual-level data to a houeshold-level value for the number of people in a household
  * Determining the maximum income of a household in household-level data aat the state-level

Collapse (which simply aggregates/summarizes data in different ways) is our trickiest concept and syntax that we've dealt with so far. The concept is trickiest because the `collapse` function changes not just the content of a variable or multiple variables but changes the structure of the data. It is very easy to get wrong and then end up with data that looks nothing like what you wanted it to be. In terms of tricky syntax, well just look at the following:

```stata
collapse (stat1) varlist1 (stat2) varlist2 ..., by(groupvars)
```

Here:
  * `stat1`, `stat2`, ... might be `mean`, `sum`, `count`, `median`, etc. 
  * `by(groupvars)` tells Stata what the new observations will represent.

Suppose you start with individual-level data (each row represents data on an individual). You want one row per region, with:
  * mean wage in the region,
  * number of individuals in the region.

```stata
  collapse      (mean) wage ///
                (count) id, by(region)

  rename        id N
  lab var       wage "Mean wage in region"
  lab var       N "Number of individuals in region"
```

After `collapse`:
  * each row is now one region,
  * `wage` is the mean wage in that region,
  * `N` is the number of individuals you started with in that region.

It is important to remember that `collapse` **overwrites your data!!** After `collapse`, your original individual-level data are **gone from memory**. But, as long as you are not overwriting the raw data, and you are writing reproducible code, you can always get back to what the data looked like before you collapsed it.

> Do [Exercise 6 - Change Variables]({{ site.baseurl }}/exercises/03-chg-var/)


### Appending datasets

We frequently want to combine one data set with another. The `append` command is used to **stack datasets on top of each other** (add more rows).

Think of:
  * survey rounds in different years
  * data from different regions with the same variables
  * files that have been split because they were too large

When combining any two data sets in any way, it is important to understand how Stata views each data set, because that will tell you how Stata will resolve conflicts. Whatever data set is currently loaded into Stata (referred to as being "in memory") is the **master** data set. The dataset you add is the **using** dataset (referred to as being "on disk"). After `append`, you have all rows from master plus all rows from using.

The basic syntax of append is

```stata
* master data in memory
  use           "survey_2020.dta", clear

* add rows from using data on disk
  append        using "survey_2021.dta"
```

After this all observations from 2020 and 2021 are in a single dataset. If both files had all the same variables and types, everything will line up nicely. But what if the two datasets don’t have exactly the same variables?
  * If a variable exists **only in master**, then observations from `using` will have that variable as **missing**
  * If a variable exists **only in using**, then observations from `master` will have that variable as **missing**.
  * If a variable has the **same name but different type** (numeric vs string), then Stata will **error**. You must fix the types before appending.

> Do [Exercise 7 - Append Data]({{ site.baseurl }}/exercises/03-append/)


###  Merging datasets

While append adds observations (rows), the `merge` command adds variables (columns) by joining two datasets on one or more **key variables**. Understand what this key variable is and how it structures the data is incredibly important because otherwise you might not be able to merge or you might merge in such a way that fundamentally changes the structure of your data. As with `append`, the dataset currently loaded into Stata is the one in memory (master) while the other data set is the using (on disk) data.

There are three types of merges:
  * one-to-one (`1:1`): each key appears at most once in the master and once in the using
  * one-to-many (`1:m`): one row per key in the master but many rows per key in the using
    * merging household data (using) into state-level data (master) - many households in a given state
  * many-to-one (`m:1`): many rows in the master per key but only one row per key in the using
    * merging household data (using) into plot-level data (master) - one household manages many plots

#### Example: one-to-one (`1:1`) merge

Goal: link baseline and endline survey for the same households.
  * `baseline.dta` – one row per `hhid` at baseline.
  * `endline.dta` – one row per `hhid` at endline.

The key here is the `hhid` variable. This variable must uniquely identify each row in both data sets. So, each row in the data represents information on a household. And each household is assigned a unique `hhid`. That way, we can perfectly identify which row of data corresponds to which household. We can find the unique id in a data set by using the `isid` command (but more on that later).

```stata
* master data in memory
  use           "baseline.dta", clear

* add columns from using data on disk
  merge 1:1     hhid using "endline.dta"
```

When you merge, Stata creates a new variable (`_merge`) that identifies which rows merged and which didn't and the source (master or using) of those rows. It also automatically outputs a results table:

```stata
Result                           # of obs.
    -----------------------------------------
    Not matched                           125
        from master     (_merge==1)       40  
        from using      (_merge==2)       85  

    Matched                             1,875
        from both       (_merge==3)    1,875
    -----------------------------------------
```

With this information you can see how successful your merge was. You can check `_merge` to see which households are only in baseline, only in endline, or in both. Then you can decide which ones to keep. In most cases you will end up dropping anything that didn't match for both (`drop if _merge != 3`) but there are cases where you will want to keep some or all of the unmatched observations.

#### Example: many-to-one (`m:1`) merge

Goal: add region-level data to household-level data.
  * `households.dta` – household-level data, one row per household, includes `region`.
  * `region_data.dta` – region-level data, one row per region, includes `region`.

Again, the key here is what variable you use as the key. Assume each household lives in a region and there is a unique identifier for each region. So, in the household data, the value that `region` takes uniquely tells us what region a household lives in. But there will be many instances of the single value, since multiple households live in each unique region. But in the region data, there is only one row per region, and therefore the value of `region` uniquely identifies the region and the unit record (row). To merge these, you would tell Stata:

```stata
* naster: household data
  use           "households.dta", clear

* merge in region characteristics
  merge m:1     region using "region_data.dta"
```

Stata will match observations where `region` is the same in both datasets by adding the region variables to each household in that region. It will also create a variable called `_merge` that records **how** each observation matched, just like before.

In understanding how `merge` can change your data, it is important to remember (or note down in a Stata comment `*`) the number of observations in the master data and the using data pre-merge and then again post-merge. In our many-to-one example, assuming we have data on each region, the number of observations post-merge should not exceed the number of observations pre-merge. But, if we merged one-to-many (we merged household data **into** the region data) we sould suddenly have a much larger data set then the pre-merge region data set, because we've duplicated each of the region observations for every household in that region.

#### Other considerations

What happens to variables with the same name? If a variable with the same name exists in both master and using Stata keeps the master version, and renames the using version `varname_using`. If both datasets have `wage`, then after merge you will see `wage` (from master) and `wage_using` (from using). You need to decide which one to keep and whether to check that they agree.

Merges are only as good as your key variables. So it is a very good habit to:
  * Check for a variable(s) that uniquely identify the data **every time you load data**
  * Verify which variable(s) uniquely identify the data **every time you save data**
This helps make sure your key uniquely identifies observations when it’s supposed to, which is import any time you change the structure of the data by
  * Collapsing
  * Appending
  * Merging

```stata
  use         "baseline.dta", clear

* check whether hhid uniquely identifies observations
  isid        hhid
```

If `isid` fails, your merge assumptions are wrong and you should fix the keys or data.


> Do [Exercise 8 - Merge Data]({{ site.baseurl }}/exercises/03-merge/)
### Summary

- Reshaping and combining data are critical preliminary steps in most analysis pipelines.
- Use 'gen' and 'replace' for variables, and 'egen' for row-level or grouped calculations.
- Efficient aggregation ('collapse') and stacking ('append') build your final analytical dataset.
