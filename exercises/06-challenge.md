

4. (Optional challenge) Use a `forvalues` loop over planting months:

   - Use `tab planting_month` to see which months are present.
   - Loop over months 1 to 12.
   - For each month, count how many plots have that planting month and display
     a line like:

     ```text
     Month 3: 452 plots
     ```

   using `count if planting_month == ...` and `r(N)`.
