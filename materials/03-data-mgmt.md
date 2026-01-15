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

You already know how to use `generate` (`gen`) to make new variables from existing ones. Stata has an "extended generate" (`egen`) command that comes with a number of built in functions that allow you to create variables using calculations that otherwise would be very tedious and verbose to code up. The big advantage of `egen` is that it:
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
  * `tag()` – mark one observation per group

#### Example: row operations

Suppose you have three exam scores:

```stata
  describe      test1 test2 test3
```

Suppose we wanted to calculate the average (or total) score across all three tests. One way to do this is:


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
  * `egen` commands like `rowmean()` **ignores missing values** by default (averages over the nonmissing exams).
  * The simple arithmetic version treats missing as missing for the entire expression.

#### Example: group-level statistics with `egen` and `bysort` (`bys`)

Often we want statistics **by group**, but still keep the individual-level data.

Let's say we wanted to calculate the mean wage by industry:

```stata
  bys industry:   egen ind_mean_wage = mean(wage)
```
Now each worker’s row now includes the mean wage for their industry. We could then calculate each worker's wage deviation from the mean for their industry:

```stata
  gen             wage_rel_to_ind = wage - ind_mean_wage
```

Another useful example is calculating the number of observations per group:

```stata
bys industry:     egen n_industry = count(wage)
```

Now each row contains how many workers are in that industry.

> Do [Exercise 4.1 - Create Variables]({{ site.baseurl }}/exercises/03-gen-var/)


### Aggregating data with `collapse`

`collapse` is used when you want to **replace your dataset with summary statistics**.
  * It takes your current dataset,
  * calculates summary statistics (means, sums, etc.),
  * and **replaces** the data in memory with the aggregated dataset.

This is useful for:
  * going from individual-level data to **household**, **village**, or **region** level,
  * creating datasets of summary statistics for tables or graphs.

Collapse (which simply aggregates data in different ways) is our trickiest concept and syntax that we've dealt with so far, but don't worry, you will have lots of opportunities to practice. The concept is trickiest because the `collapse` function changes not just the content of a variable or multiple variables but changes the structure of the data. It is very easy to get wrong and then end up with data that looks nothing like what you wanted it to be. Examples of what you might use `collapse` for are:
  * Take crop-level data and collapse it to the plot-level
  * Take plot-level data and collapse it to the household-level
  * Take individual-level data and collapse it to the houeshold-level
  * Take household-level data and collapse it to the state-level

In terms of tricky syntax, well just look at the following:

```stata
collapse (stat1) varlist1 (stat2) varlist2 ..., by(groupvars)
```

Here:
  * `stat1`, `stat2`, ... might be `mean`, `sum`, `count`, `median`, etc. So 
  * `by(groupvars)` tells Stata what the new observations will represent.

#### 2.2 Example: going from individuals to regions

Suppose you start with individual-level data:

```stata
  list           id region wage in 1/6, sepby(region)
```

You want one row per region, with:

  * mean wage in the region,
  * number of individuals in the region.

```stata
  collapse      (mean) wage ///
                (count) id, by(region)

  rename        id N
  lab var       wage "Mean wage in region"
  lab var       N "Number of individuals in region"

list
```

After `collapse`:

  * each row is now **one region**,
  * `wage` is the **mean wage** in that region,
  * `N` is the **number of individuals** you started with in that region.

It is important to remember that **`collapse` overwrites your data!!** After `collapse`, your original individual-level data are **gone from memory**. But, as long as you are not overwrighting the raw data, and you are writing reproducible code, you can always get back to what the data looked like before you collapsed it.

---

### 3. Appending datasets with `append`

`append` is used to **stack datasets on top of each other** (add more rows).

Think:

  * survey rounds in different years,
  * data from different regions with the same variables,
  * files that have been split because they were too large.

#### 3.1 Concept

  * The dataset in memory is the **master** dataset.
  * The dataset(s) you add are the **using** dataset(s).
  * After `append`, you have all rows from master **plus** all rows from using.

#### 3.2 Basic syntax

```stata
use "survey_2020.dta", clear   // master data in memory
append using "survey_2021.dta" // add rows from using data
```

After this:

  * all observations from 2020 and 2021 are in a single dataset.
  * If both files had the same variables and types, they will line up nicely.

#### 3.3 Variables that don’t match

What if the two datasets don’t have exactly the same variables?

  * If a variable exists **only in master**:
    * observations from `using` will have that variable as **missing**.
  * If a variable exists **only in using**:
    * observations from `master` will have that variable as **missing**.
  * If a variable has the **same name but different type** (numeric vs string):
    * Stata will **error**. You must fix the types before appending.

#### 3.4 Tracking where observations came from

It is often useful to know which dataset each observation came from.

```stata
use "survey_2020.dta", clear
append using "survey_2021.dta", generate(source)
```

  * Stata creates a new variable `source`:
    * `source == 0` for observations from the master (2020),
    * `source == 1` for observations from the using dataset (2021).

You can label it:

```stata
label define source_lbl 0 "2020 survey" 1 "2021 survey"
label values source source_lbl
label variable source "Source survey year"
```

You can also append multiple datasets in one go:

```stata
use "survey_2019.dta", clear
append using "survey_2020.dta" "survey_2021.dta", generate(source)
```

---

### 4. Merging datasets with `merge`

`merge` is used to **add variables (columns)** to your data by joining two datasets on one or more **key variables**.

Compare:

  * `append` → more **rows** (stack datasets).
  * `merge` → more **columns** (combine information about the same units).

#### 4.1 Master vs using

As with `append`:

  * Dataset in memory = **master**.
  * Dataset on disk = **using**.

We merge them based on one or more key variables (e.g., `id`, `hhid`, `region`).

#### 4.2 Types of merges

Most common in applied work:

  * **one-to-one (`1:1`)**  
    * each key appears at most once in master and once in using.
  * **many-to-one (`m:1`)**  
    * many rows in master per key, one row per key in using.
    * Example: household data (many households per region) merged with region data (one row per region).

Stata also supports `1:m` and `m:m`, but `m:m` is almost never what you want and is dangerous. In this class we’ll mostly use `1:1` and `m:1`.

#### 4.3 Example: many-to-one (`m:1`) merge

Goal: add region-level data to household-level data.

  * `households.dta` – household-level data, one row per household, includes `region`.
  * `region_data.dta` – region-level data, one row per region, includes `region`.

```stata
* Master: household data
use "households.dta", clear

* Merge in region characteristics
merge m:1 region using "region_data.dta"
```

Stata will:

  * match observations where `region` is the same in both datasets,
  * add the region variables to each household in that region,
  * create a variable called `_merge` that records **how** each observation matched.

Check the merge results:

```stata
tabulate _merge
```

Common `_merge` values:

  * `1` – observation only in master (no match in using)
  * `2` – observation only in using (no match in master)
  * `3` – observation in both (matched)

Often we keep only matched observations:

```stata
keep if _merge == 3
drop _merge
```

#### 4.4 Example: one-to-one (`1:1`) merge

Goal: link baseline and endline survey for the same households.

  * `baseline.dta` – one row per `hhid` at baseline.
  * `endline.dta` – one row per `hhid` at endline.

```stata
use "baseline.dta", clear
merge 1:1 hhid using "endline.dta"
```

Again:

  * Check `_merge` to see which households are only in baseline, only in endline, or in both.
  * Decide which ones to keep.

#### 4.5 What happens to variables with the same name?

If a variable with the **same name** exists in both master and using:

  * Stata keeps the master version,
  * and renames the using version `varname_using`.

Example:

  * Both datasets have `wage`.
  * After merge you will see `wage` (from master) and `wage_using` (from using).

You need to decide:

  * which one to keep,
  * whether to check that they agree.

Example:

```stata
summarize wage wage_using
drop wage_using   // if you decide to keep the master version
```

#### 4.6 Keys and data quality

Merges are only as good as your key variables.  
Good habits:

  * Make sure your key uniquely identifies observations when it’s supposed to.
  * For `1:1` merges, check uniqueness:

```stata
use "baseline.dta", clear
isid hhid   // checks whether hhid uniquely identifies observations
```

  * For `m:1` merges, check uniqueness in the **using** dataset:

```stata
use "region_data.dta", clear
isid region
```

If `isid` fails, your merge assumptions are wrong and you should fix the keys or data.