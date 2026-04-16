---
layout: exercise
topic: LaTeX
title: Summary Statistics Table
language: Stata
---

Using `tenuredata.dta` (rice observations only), produce a summary statistics table.
- First, run `estimates clear` to clear any previously stored estimates.
- Use `estpost sum` to compute summary statistics for: `yield`, `q_f_ha`, `lt_f_ha`, `area`, `irrig`, `tenure`.
- Display the table with:

   ```stata
   esttab,     cells("count mean sd min max") ///
                   noobs nonumber nomtitle ///
                   title("Summary Statistics — Rice Parcels") ///
                   label
   ```

---
