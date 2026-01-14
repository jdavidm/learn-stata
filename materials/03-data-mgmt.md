---
layout: page
element: notes
title: Manipulating Data
language: Stata
---


  * A lot of applied economics work is about **reshaping and combining data** so that you can run the analysis you care about.
  * In this lecture we’ll focus on four key tasks:
    1. Creating variables with `gen` and `egen`
    2. Aggregating data with `collapse`
    3. Stacking datasets with `append`
    4. Joining datasets with `merge`
  * These operations are the building blocks for:
    * going from raw survey data to analysis-ready panels,
    * combining different data sources,
    * and creating the summary datasets used in tables and figures.

---

### 1. Creating variables: `gen` and `egen`

You already know how to use `generate` (`gen`) to make new variables from existing ones. Here we:

  * briefly recap `gen`, and
  * introduce `egen` (**extended generate**), which adds a lot of power.

#### 1.1 Recap: `gen` for simple transformations

`gen` creates a new variable observation-by-observation using an expression.

```stata
* Simple arithmetic transformation
gen ln_wage = ln(wage)
label variable ln_wage "Log of hourly wage"

* Indicator variable (dummy)
gen female = (sex == 2)
label variable female "Respondent is female"

* Conditional creation with missing-value check
gen high_educ = (years_schooling >= 12) if !missing(years_schooling)
label variable high_educ "Completed at least 12 years of schooling"
```

Notes:

  * `gen` can only see **the current observation** and the variables in that row.
  * If you need to update an existing variable, use `replace` instead of `gen`.

```stata
replace ln_wage = . if wage <= 0
```

#### 1.2 `egen`: extended generate

`egen` is like `gen`, but with extra functions that:

  * work across **multiple variables in the same row** (e.g., row means),
  * or across **multiple observations** (e.g., group means, counts, ranks).

General syntax:

```stata
egen newvar = function(arguments) [if] [in] [, options]
```

Some of the most useful `egen` functions:

  * `rowmean()` – mean across variables in the same row
  * `rowtotal()` – sum across variables in the same row
  * `mean()` – group-level mean
  * `sum()` – group-level sum
  * `count()` – number of nonmissing values
  * `tag()` – mark one observation per group

##### Example: row operations

Suppose you have three exam scores:

```stata
describe test1 test2 test3
```

To compute each student’s average test score:

```stata
egen test_mean = rowmean(test1 test2 test3)
label variable test_mean "Average test score (3 exams)"
```

Why use `egen rowmean()` instead of:

```stata
gen test_mean = (test1 + test2 + test3) / 3
```

  * `rowmean()` **ignores missing values** by default (averages over the nonmissing exams).
  * The simple arithmetic version treats missing as missing for the entire expression.

##### Example: group-level statistics with `egen` and `bysort`

Often we want statistics **by group**, but still keep the individual-level data.

Example: mean wage by industry:

```stata
bysort industry: egen ind_mean_wage = mean(wage)
label variable ind_mean_wage "Industry mean wage"
```

After this:

  * each worker’s row now includes the mean wage for their industry,
  * you can compute deviations from the mean, etc.

```stata
gen wage_rel_to_ind = wage - ind_mean_wage
label variable wage_rel_to_ind "Wage minus industry mean"
```

Another useful example: number of observations per group:

```stata
bysort industry: egen n_industry = count(wage)
label variable n_industry "Number of workers in industry"
```

Now each row knows how many workers are in that industry.

##### Example: tagging one observation per group

Sometimes you only want to **see each group once**, e.g., when checking group sizes:

```stata
egen tag_ind = tag(industry)
list industry n_industry if tag_ind
```

  * `tag_ind` is 1 for the **first** observation in each industry and 0 otherwise.
  * This is handy when you want to look at group information without repeating rows.

#### 1.3 When to use `gen` vs `egen`

  * Use **`gen`** when:
    * you are doing simple transformations on a single variable,
    * or combining variables with straightforward arithmetic.
  * Use **`egen`** when:
    * you need row-wise operations across multiple variables,
    * or you need group-level statistics while staying at the individual level.

---

### 2. Aggregating data with `collapse`

`collapse` is used when you want to **replace your dataset with summary statistics**.

  * It takes your current dataset,
  * calculates summary statistics (means, sums, etc.),
  * and **replaces** the data in memory with the aggregated dataset.

This is useful for:

  * going from individual-level data to **household**, **village**, or **region** level,
  * creating datasets of summary statistics for tables or graphs.

#### 2.1 Basic syntax

```stata
collapse (stat1) varlist1 (stat2) varlist2 ..., by(groupvars)
```

  * `stat1`, `stat2`, … might be `mean`, `sum`, `count`, `median`, etc.
  * `by(groupvars)` tells Stata what the new observations will represent.

#### 2.2 Example: going from individuals to regions

Suppose you start with individual-level data:

```stata
list id region wage in 1/6, sepby(region)
```

You want one row per region, with:

  * mean wage in the region,
  * number of individuals in the region.

```stata
collapse (mean) wage (count) id, by(region)
rename id N
label variable wage "Mean wage in region"
label variable N "Number of individuals in region"

list
```

After `collapse`:

  * each row is now **one region**,
  * `wage` is the **mean wage** in that region,
  * `N` is the **number of individuals** you started with in that region.

#### 2.3 Multiple statistics at once

You can compute several statistics at the same time:

```stata
collapse (mean) wage hours (sd) wage, by(region)
```

Now you have:

  * `wage` = mean wage
  * `hours` = mean hours
  * `wage_sd` (Stata will name it `wage_sd`) = standard deviation of wage

#### 2.4 Important: `collapse` overwrites your data

After `collapse`, your original individual-level data are **gone from memory**.

Good habits:

  * Either:
    * run `collapse` in a do-file that starts by reloading the raw data, **or**
    * use `preserve` and `restore`:

```stata
preserve
collapse (mean) wage, by(region)
* Use the collapsed data (e.g., export it, make graphs)
restore
```

  * `preserve` stores the current dataset in memory;
  * `restore` brings it back after you’re done with the aggregated version.

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

---

### 5. Summary: what each command does

  * **`gen`** – create a new variable from an expression, one row at a time.
  * **`egen`** – extended generate; row-wise operations and group-level statistics.
  * **`collapse`** – replace the dataset with summary statistics, often by group.
  * **`append`** – stack datasets vertically (add more rows).
  * **`merge`** – join datasets horizontally (add more columns) based on key variables.

These are the core tools for turning raw data into something you can use for applied economic analysis. In the assignments, you’ll practice:

  * creating new variables with `gen` and `egen`,
  * aggregating with `collapse`,
  * combining multiple files with `append` and `merge`,
  * and checking that the resulting datasets make sense.
