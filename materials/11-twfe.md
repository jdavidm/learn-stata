---
layout: page
element: notes
title: Two-Way Fixed Effects
language: Stata
---

While One-Way Fixed Effects absorb unobserved, time-invariant heterogeneity across individuals, **Two-Way Fixed Effects (TWFE)** go a step further. We add time fixed effects to absorb any unobserved macroeconomic shocks or trends that affect all individuals in a given time period identically.

The classic TWFE model is

$$
    Y_{it} = \beta D_{it} + \alpha_i + \gamma_t + \epsilon_{it},
$$

where $\alpha_i$ are individual fixed effects and $\gamma_t$ are time fixed effects. For a long time, TWFE was the undisputed gold standard for analyzing panel data. You simply included `i.wave` in your `xtreg`:

```stata
* estimate TWFE using xtreg and i.wave
	xtreg           yield_kg fert i.wave, fe vce(cluster hh_id_obs)
```

Recent years have seen new commands for estimating 2+ levels of fixed effects as well as a growing recognitition that TWFE estimates can be wrong under certain, commonly occuring circumstances. We will return to this issue later in this section.

### The `reghdfe` Command

When you have two or more levels of fixed effects, `xtreg, fe` becomes less efficient because it only "demeans" out the panel identifier, while explicitly estimating a dummy variable coefficient for every single time period (`i.wave`) or whatever your other FE is. If your dataset is very large, has many time periods, or has many additional levels of data that you want to control for (e.g., state of residence), this can quickly hit Stata's matrix limits or slow down computation.

The modern solution is the user-written `reghdfe` command (Correia, 2016). It efficiently absorbs multiple high-dimensional fixed effects without estimating thousands of dummy parameters, and it correctly adjusts the degrees of freedom and standard errors.

Install `reghdfe` by adding it to the package loop in your `project.do` file. The `reghdfe` command also requires that you install `require` package, so do that by also adding `require` to the package loop in your `project.do` file. Then use the `absorb()` option to specify which dimensions to absorb:

```stata
* estimate the identical TWFE model using reghdfe
	reghdfe         yield_kg fert, absorb(hh_id_obs wave) vce(cluster hh_id_obs)
```

`reghdfe` produces the same point estimates as `xtreg, fe` with `i.wave`, but with correctly adjusted standard errors. It also scales easily to models with two or more high-dimensional fixed effects (e.g., hundreds of thousands of firms *and* hundreds of thousands of workers).

> Do [Exercise 5 - Adding Time Fixed Effects]({{ site.baseurl }}/exercises/11-twfe/)

### The Staggered Treatment Problem

In recent years, econometricians (such as Goodman-Bacon, 2021) discovered a major flaw in the standard TWFE estimator when evaluating treatments that are adopted at *different times* (staggered adoption) and where the treatment effect *changes over time* (dynamic effects).

Let's illustrate this with simulated data. First, we'll simulate a clean setup where everyone who gets treated gets it at the exact same time (non-staggered):

```stata
* simulate non-staggered treatment data
	clear
	set             obs 1000
	gen             id = _n
	expand          10
	bysort id:      gen t = _n
	
	* true effect = exactly 5
	* non-staggered: 50% treated starting at t=5
	gen             treated_nonstag = (t >= 5) & (id > 500)
	gen             y_nonstag = 5 * treated_nonstag + id + t + rnormal()
	
	xtset           id t
	xtreg           y_nonstag treated_nonstag i.t, fe
```

If you run this, `xtreg` recovers a coefficient very close to 5. 

But what if treatments are staggered? Let's assign individuals different treatment years. Furthermore, let's assume the effect of the treatment takes time to ramp up:

```stata
* simulate staggered adoption with dynamic effects
	bysort id:      gen treat_time = runiformint(3, 11) if _n == 1
	bysort id:      replace treat_time = treat_time[1]
	replace         treat_time = 0 if treat_time > 9
	gen             treated_stag = (t >= treat_time) & (treat_time > 0)
	
* dynamic effect: baseline effect of 5, grows by 2 each year
	gen             true_effect = 5 + 2 * (t - treat_time)
	gen             y_stag = true_effect * treated_stag + id + t + rnormal()
	
	xtreg           y_stag treated_stag i.t, fe
```

In our simulation, the true treatment effect is 9.8 but if you run the naive TWFE you will notice the estimate is often wildly wrong—sometimes even negative! Based on our simulation, `xtreg` gives us an estimate of 6.14. Why the downward bias? Because standard TWFE calculates a weighted average of all possible 2x2 Difference-in-Difference combinations. When adoption is staggered, TWFE uses **already-treated units as controls** for newly-treated units. Because the treatment effect for the "already-treated" is growing over time, this creates negative weights, severely biasing your estimate.

> Do [Exercise 6 - Simulating the Bias]({{ site.baseurl }}/exercises/11-bias/)

### Decomposing the Bias

Goodman-Bacon (2021) proved that TWFE is a weighted average of comparisons. We can use a user-written Stata package `bacondecomp` to see exactly how much weight is being placed on bad comparisons (Later vs. Earlier Treated).

Install the `bacondecomp` package by adding it to our list of packages in `project.do`. Then switch the value of `pack` to 1 and re-run the `project.do` file. Finally, switch the value of `pack` back to zero and save the `project.do` file.

The `bacondecomp` command produces a scatterplot showing the different 2x2 DiD comparisons and their weights. 

```stata
* decompose the TWFE estimate
	bacondecomp     y_stag treated_stag, ddetail
```

Look at the resulting graph. You will see two distinct groups of comparisons:
1. **Solid triangles**: These are the "good" comparisons (e.g., comparing newly-treated units to never-treated units). These 2x2 estimates are large and positive (ranging from 5 to 10), which accurately reflects our true growing treatment effect.
2. **Hollow circles**: These are the problematic comparisons where already-treated units act as controls for newly-treated units. Because the treatment effect for the "controls" is growing, these difference-in-difference estimates are severely biased downward, with many close to zero or even negative.

The dotted horizontal line shows the overall TWFE estimate (around 3.9). The TWFE estimate is simply a weighted average of all these points. Because the problematic hollow circles receive substantial weight, they drag the overall TWFE estimate down far below the true treatment effect.

### Modern Solutions (e.g., `csdid`)

To fix this, econometricians have developed new estimators (Callaway & Sant'Anna, 2021; Sun & Abraham, 2021; Borusyak et al., 2021). These "modern TWFE" estimators explicitly avoid using already-treated units as controls. Instead, they only compare newly-treated units to "not-yet-treated" or "never-treated" units.

One of the most popular packages is `csdid` (Callaway & Sant'Anna). Unlike `bacondecomp`, `csdid` is not on the `ssc` repository. Rather, we need to install it from the creator's github repo. In the package loop that is already in your `project.do`, you should have the following line:

```stata
	* install -xfill and dm89_1 - packages
		net install xfill, from(https://www.sealedenvelope.com/) replace
```

If not, add it before the final `}` bracket in the package loop. On the line immediately following the command to install `xfill` add this line:

```stata
* install csdid
	net             install csdid, from("https://raw.githubusercontent.com/friosavila/csdid_drdid/main/code/") replace
```

Rerun `project.do` and save it (you may also need to install `drdid`). Now that we have `csdid`, the package requires a variable indicating the *first period* an individual was treated (the cohort variable). We already created `treat_time` for our simulation, where never-treated units are correctly set to 0.

```stata
* run csdid
	csdid           y_stag, time(t) ivar(id) gvar(treat_time)

* calculate the true att
	estat           simple
```
`csdid` first calculates all the pair-wise difference-in-differences. The `estat simple` command then calculates the average treatment effect for the entire treated group, which it estimates as 9.96, much closer to the true value of 9.8.

> Do [Exercise 7 - Modern TWFE Solutions]({{ site.baseurl }}/exercises/11-bacon/)
