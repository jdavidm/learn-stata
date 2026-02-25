---
layout: exercise
topic: Problem Solving
title: Stata Help
language: Stata
---

### Overview

In this exercise you will practice using **Stata’s built-in help and documentation** to solve a concrete coding problem.

**Goal:** Using `plot_dataset.dta`, create a graph of **mean yield per hectare by main crop**, with bars sorted from lowest to highest mean yield.

You are expected to use `help` or `search` inside Stata to figure out the exact syntax and options.

### Instructions

In your assignment `.do` file, create a new section:

```stata
**********************************************************************
**# exercise 5 - stata help
**********************************************************************
```

Then complete the steps below.

---

### Step 1 – Document your help search

At the top of this section, add comments describing how you used Stata’s help:

```stata
* stata help used:
* - command(s): e.g., help graph bar
* - what you were looking for: e.g., how to sort bars by mean value
* - at least one option or example you learned from the help file
```

When you actually run `help` or `search` in Stata, you do **not** need to record the entire output; just summarize what you learned.

---

### Step 2 – Load the data and create yield per hectare

```stata
* load data
    use             "$root/plot_dataset.dta", clear

* create yield per hectare (if not already created)
    gen             yield_ha = harvest_kg / plot_area_GPS
```

You may want to add a quick check:

```stata
    sum             yield_ha
    *** brief comment on mean/min/max yield_ha
```

---

### Step 3 – Use help to design the graph

Use `help graph bar` (or another relevant help file) to answer questions like:

- How do I compute **mean** of a variable in a `graph bar` command?
- How do I put different groups on the x-axis?
- How can I **sort** the bars by the mean value?
- How can I add axis titles and an overall title?

Record key options you decide to use in comments. For example:

```stata
* from help graph bar i learned:
* - (mean) varlist syntax to plot means
* - over(main_crop, sort(1)) to sort bars by the first statistic
```

---

### Step 4 – Produce the graph

Use the information from the help file to write a `graph bar` command that:

1. Plots **mean `yield_ha`**.
2. Groups bars by `main_crop`.
3. Sorts bars from lowest to highest mean yield.
4. Has informative axis labels and title.

For example, your final command may look structurally like:

```stata
* mean yield per hectare by main crop
    graph bar       (mean) yield_ha, over(main_crop, sort(1)) ///
                        ytitle("Mean yield (kg/ha)") ///
                        xtitle("Main crop") ///
                        title("Mean yield per hectare by crop")
```

(The exact options are up to you, as long as they work and are informed by the help file.)

---

### Deliverables

By the end of this exercise, your `.do` file should contain:

- A house-style heading for Exercise 5.
- Comments describing how you used Stata’s built-in help (`help` or `search`).
- Working code that:
  - loads `plot_dataset.dta`,
  - creates `yield_ha`,
  - and produces a bar graph of mean `yield_ha` by `main_crop`, sorted by mean.
