---
layout: exercise
topic: Macros
title: Using Locals to Store Results
language: Stata
---

Using `eth_allrounds_final.dta`,

1. Summarize `yield_kg` and store the mean and standard deviation from this command in locals named
   `mean_yield` and `sd_yield` using `r(mean)` and `r(sd)`. Use these locals to create a standardized yield variable called `yield_kg_std`. Recall from your stats classes, to standardize a variable you subtract the mean value from the variable and then divide the results by the standard deviation. What is

   ```stata
   gen yield_kg_std = (yield_kg - `mean_yield') / `sd_yield'
   ```

4. Check that the standardized variable behaves as expected by summarizing it:

   ```stata
   summarize yield_kg_std
   ```

   - Does the mean look close to 0?
   - Does the standard deviation look close to 1?

5. Use a `display` command and your locals to print a short, readable sentence
   to the Results window. For example (modify the text as you like):

   ```stata
   display "Mean yield on Ethiopian plots is `mean_yield' kg with sd `sd_yield' kg."
   ```

---
