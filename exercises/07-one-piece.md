---
layout: exercise
topic: Problem Solving
title: One Piece at a Time
language: Stata
---

In this exercise, you will implement only the early steps of the plan you made in exercise 2 and **one small piece at a time** instead of trying to solve everything at once. Again, using the goal problem defined in exercise 1, complete the steps below, running and checking **each block** as you write it.

1\. *Load and inspect the data*. Use `use`, `describe`, and `sum`. After running this block, add a short comment describing what you learned.
2\. *Create per-plot variables*. Create at least one per-plot variable that you expect to use later. A natural example is yield per hectare but you can choose the variable you want to create, as long as it fits into the goal problem and plan you outlined in exercise 2.
3\. *Create a household–season identifier*. Create a combined identifier for `hh_id_merge` and `season` using the `group` function of `egen`.

