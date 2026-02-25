---
layout: exercise
topic: Problem Solving
title: Online Help
language: Stata
---

### Overview

In this exercise you will practice using **online resources** (Stata documentation, Statalist, Stack Overflow, etc.) to solve a coding problem and adapt example code safely.

**Goal:** Using `plot_dataset.dta`, create a summary dataset with one row per **agro-ecological zone** (`agro_ecological_zone`) containing the **mean and standard deviation of yield per hectare**.

You should use an online resource to remind yourself how to compute **multiple statistics by group** and then adapt that example to this dataset.

### Instructions

In your assignment `.do` file, create a new section:

```stata
**********************************************************************
**# exercise 6 - online help
**********************************************************************
```

Then complete the steps below.

---

### Step 1 – Search online and document what you used

Open a web browser and search for something like:

- `stata collapse mean sd by group`, or
- `stata multiple statistics by group`, or a similar query.

Find at least one online resource (e.g., Stata manual, Statalist post, Stack Overflow answer) that shows how to compute **mean and standard deviation by group** using commands like `collapse`, `tabstat`, or similar.

In your `.do` file, add comments summarizing your search:

```stata
* online search:
* - search terms:
* - website or post used (e.g., Stata docs, Statalist, Stack Overflow):
* - one specific syntax detail learned (e.g., collapse (mean) x (sd) x, by(group))
```

You do **not** need to paste links; the site name and what you learned is enough.

---

### Step 2 – Load the data and create yield per hectare

```stata
* load data
    use             "$root/plot_dataset.dta", clear

* create yield per hectare
    gen             yield_ha = harvest_kg / plot_area_GPS

* quick check of agro_ecological_zone
    tab             agro_ecological_zone
    *** brief comment about how many zones there are
```

---

### Step 3 – Compute mean and SD by agro-ecological zone

Using what you learned online, compute the **mean** and **standard deviation** of `yield_ha` by `agro_ecological_zone` and store them in a dataset with one row per zone.

A natural approach uses `collapse`:

```stata
* collapse to zone-level summary
    collapse        (mean) mean_yield_ha = yield_ha ///
                    (sd)   sd_yield_ha   = yield_ha, ///
                        by(agro_ecological_zone)

    lab var         mean_yield_ha   "Mean yield (kg/ha) by agro-ecological zone"
    lab var         sd_yield_ha     "SD yield (kg/ha) by agro-ecological zone"
```

You may choose a different command if you prefer, as long as the final dataset has:

- one row per `agro_ecological_zone`, and
- variables for the mean and SD of `yield_ha`.

---

### Step 4 – Save the summary dataset

Save the resulting dataset in your assignments answers folder with a clear name:

```stata
* save summary dataset
    save            "$export/zone_yield_summary.dta", replace
```

Add a short comment explaining how this file could be used later:

```stata
*** this file can be merged back to household or plot data or used for maps/plots
```

---

### Step 5 – Explain how you adapted the online example

At the end of this exercise section, add a short comment block explaining:

```stata
* adaptation notes:
* - what the original online example was doing
* - what you changed (variable names, by-groups, file paths, etc.)
* - anything from the example that you chose NOT to copy (and why)
```

### Deliverables

By the end of this exercise, your `.do` file should contain:

- A house-style heading for Exercise 6.
- Comments documenting your online search and what you learned.
- Working code that:
  - loads `plot_dataset.dta`,
  - creates `yield_ha`,
  - computes mean and SD of `yield_ha` by `agro_ecological_zone`,
  - and saves a zone-level summary dataset.
- A brief explanation of how you adapted online code to your own context.
