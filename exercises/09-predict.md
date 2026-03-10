---
layout: exercise
topic: Regression
title: Predicting Values
language: Stata
---


Using the **maize only** version of `eth_allrounds_final.dta` with per hectare inputs compute and graph predicted values from a regression.
- Run `reg yield_kg fert labor i.irr i.admin_1`
- Use `predict yhat` to generate predicted values
- Use `summ yield_kg yhat, meanonly` to find the plotting range
- Save the minimum and maximum values for `yhat` **AND** `yield_kg`as locals, for example:

```stata
	qui sum			yhat, meanonly
	local			yhat_min = r(min)
	local			yhat_max = r(max)
```
- Create locals called `gmin` and `gmax` that are the minimum and maximum of `yhat` and `yield_kg`. For example, `gmin = min(`yhat_min', `yield_min')`
- Use `twoway scatter` to create the scatter plot
- Add the 45° reference line with `function y = x` and use the locals in the range option `function y = x, range(``gmin' ``gmax')`
  
---