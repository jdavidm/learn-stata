---
layout: page
element: notes
title: Problem Decomposition
language: Stata
---

### Why talk about problem decomposition?

* Up to now we've focused on specific Stata commands: `sum`, `gen`, `merge`, `graph`, etc.
* Real tasks in applied economics rarely look like "run a single command"
    * Clean multiple raw data files
    * Merge them together
    * Construct variables
    * Check that code runs on another computer
    * Produce a table or figure for a paper
* These are multi-step problems. If you try to solve them in one shot, you’ll get stuck and frustrated.
* Problem decomposition is the skill of:
    * Slowing down
    * **Thinking before you code**
    * Breaking a big problem into small, testable steps

![Your problem: Image of an angry hippopotamus. Your problem broken down into pieces: 4 cute pictures of Moo Deng an adorable baby pygmy hippo. Angry hippo image from: https://www.fotocommunity.de/photo/angry-hippo-again-huber-tom/43184827](../moo-deng-problem-decomposition.png)

### Three-step problem decomposition workflow

We’ll use a simple three-step workflow adapted from the Data Carpentry R materials but implemented in Stata:

1. Understand the problem
    1. Restate the problem in your own words
    2. Determine the inputs and outputs
    3. Ask for clarification
2. Break the problem down
    1.  Write down the pieces, on paper or as comments in a file
    2.  Break complicated pieces down until all pieces are small and manageable
3. Code one small piece at a time
    1.  Test it on it's own
    2.  Fix any problems before proceeding

We’ll keep referring back to ideas from *Code Execution* (order matters) and *Check That Your Code Runs* (reproducibility).

### Understand the problem

Before you touch Stata:

1. Restate the problem in your own words
    * If an assignment says:  
        * "Use `eth_allrounds_final.dta` to create a household-level dataset with mean plot yield and total nitrogen use per household."
    * Restate as:
        * "I need to go from *plot-year* data to *household-level* data, with two new variables: average yield per household and total nitrogen used by that household."
2. Determine the inputs and outputs
    * Inputs
        * The starting dataset(s)
        * Variables you’ll need
        * Any assumptions (e.g., one manager per plot)
    * Outputs
        * What dataset should exist at the end?
        * What variables should it have?
        * Do you need a graph or table?
3. Ask for clarification
    * Do we have to follow house style? (Yes!)
    * Are we allowed to modify raw data? (No!)
    * Where should output be saved (which folder/globals)?

> Do [Exercise 1 - Understand the Problem]({{ site.baseurl }}/exercises/07-understand/)

### Break the problem into pieces

Once you understand the goal, **don’t** jump straight into writing complex code. Instead:

1. Write down the pieces
    * On paper
    * In a text editor
    * Or as comments and headings in a `.do` file using house style

For the example, we might start a `.do` file like:

```stata
**********************************************************************
**# 1 - household-level yield and nitrogen
**********************************************************************

* load plot-level data
    use             "$data/eth_allrounds_final.dta", clear

* check structure of data

* create household id

* compute plot-level yield (if needed)

* aggregate to household-level means/totals

* save final household-level file
```

2. Break complicated pieces into smaller steps

Take one bullet and break it down again. For example, “aggregate to household-level means/totals”:

```stata
* aggregate to household level
*   1. make sure household id uniquely identifies households (`isid`)
*   2. collapse plot-level variables to household level (`collapse`)
*   3. label new variables (`var lab`)
```

If any line feels fuzzy (“create household id”, “compute yield”), keep breaking it down until each item is something you could reasonably code in 2–4 lines.

> Do [Exercise 2 - Break the Problem Down]({{ site.baseurl }}/exercises/07-break-down/)

### Code and test one small piece at a time

A common pattern when students get stuck:
* They write **30 lines** of new code
* Run all of it
* Something breaks... and they don’t know where

Instead:
1. Implement one sub-step
2. Run just that part
3. **Check that it did what you expected**
4. Only then move on

#### Example: From plot-level to household-level

Continuing the example, suppose we’ve broken our plan into:

1. Load data
2. Check the structure
3. Construct household id (if needed)
4. Collapse to household-level
5. Label and save

We can code each step and test:

```stata
**********************************************************************
**# 1 - household-level yield and nitrogen
**********************************************************************

* 1. load plot-level data
    use             "$data/eth_allrounds_final.dta", clear

* 2. check structure of data
    describe
    sum             yield_kg nitrogen_kg hh_id
    *** hh_id exists and looks like a household identifier

* 3. verify uniqueness of hh_id
    isid            hh_id
    *** if this fails, we need to think more about the key

* 4. collapse to household level
    collapse        (mean) yield_kg ///
                        (sum)  nitrogen_kg, by(hh_id)

* 5. label variables
    lab var         yield_kg    "Mean plot yield (kg) for household"
    lab var         nitrogen_kg "Total nitrogen (kg) for household"

* 6. save final data set
    save            "$export/eth_household_yield_nitrogen.dta", replace
```

At each step:
* Run just that block (e.g., highlight and Ctrl+D)
* Use `describe`, `sum`, `list`, or `browse` to check that your expectations match what Stata did
* If something is wrong, fix it **before** adding more code

### Start simple and iteratively refine

Once you have the basic pieces:

1. Experiment
    * Try a quick version on a subset of the data: `in 1/100`, or using only one region

2. Write a simpler version
    * Don’t start with all the options and graphs
    * Get the core logic working first

3. Make sure it works
    * Run from the top of the file

4. Make sure you understand it
    * If you can’t explain what each line does in words, you don’t understand it yet

5. Then make it more complicated
    * Add extra variables to `collapse`
    * Add more `by()` groups
    * Beautify the graph
    * Wrap in a loop, etc.

> Do [Exercise 3 - One Piece at a Time]({{ site.baseurl }}/exercises/07-one-piece/)

### Using house style as decomposition scaffolding

Our **house style** is a great tool for problem decomposition:

* Use numbered headings to match big pieces of the problem:
    * `**# 1 - load and clean data`
    * `**# 2 - merge in household data`
    * `**# 3 - construct analysis variables`
    * `**# 4 - produce graphs/tables`
* Use subheadings (`**##`) for sub-parts of each step
* Use comments (`*`) to state the sub-problem above each code block
* Use comments (`***`) to record the outcomes of a code block

Example skeleton for a more complex task:

```stata
**********************************************************************
**# 1 - prepare plot-level data
**********************************************************************

**## 1.1 - load and inspect data

* load plot data
    use             "$data/eth_allrounds_final.dta", clear

* basic checks
    describe
    sum             yield_kg nitrogen_kg
    *** 63,450 observations
    *** mean yield 1,230; sd 4,320
    *** mean fert 10; st 120

**## 1.2 - construct key variables

* create plot id
    gen             plot_id = hh_id + " " + string(plotnum)
    lab var         plot_id "unique plot identifier"
    isid            plot_id
    *** new plot-level unique ID
```

When you’re stuck, often the fastest way forward is:

> Add more structure and comments before adding more Stata commands.

