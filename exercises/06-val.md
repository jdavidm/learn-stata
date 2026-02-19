---
layout: exercise
topic: Loops
title: For Values
language: Stata
---

In this exercise you will use `forvalues` to loop over survey waves and compute
summary statistics.

1. Use `tab` to determine how many survey waves (`wave`) are in the data set. How many waves are in the data set?

2. Use a `forvalues` loop to summarize `yield_kg` separately for each wave.
   Your code should:
   - Loop over all integer values of `wave` observed in the data (for example, `1/3` if there are 3 waves).
   - For each wave:
     - Display a header line like `"Wave 1"`.
     - Run `summarize yield_kg if wave == ...`.

   Example structure (modify the range to match your data):

   ```stata
   forvalues w = 1/3 {
       display "------------------------"
       display "Summary for wave `w'"
       summarize yield_kg if wave == `w'
   }
   ```
   
   What is mean yield in each wave?

3. Extend your loop so that for each wave it also summarizes `nitrogen_kg`. What is mean nitrogren use in each wave?

---
