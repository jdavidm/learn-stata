---
layout: exercise
topic: Data Analysis
title: Check That Your Code Runs
language: Stata
---

Sometimes you think you're code runs, but it only actually works because of something else you did previously. To make sure it actually runs you should save your work and then run it in a clean environment.

Follow these steps in to make sure your code really runs:

1. Restart Stata by closing the instance of Stata that you have open.

2. When you reopen Stata, type in the command line `clear all`. Or, better yet, put `clear all` at the top of your `.do` file, after the preamble but before any commands.

3. Rerun your entire homework assignment by clicking the `Execute` button to make sure it runs from start to finish and produces the expected results.

4. Make sure that you saved your code with the name of the assignment number (i.e., `assignment_01`). You should see the file in your git repo on your machine.

5. Make sure that your code will run on other computers (relevant for all assignments after the first assignment)
  - No `cd`. Use a `project.do` file instead to set directories
  - Use only relative paths in files other than the `project.do` file
  - Use `/` not `\` for paths

---