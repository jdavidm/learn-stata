---
layout: exercise
topic: Problem Solving
title: Debugging
language: Stata
---

In this exercise you will practice **systematic debugging** using a deliberately broken `.do` file that works with `plot_dataset.dta`.

Your goals are to:

1. Make the bug **reproducible** from a clean session.
2. Fix **one bug at a time**, always reading the error message.
3. Use Stata’s tools (`describe`, `sum`, `list`, `help r(###)`, etc.) to understand what’s going on.
4. End with a **clean, working script** and a short reflection.

### Step 1 – Set up a reproducible error

At the top of your assignment `.do` file (or at the top of this exercise), make sure you can reproduce errors from a clean session:

```stata
**********************************************************************
**# 0 - setup for debugging
**********************************************************************

    clear all
    project        , do("project.do")   // or run your project do file directly

**********************************************************************
**# exercise 4 - debugging
**********************************************************************
```

You should be able to run your `.do` file from the top and have Stata stop when it hits the first error in this exercise.

---

### Step 2 – Copy in the broken code

Copy the following **broken** code block directly under the Exercise 4 heading:

```stata
**********************************************************************
**# 1 - plot-level yield summaries
**********************************************************************

* load data
    use             "$root/plot_dataset", clear

* create yield per hectare
    gen             yield_ha = harvestkg / plot_area_GPS

* summarize average yield for irrigated plots only, by main crop
    bys             main_crop: sum yield_ha if irrigated = 1, details

**********************************************************************
**# 2 - save irrigated-only data by season
**********************************************************************

* get list of seasons
    levelsof        season, local(seasons)

* loop over seasons and save a file for each
    foreach s of local seasons {

    * keep only irrigated plots for this season
        keep        if season == s & irrigated == 1

    * save season-specific file
        save        "$export/plot_yield_irr_s.dta"

    * reload data for next loop iteration
        use         "$root/plot_dataset.dta", clear
    }

* close log
    log             close
```

Do **not** fix anything yet. Run your `.do` file from the top and let Stata stop at the first error.

---

### Step 3 – Fix one bug at a time

There are **multiple bugs** in this code (file names, variable names, `=` vs `==`, loop logic, options, and more).

For each bug you encounter:

1. Run your `.do` file from the top until Stata stops with an error.
2. **Copy the error message and code** in a comment **above the offending line** using the pattern:

```stata
*** ERROR HERE: r(111) type mismatch; harvestkg does not exist
```

3. Immediately below that comment, **fix the bug**.

Example pattern:

```stata
*** ERROR HERE: r(111) variable harvestkg not found; should be harvest_kg
    gen             yield_ha = harvest_kg / plot_area_GPS
```

4. Run the file from the top again to see the **next** error.
5. Repeat this process until the entire script runs without errors.

You should end up with a series of `*** ERROR HERE:` comments documenting each bug you found and how you fixed it.

---

### Step 4 – Use Stata’s debugging tools

As you debug, use at least **three** of the following tools at appropriate points:

- `describe`
- `sum` or `sum, detail`
- `list` or `browse`
- `tab`
- `help r(###)` for one of the error codes you encounter
- `display` of a macro (e.g., `display "`s'"`) or returned result (e.g., `display r(mean)`)

Each time you use one of these tools, add a short `***` comment summarizing what you learned. For example:

```stata
    describe        harvest_kg plot_area_GPS irrigated main_crop
    *** confirms that harvest_kg exists and harvestkg does not

    tab             season
    *** seasons are coded 1, 2, 3
```

---

### Step 5 – Final cleaned code and reflection

After you have fixed all the bugs and the code runs cleanly:

1. Keep the **cleaned, working version** of the code in your Exercise 4 section.
2. At the very end of this section, add a short reflection as comments answering:

```stata
* reflection:
* - which bug was hardest to find? why?
* - which debugging tool or habit was most helpful (reading error messages,
*   describe/sum/list, help r(###), or something else)?
```