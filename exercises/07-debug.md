---
layout: exercise
topic: Problem Solving
title: Debugging
language: Stata
---

In this exercise you will practice **systematic debugging** using a deliberately broken `.do` file that works with `plot_dataset.dta`. Your goals are to:
- Make the bug reproducible from a clean session.
- Fix one bug at a time, always reading the error message.
- Use Stata’s tools (`describe`, `sum`, `list`, `help r(###)`, etc.) to understand what’s going on.
- End with a clean, working script and a short reflection.

At the top of this exercise make sure you can reproduce errors from a clean session. To do this, use `clear all` and then `do` to run the `projectdo` file from this script. Then copy the following **broken** code block directly after the line where you run the `projectdo` file.

```stata
******************************************************************
**# 1 - plot-level yield summaries
******************************************************************

* load data
    use             "$root/plot_dataset", clear

* create yield per hectare
    gen             yield_ha = harvestkg / plot_area_GPS

* summarize average yield for irrigated plots only, by main crop
    bys             main_crop: sum yield_ha if irrigated = 1, details

******************************************************************
**# 2 - save irrigated-only data by season
******************************************************************

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

There are multiple bugs in this code (file names, variable names, `=` vs `==`, loop logic, options, and more). Do **not** fix anything yet. Run your `.do` file from the top and let Stata stop at the first error. 

For each bug you encounter:
- Run your `.do` file from the top until Stata stops with an error.
- Copy the error message and code in a comment below the offending line using the pattern:

```stata
        *** ERROR HERE: r(111) type mismatch; harvestkg does not exist
```

Comment out the broken code and immediately below that `***` comment decribing the error **fix the bug**. Then run the file from the top again to see the **next** error. Repeat this process until the entire script runs without errors. You should end up with a series of `*** ERROR HERE:` comments documenting each bug you found followed by your debugged code.

As you debug, remember to use Stata's tools at appropriate points (do not use online help or an LLM).
- `describe`
- `sum` or `sum, detail`
- `list` or `browse`
- `tab`
- `help r(###)` for one of the error codes you encounter
- `display` of a macro (e.g., `display "`s'"`) or returned result (e.g., `display r(mean)`)

Each time you use one of these tools, add a short `***` comment summarizing what you learned.

When you have completed this exercise you should have all the broken code commented out, followed by your comments regarding what the problem/bug was, and then a cleaned, working version of the buggy code block.

---