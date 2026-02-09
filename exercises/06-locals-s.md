---
layout: exercise
topic: Macros
title: Using Locals to Store Results
language: Stata
---


In this exercise you will **capture results** from `summarize` into local
macros and reuse them.

1. Using `eth_allrounds_final.dta`, summarize `yield_kg`:

   ```stata
   summarize yield_kg
   ```

2. Store the mean and standard deviation from this command in locals named
   `mean_yield` and `sd_yield` using `r(mean)` and `r(sd)`:

   ```stata
   local mean_yield = r(mean)
   local sd_yield   = r(sd)
   ```

3. Use these locals to create a **standardized yield** variable:

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
