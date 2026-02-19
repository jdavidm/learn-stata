---
layout: exercise
topic: Loops
title: Challenge 6
language: Stata
---

This challenge builds immediately on the loop you wrote in exercise 8. The goal is to put everything together in something closer to real work. For a list of variables, we will write loops to produce:
- A table of summary statistics  
- A histogram saved to disk for each variable  

The loop you wrote for exercise 8 should look something like:

```stata
* create a local of continuous variables
    local				vars yield_kg harvest_value_USD nitrogen_kg totcons_USD

* loop over each variable and print out the number of observations	
	foreach v of varlist `vars' {
		qui sum 			`v', detail
		local				N = r(N)
		display				`N'
	}

```

**Within** this loop, add a **programming** `if` statement that for variables stricly less than (`<`) 63,450 `displays as text` the following: "Skipping `` `v' `` (only `` `N' `` non-missing obs)". Recall that after a programming `if ...` statement you need `{}` and it is inside these brackets where you put the text you want displayes *if* the statement is true.

Within this `if` loop, us `continue` to to tell Stata to move on to the next variable (this will have the effect of Stata moving onto the next variable without graphing variables with observations `< 63450`).

Outside of the `if` loop, tell Stata what to do when the `if` statement is **not** true. That is, draw a `hist` of the variable `` `v' ``. Label the title `` "Distribution of `v'" `` and x-axis label `` "`v'" ``.  Save the graph with a name that depends on the variable, e.g. `hist_yield_kg.png`.

In the end, you should have one loop inside another. The outside loop is the `foreach` loop above. The inside loop is the one that follows `if ...`. The code for the `hist` goes inside the first loop but **not** inside the second. That second loop tells Stata what to do when the `if` statement is true. If the statement is **not** true, than Stata will automatically draw the `hist`