---
layout: page
element: exercise
title: Understand the Problem
language: Stata
---

### Overview

In this exercise you will practice the **first step of problem solving**: making sure you actually understand the task before you start coding.

We will use a common goal problem that you will return to in later exercises:

> **Goal problem:**  
> Starting from `plot_dataset.dta` (one row per plot), create a **household–season** dataset with:
> - one observation per `hh_id_merge` and `season`
> - mean plot yield (kg) per household–season
> - total nitrogen (kg) per household–season
> - the number of plots managed by the household in that season
> - an indicator for whether the household had **any irrigated plot** that season

Your job in this exercise is *not* to solve this problem. Your job is to **understand and define** it clearly.

### Instructions

In your assignment `.do` file, create a new section:

```stata
**********************************************************************
**# exercise 1 - understand the problem
**********************************************************************
```

Then complete the following steps, **using comments** to record your answers.

---

#### 1. Restate the problem in your own words

Under the heading for this exercise, write a short paragraph (1–3 sentences) *as comments* that restates the goal problem in your own words. Your restatement should mention:

- what the **starting data** look like (plot-level),
- what the **final data** should look like (household–season level),
- the **key variables** you need to create.

Example structure (but write your own text):

```stata
* in my own words:
* starting from plot-level data with one row per plot,
* i need to build a household-season dataset with mean yield, total nitrogen,
* number of plots, and an indicator for any irrigated plot.
```

---

#### 2. Identify the inputs

Next, think about **what information you need** to solve the problem.

1. Load the data just to inspect its structure:

```stata
    use             "$root/plot_dataset.dta", clear
    describe
```

2. In comments, list the **inputs** you think you need:

   - the dataset(s),
   - the **ID variables**,
   - the **variables needed** to construct mean yield, total nitrogen, number of plots, and irrigated status.

Example (again, use your own words):

```stata
* inputs i need:
* - dataset: plot_dataset.dta
* - ids: hh_id_merge, season, plot_id_merge
* - outcome variables: harvest_kg, nitrogen_kg, plot_area_GPS, irrigated
```

---

#### 3. Identify the outputs

Now describe the **desired output**.

In comments, explain:

- what each **row** of the final dataset represents,
- what **variables** the final dataset should contain,
- whether you expect to save this final dataset, and if so:
  - **file name**, and
  - **location** (e.g., in `$export`).

Example:

```stata
* outputs:
* - one row per hh_id_merge-season
* - variables: hh_id_merge, season, mean_yield_kg, total_nitrogen_kg,
*              n_plots, any_irrigated
* - save as $export/hh_season_yield.dta
```

---

#### 4. Ask clarification questions

Finally, imagine you are about to start writing code but your collaborator is online. What questions would you ask *before* you start?

Add **at least three clarifying questions** as comments. For example:

```stata
* clarification questions:
* 1. should we include all seasons or only main season?
* 2. what should we do with plots that have missing harvest_kg or plot_area_GPS?
* 3. should we drop households with only one plot?
```

### Deliverables

By the end of this exercise, your `.do` file should contain:

- A house-style heading for Exercise 1.
- Commands to load and inspect `plot_dataset.dta`.
- Commented answers that:
  - restate the problem in your own words,
  - list inputs,
  - describe outputs,
  - and pose at least three clarifying questions.
