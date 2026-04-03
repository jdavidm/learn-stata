---
layout: exercise
topic: Event Studies
title: Using the eventdd Package
language: Stata
---

Manual dummy-shifting and binning works but is inherently repetitive across projects. Dedicated Stata packages such as `eventdd` abstract the dummy management away.

- Add `eventdd` and `boottest` to the package loop in your `project.do` file. Change `$pack` to 1 and re-run `project.do`. Then change `$pack` back to 0. (Skip this step if you're on a secure lab server and cannot download packages.)
- Assuming you successfully installed `eventdd`: run the command using the `rel_time` variable you created in Exercise 4.
   ```stata
   eventdd evi_med c.bin_max_60_611 i.year, timevar(rel_time) ///
                           method(fe, cluster(district_id)) ///
                           graph_op(ytitle("Effect on EVI (Yield Index)"))
   ```

1. Look at the automatically produced plot. What are two advantages of using a built-in package over manually estimating the dummies?
2. How does the `eventdd` plot compare to the `coefplot` you produced in Exercise 5?
