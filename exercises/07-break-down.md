---
layout: page
element: exercise
title: Break the Problem Down
language: Stata
---

### Overview

In this exercise you will practice the **second step of problem solving**: breaking a big task into smaller pieces and sub-pieces before you start coding.

You will continue working with the the same goal problem:

> **Goal problem:**  
> Starting from `plot_dataset.dta` (one row per plot), create a **household–season** dataset with:
> - one observation per `hh_id_merge` and `season`
> - mean plot yield (kg) per household–season
> - total nitrogen (kg) per household–season
> - the number of plots managed by the household in that season
> - an indicator for whether the household had **any irrigated plot** that season

Your job in this exercise is to build a **structured plan** using house-style headings and comments.

### Instructions

In your assignment `.do` file, create a new section:

```stata
**********************************************************************
**# exercise 2 - break the problem down
**********************************************************************
```

Then complete the steps below. You do **not** need to write any new Stata commands beyond headings and comments.

---

#### 1. Create high-level headings

Using the house style, create a set of **major sections** that could solve the goal problem.

Example structure (adapt / extend as needed):

```stata
**********************************************************************
**# 1 - prepare plot-level data
**********************************************************************

**## 1.1 - load and inspect data

**## 1.2 - check keys and ids

**********************************************************************
**# 2 - construct household-season variables
**********************************************************************

**## 2.1 - create household-season id

**## 2.2 - create per-plot variables (e.g., yield per hectare)

**********************************************************************
**# 3 - collapse to household-season level
**********************************************************************

**## 3.1 - aggregate yield and nitrogen

**## 3.2 - count plots and irrigated indicator

**********************************************************************
**# 4 - label and save output
**********************************************************************
```

You may change the wording or numbering, but the headings should:

- cover the full workflow from raw data to final dataset, and
- follow house style (`**#` for headings, `**##` for subheadings).

---

#### 2. Add “mini-steps” under one heading

Pick **one** of your big sections (for example, “collapse to household-season level”) and break it down into smaller steps using comments.

Example:

```stata
**## 3.1 - aggregate yield and nitrogen

* steps:
* 1. check that hh_id_merge and season uniquely identify households within a season
* 2. collapse mean yield_kg and sum nitrogen_kg to hh_id_merge-season level
* 3. create a count of plots per household-season
* 4. label the new variables
```

You should end up with a short bullet-style list of **2–5 sub-steps** that you could realistically implement with 1–4 Stata commands each.

---

#### 3. Keep this as a plan

For this exercise you are building a **plan**, not writing full code. Do **not** implement the commands yet. You will start coding in Exercise 3.

### Deliverables

By the end of this exercise, your `.do` file should contain:

- A house-style heading for Exercise 2.
- A set of major headings and subheadings that outline the solution.
- At least one subheading with a commented list of mini-steps that break that part of the problem into smaller pieces.
