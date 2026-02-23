---
layout: page
element: exercise
title: One Piece at a Time
language: Stata
---

### Overview

In this exercise you will practice the **third step of problem solving**: implementing and checking **one small piece at a time** instead of trying to solve everything at once.

You will begin coding part of your plan for the same goal problem:

> **Goal problem:**  
> Starting from `plot_dataset.dta` (one row per plot), create a **household–season** dataset with:
> - one observation per `hh_id_merge` and `season`
> - mean plot yield (kg) per household–season
> - total nitrogen (kg) per household–season
> - the number of plots managed by the household in that season
> - an indicator for whether the household had **any irrigated plot** that season

In this exercise, you will implement only the **early steps** of your plan and check each step as you go.

### Instructions

In your assignment `.do` file, create a new section:

```stata
**********************************************************************
**# exercise 3 - one piece at a time
**********************************************************************
```

Then complete the steps below, running and checking **each block** as you write it.

---

#### 1. Load and inspect the data

```stata
**## 3.1 - load and inspect data

* load plot-level data
    use             "$root/plot_dataset.dta", clear

* basic structure check
    describe
    sum             harvest_kg nitrogen_kg plot_area_GPS hh_id_merge season
```

After running this block, add a short comment describing what you learned:

```stata
*** harvest_kg and plot_area_GPS are non-missing for most observations; hh_id_merge and season exist
```

---

#### 2. Create per-plot variables

Create at least one per-plot variable that you expect to use later. A natural example is yield per hectare:

```stata
**## 3.2 - create per-plot variables

* create yield per hectare
    gen             yield_ha = harvest_kg / plot_area_GPS

* quick check
    sum             yield_ha
    *** record here what you see about mean, min, and max yield_ha
```

If needed, you can also add checks for missing or zero `plot_area_GPS`:

```stata
    count           if plot_area_GPS == 0 | plot_area_GPS == .
    *** how many plots have zero or missing area?
```

---

#### 3. Create a household–season identifier

Create a combined identifier for `hh_id_merge` and `season`:

```stata
**## 3.3 - create household-season id

* create combined id
    egen            hh_season_id = group(hh_id_merge season)
    lab var         hh_season_id "household-season identifier"

* spot check
    list            hh_id_merge season hh_season_id in 1/10
    *** confirm that hh_season_id is constant within each hh_id_merge-season combination
```

---

#### 4. Optional: start thinking ahead

If you have time, you may (optionally) sketch how you would collapse to household–season level in comments (you will do more of this later in the course). For example:

```stata
* later we will:
* - collapse mean yield_ha and sum nitrogen_kg by hh_id_merge season
* - create a count of plots and an irrigated indicator
```

### Deliverables

By the end of this exercise, your `.do` file should contain:

- A house-style heading for Exercise 3.
- Working code that:
  - loads and inspects `plot_dataset.dta`,
  - creates at least one per-plot variable (e.g., `yield_ha`),
  - creates a `hh_season_id` variable.
- At least **two `***` comments** reporting what you saw from your checks (`sum`, `list`, `count`, etc.).
