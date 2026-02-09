---
layout: exercise
topic: Loops
title: For Values
language: Stata
---


In this exercise you will use `forvalues` to loop over survey waves and compute
summary statistics.

1. Tabulate the `wave` variable to see how many survey waves you have and what
   their codes are:

   ```stata
   tab wave
   ```

2. Use a `forvalues` loop to summarize `yield_kg` separately for each wave.
   Your code should:

   - Loop over all integer values of `wave` observed in the data (for example,
     `1/3` if there are 3 waves).
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

3. Extend your loop so that for each wave it also summarizes `nitrogen_kg`:

   ```stata
   forvalues w = 1/3 {
       display "------------------------"
       display "Summary for wave `w'"
       summarize yield_kg    if wave == `w'
       summarize nitrogen_kg if wave == `w'
   }
   ```

4. (Optional challenge) Use a `forvalues` loop over planting months:

   - Use `tab planting_month` to see which months are present.
   - Loop over months 1 to 12.
   - For each month, count how many plots have that planting month and display
     a line like:

     ```text
     Month 3: 452 plots
     ```

   using `count if planting_month == ...` and `r(N)`.


---
