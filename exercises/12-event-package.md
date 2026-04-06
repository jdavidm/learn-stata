---
layout: exercise
topic: Event Studies
title: Using the `eventdd` Package
language: Stata
---

Manual dummy-shifting and binning works but is inherently repetitive across projects. Dedicated Stata packages such as `eventdd` abstract the dummy management away.

- Run the `eventdd` command using the `ry` variable you created in Exercise 4.
- Include `c.bin_max_60_611 i.year` as the independent variables.
- Use the `method()` option to control for unit and time fixed effects and cluster standard errors by `district_id`.
- Use the `graph_op()` option to set the y-axis title.
- Upload the resulting plot to your Overleaf document.
---
