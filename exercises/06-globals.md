---
layout: exercise
topic: Macros
title: Using Globals
language: Stata
---


In this exercise you will practice using a **global macro** to store a cutoff
that is reused in several commands. Remember: in this course, locals are
preferred almost always; this exercise is to help you understand how globals
work and why they can be risky.

1. Define a global macro named `largeplot_cutoff` that stores the size (in
   hectares) above which you will consider a plot “large”. Use 1 hectare as the
   cutoff:

   ```stata
   global largeplot_cutoff = 1
   ```

2. Create a new indicator variable `large_plot` that equals 1 if
   `plot_area_GPS` is **strictly greater** than `$largeplot_cutoff` and 0
   otherwise.

   ```stata
   gen large_plot = plot_area_GPS > $largeplot_cutoff
   label var large_plot "1 if plot area > $largeplot_cutoff ha"
   ```

3. Compare yields on large vs smaller plots:

   - Use `tabstat` or `summarize` with `if` to compute the mean `yield_kg` for
     `large_plot == 1` and for `large_plot == 0`.

4. Now **change the definition** of the global cutoff to 0.5 hectares:

   ```stata
   global largeplot_cutoff = 0.5
   ```

   Recreate the variable `large_plot` (you can `drop large_plot` first) using
   the new cutoff, and recompute the mean yields for large vs non-large plots.

5. In a comment in your do-file, briefly note:

   - What changed when you changed the global macro?
   - Why could using many globals like this make debugging harder in a large
     project?

---
