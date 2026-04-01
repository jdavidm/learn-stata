---
layout: page
element: notes
title: Event Studies
language: Stata
---

Difference-in-Differences (DiD) estimations, particularly under Two-Way Fixed Effects (TWFE), yield a single average treatment effect. However, a single coefficient often obscures the dynamic nature of treatment:
1. Are effects immediate or do they take time to phase in?
2. Are there pre-existing trends leading up to the intervention?

An **Event Study** regression solves both issues by estimating treatment effects relative to the moment of intervention.

This lecture covers:
- The concept of relative time
- Estimating dynamic treatment effects
- Plotting the event study graph using `coefplot`
- Dedicated event study packages

We'll continue using the Castle Doctrine dataset (`castle.dta`), evaluating the effect of the self-defense laws (`post`) on homicides (`l_homicide`).

### Creating Relative Time Variables

In a staggered rollout, different states pass laws in different years. "Year $= 2008$" might be 2 years post-treatment for State A, but 1 year pre-treatment for State B.

We recenter time around the intervention year (`effyear`) to create "event time" or "relative time."

$$ RelativeTime = CalendarTime - TreatmentTime $$

```stata
* load data
	use             "https://github.com/scunning1975/mixtape/raw/master/castle.dta", clear

* create relative time
* for never-treated units, we leave it missing
	gen             rel_time = year - effyear if effyear != .
```

`rel_time` $= 0$ is the year the law passed. `rel_time` $< 0$ are the "leads" (pre-treatment periods). `rel_time` $> 0$ are the "lags" (post-treatment periods).

> Do [Exercise 4 - Event Time Metrics]({{ site.baseurl }}/exercises/12-event-metrics/)

### Estimating Event Study Regressions

To run an event study, we regress our outcome on a full set of dummy variables for each relative time period, controlling for unit and time fixed effects:

$$ Y_{it} = \alpha_i + \gamma_t + \sum_{k=-K}^{-2} \delta_k D_{it}^k + \sum_{k=0}^{L} \delta_k D_{it}^k + \epsilon_{it} $$

Notice we intentionally **omit $k = -1$**, the period just before treatment. This anchors our estimates. All coefficients $\delta_k$ are interpreted as the effect compared to the pre-treatment baseline.

```stata
* bin the far endpoints 
* so we don't have dummies with only 1 state
	gen             rel_time_binned = rel_time
	replace         rel_time_binned = -5 if rel_time <= -5 & rel_time != .
	replace         rel_time_binned =  5 if rel_time >=  5 & rel_time != .

* shift rel_time so it is strictly positive 
* (stata factor variables can't be negative)
	gen             event_factor = rel_time_binned + 10  

* run regression, omitting rel_time = -1 
* (the 'ib9' prefix tells stata to use 9 as the base category)
	xtset           sid year
	xtreg           l_homicide ib9.event_factor i.year if effyear != ., fe vce(cluster sid)
```

The pre-treatment coefficients tests parallel trends. The post-treatment coefficients show the dynamic effect curve.

> Do [Exercise 5 - Replicating Dummies manually]({{ site.baseurl }}/exercises/12-event-dummies/)

### Visualizing with `coefplot`

Regression tables for event studies are massive. Using `coefplot` allows us to visualize the dynamic effects curve.

```stata
* plot with coefplot
	coefplot,       keep(*.event_factor) ///
			        rename(*.event_factor = "") ///
			        vertical ///
			        yline(0, lcolor(black) lpattern(dash)) ///
			        xline(9, lcolor(maroon) lpattern(dash)) ///
			        title("Event Study: Castle Doctrine on Homicides") ///
			        xtitle("Periods Relative to Treatment") ///
			        ytitle("Log Homicide Rate") ///
			        recast(connected) ///
			        ciopts(recast(rcap)) ///
			        graphregion(color(white))
```

*Note: Since we shifted the relative time by +10, you can use the `coeflabels` option in `coefplot` to remap 5 to "-5", 9 to "-1", 10 to "0", etc.*

> Do [Exercise 6 - Event Plot]({{ site.baseurl }}/exercises/12-event-plot/)

### Dedicated Packages

Manually shifting, binning, and relabeling factor variables is tedious. `xtevent` and `eventdd` are prominent packages specifically written for event studies. Using these handles all the data-reshaping for you!

```stata
* install event study packages
*	ssc             install eventdd
*	ssc             install boottest

* run eventdd assuming rel_time is set up without modification
*	eventdd         l_homicide i.year, timevar(rel_time) method(fe, cluster(sid)) ///
			        graph_op(ytitle("Effect on Homicide"))
```

> Do [Exercise 7 - Evaluating Non-Binary Treatments]({{ site.baseurl }}/exercises/12-event-package/)
