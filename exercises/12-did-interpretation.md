---
layout: exercise
topic: Difference-in-Differences
title: Interpreting Interactions Effect
language: Stata
---

Let's test if there is a generalized generalized difference in the treatment effect based on a binary policy shock over time using continuous data.

### Tasks

1. Assume that at some point, a national policy supported flood-resistant agriculture (e.g., imagine creating an artificial policy jump: `gen post2015 = year > 2015`).
2. Run an interacted TWFE difference in differences of `evi_med` against `c.seed##i.post2015`.
3. Use `eststo` to store the result, and use `esttab` to print the continuous DiD table alongside your interacted continuous table from the previous exercise.
4. Export the resulting tables to LaTeX using `esttab`. Make sure to use `booktabs` and replace variable labels cleanly.
5. In comments, how does this interaction term differ fundamentally from the 2x2 binary model (`Treat * Post`) shown in the lecture?
