---
layout: exercise
topic: Problem Solving
title: Understand the Problem
language: Stata
---

For the first three exercises this week we will use a common goal problem:

> **Goal problem:**  Starting from `plot_dataset.dta` (one row per plot), create a household dataset with:
> - one observation per `hh_id_merge`
> - mean plot yield (kg/ha) per household
> - total nitrogen (kg) per household
> - total labor (days) per household
> - the number of plots managed by the household in that season
> - an indicator for whether the household had any irrigated plot that season

Your job in this exercise is *not* to solve this problem. Your job is to **understand and define** it clearly. Complete the following steps, **using comments** to record your answers.

1\. Restate the problem in your own words. Under the heading for this exercise, write a short paragraph (1–3 sentences) as comments that restates the goal problem in your own words. Your restatement should mention:
  - What the starting data look like (plot-level)
  - What the final data should look like (household–level)
  - The key variables you need to create

 2\. Identify the inputs. Next, think about what information you need to solve the problem.
  - Load the data just to inspect its structure
  - In comments, list the inputs you think you need

3\. Identify the desired outputs. In comments, explain:
  - what each row of the final dataset represents,
  - what variables the final dataset should contain,
  - whether you expect to save this final dataset, and if so:
    - file name, and
    - location (e.g., in `$export`).

4\. Ask clarification questions. Finally, imagine you are about to start writing code but your collaborator is online. What questions would you ask before you start? Add at least three clarifying questions as comments.

---