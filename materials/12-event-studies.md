---
layout: page
element: notes
title: Event Studies
language: Stata
---

In the previous lecture we estimated a single Difference-in-Differences coefficient using Two-Way Fixed Effects (TWFE). That coefficient told us the *average* effect of the Castle Doctrine on homicides — but a single number hides a lot:

1. Were treatment and control groups trending similarly *before* the law passed?
2. Did the effect kick in immediately, or build over time?

An **event study** regression answers both questions by estimating a separate treatment effect for every period relative to the intervention. The result is a *dynamic treatment effects curve* rather than a single point estimate.

This lecture covers:
- Building lead and lag dummies to estimate an event study
- Interpreting pre-treatment leads as evidence for parallel trends
- Visualizing the event study with `coefplot`
- The Bacon decomposition: understanding what TWFE actually estimates under staggered adoption

We continue using the Castle Doctrine dataset (`castle.dta`). Our outcome is the log homicide rate (`l_homicide`), identified by state (`sid`) across years (`year`). Recall from the previous lecture that the TWFE coefficient on `cdl` was approximately 0.08 — an 8% increase in homicides. Now let's see what's behind that number.

### From DiD to Event Study: Leads and Lags

In a staggered rollout, different states pass the castle doctrine in different years. The variable `effyear` records the year each state adopted the law. To conduct an event study, we need to measure time *relative to treatment*:

```stata
* load data and set panel
	use             "https://github.com/scunning1975/mixtape/raw/master/castle.dta", clear
	xtset           sid year

* define global macros
	global 			crime1 jhcitizen_c jhpolice_c murder homicide ///
						robbery assault burglary larceny motor robbery_gun_r 
	global 			demo blackm_15_24 whitem_15_24 blackm_25_44 whitem_25_44 //demographics
	global 			lintrend trend_1-trend_51 //state linear trend
	global 			region r20001-r20104  //region-quarter fixed effects
	global 			exocrime l_larceny l_motor // exogenous crime rates
	global 			spending l_exp_subsidy l_exp_pubwelfare
	global 			xvar l_police unemployrt poverty l_income ///
		l_prisoner l_lagprisoner $demo $spending
	lab var			post "Year of treatment"

* create relative time
* for never-treated units, we leave it missing
	gen             rel_time = year - effyear if effyear != .

* create lead dummies (pre-treatment)
	forvalues       k = 1/9 {
	    gen         lead`k' = (rel_time == -`k')
	}

* create lag dummies (post-treatment)
	forvalues       k = 0/5 {
	    gen         lag`k' = (rel_time == `k')
	}
```

`rel_time` $= 0$ is the year the law passed. `rel_time` $< 0$ are the "leads" (pre-treatment periods). `rel_time` $> 0$ are the "lags" (post-treatment periods). Never-treated states have missing `rel_time` — their lead and lag dummies are all zero, so they serve as controls.

The `forvalues` loops create a dummy for each period relative to treatment. For example, `lead3` equals 1 when a state is 3 years *before* its law passed, and `lag2` equals 1 when a state is 2 years *after*.

The event study regression replaces the single `post` dummy with this full set of period-specific dummies. We include leads 9 through 1 and lags 1 through 5, but *omit* `lag0` (the treatment year) — making it the reference category:

$$ Y_{it} = \alpha_i + \gamma_t + \sum_{k \neq 0} \delta_k \cdot D_{it}^k + X_{it}\beta + \epsilon_{it} $$

The pre-treatment coefficients ($\delta_{-k}$) test for parallel trends: if they are close to zero, the treatment and control groups were trending similarly before the law. The post-treatment coefficients trace the dynamic effect path.

```stata
* event study regression — lag0 is omitted as the reference category
	xi: xtreg       l_homicide lead9 lead8 lead7 lead6 lead5 ///
	                    lead4 lead3 lead2 lead1 ///
	                    lag1 lag2 lag3 lag4 lag5 ///
	                    i.year $region $xvar $lintrend ///
	                    [aweight=popwt], fe vce(cluster sid)
```

Look at the output: leads 1 through 6 should be close to zero and statistically insignificant — evidence consistent with parallel trends. The lags should be positive, showing that homicides increased *after* states passed castle doctrine laws.

> Do [Exercise 4 - Event Study Regression]({{ site.baseurl }}/exercises/12-event-dummies/)

### Visualizing with `coefplot`

Event study tables are massive and hard to interpret at a glance. The standard practice is to plot the coefficients with confidence intervals. The `coefplot` command (by Ben Jann) makes this straightforward:

```stata
* event study plot
	coefplot,       keep(lead9 lead8 lead7 lead6 lead5 ///
	                    lead4 lead3 lead2 lead1 ///
	                    lag1 lag2 lag3 lag4 lag5) ///
	                    vertical ///
	                    yline(0, lcolor(black) lpattern(dash)) ///
	                    xline(9.5, lcolor(maroon) lpattern(dash)) ///
	                    title("Event Study: Castle Doctrine on Homicides") ///
	                    xtitle("Periods Relative to Treatment") ///
	                    ytitle("Log Homicide Rate") ///
	                    msymbol(D) mfcolor(white) ///
	                    recast(connected) ///
	                    ciopts(recast(rcap)) ///
	                    graphregion(color(white))
```

Reading the plot:
- **Left of the vertical dashed line**: these are the *pre-treatment* leads. If the points hover around zero, there's no evidence of differential pre-trends.
- **Right of the line**: these are the *post-treatment* lags. Positive coefficients indicate castle doctrine raised homicides.
- **The horizontal dashed line** at $y = 0$ is the reference: no effect.

This kind of figure has become the "heart and soul" of modern DiD papers (Cunningham 2021). It simultaneously demonstrates the plausibility of parallel trends and the dynamic causal effect.

> Do [Exercise 5 - Event Plot]({{ site.baseurl }}/exercises/12-event-plot/)

### The Bacon Decomposition: What's Inside the TWFE Estimate?

We introduced Goodman-Bacon's (2021) decomposition in the TWFE lecture and applied `bacondecomp` to simulated data. Now let's revisit it with the Castle Doctrine — a real-world example of staggered adoption.

Recall the three types of 2×2 comparisons hiding inside TWFE:

1. **Treated vs. Never-Treated** — the "clean" comparison.
2. **Early-Treated vs. Not-Yet-Treated** — also clean.
3. **Later-Treated vs. Already-Treated** — *Problematic*: the "control" group is already treated!

Let's decompose the Castle Doctrine TWFE estimate:

```stata
* simple twfe for decomposition (no extra covariates)
	areg            l_homicide post i.year, absorb(sid) robust

* bacon decomposition
	bacondecomp     l_homicide post, ddetail
```

`bacondecomp` produces a scatter plot where:
- Each point is one $2 \times 2$ sub-estimate
- The x-axis shows the **weight** that sub-estimate receives in the final TWFE coefficient
- The y-axis shows the **point estimate** from that $2 \times 2$
- Points are colored/shaped by type (Treated vs. Never Treated, Earlier vs. Later Treated, etc.)

The dashed horizontal line is the overall TWFE estimate — the weighted average of all these points. Unlike our simulation where the bias was dramatic, the Castle Doctrine case is reassuring: the "clean" comparisons and the full TWFE estimate point in the same direction, suggesting the staggered-adoption bias is modest here.

**Why this matters:** When the Bacon decomposition shows that problematic comparisons have large weights *and* pull the estimate in a different direction, you should turn to modern robust estimators like `csdid` (which we covered last lecture). The event study plot and the Bacon decomposition together form your diagnostic toolkit.

> Do [Exercise 6 - Bacon Decomposition]({{ site.baseurl }}/exercises/12-event-metrics/)

### Dedicated Packages

Manually creating lead and lag dummies, binning endpoints, and relabeling axes is tedious. Dedicated event study packages handle all of this automatically. Two popular options:

- `eventdd` — Produces event study regressions and plots in one command
- `xtevent` — More flexible, handles heterogeneous treatment effects

To install these, add `eventdd` and `boottest` to the package loop in your `project.do` file. Then change `$pack` to 1 and re-run `project.do`. Once the packages install, change `$pack` back to 0.

```stata
* create relative time for eventdd
	gen             rel_time = year - effyear if effyear != .

* eventdd automates the entire process
	eventdd         l_homicide i.year, timevar(rel_time) ///
	                    method(fe, cluster(sid)) ///
	                    graph_op(ytitle("Effect on Homicide"))
```

These packages not only automate the dummy creation and plotting, but also handle endpoint binning and allow for alternative estimation methods that address the TWFE bias we discovered with the Bacon decomposition.

> Do [Exercise 7 - Using the eventdd Package]({{ site.baseurl }}/exercises/12-event-package/)
