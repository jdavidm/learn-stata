---
layout: exercise
topic: Event Studies
title: Using the eventdd Package
language: Stata
---

Manual dummy-shifting and binning works but is inherently repetitive across projects. Advanced dedicated Stata packages such as `eventdd` or `xtevent` abstract the dummy management away!

### Tasks

1. From Stata, install `eventdd` by running `ssc install eventdd, replace`. You might also need `boottest` (`ssc install boottest, replace`). (This is skipped if you're on a secure lab server and cannot download).
2. Assuming you successfully installed `eventdd`: run the command explicitly mapping relative time. 
   ```stata
   eventdd evi_med i.year, timevar(rel_time) method(fe, cluster(district_id)) ///
                           graph_op(ytitle("Effect on EVI (Yield Index)"))
   ```
3. Look at the automatically produced plot! In comments, mention two advantages to using a built-in package over manually estimating the dummies. 
