---
layout: page
element: notes
title: Extensions of RDD
language: Stata
---

In the [previous lecture]({{ site.baseurl }}/materials/14-rdd/), we covered the basics of Regression Discontinuity Design (RDD), including clear visual diagnostics and estimation of sharp RDDs using OLS and `rdrobust`. 

This lecture covers:
- Fuzzy RDD and the IV approach
- Diagnostic checks: density tests and placebo outcomes
- What RDD actually estimates (Local Average Treatment Effects)
- Connecting RDD to our broader causal inference toolkit

### Fuzzy RDD

When treatment is not perfectly determined by the cutoff, we have a fuzzy RDD. The solution is to use the cutoff as an **instrument** for treatment, scaling the reduced-form jump by the first-stage jump in treatment rates at the cutoff. This is the IV logic from [Week 13]({{ site.baseurl }}/materials/13-iv/) applied to the discontinuity setting.

We illustrate this with data from Fetter (2013), who studies the effect of veteran mortgage subsidies on home ownership. The running variable is quarter of birth relative to Korean War eligibility (`qob_minus_kw`), centered so the cutoff is at zero. Not everyone born at the right time became a veteran, so this is a fuzzy design — treatment rates jump at the cutoff, but not from 0% to 100%.

#### Fuzzy RDD by hand with IV

```stata
* load mortgages data
    causaldata mortgages.dta, use clear download

* create an above variable as an instrument
    gen             above = qob_minus_kw > 0

* impose a bandwidth of 12 quarters on either side
    keep if         abs(qob_minus_kw) < 12

* regress, using above as an instrument for veteran status.
* note that qob_minus_kw by itself doesn't need instrumentation
* so we separate it. usually I advise against it,
* but in this case this is easier if we just make our
* own interaction with g (generate)
    gen             interaction_vet = vet_wwko*qob_minus_kw
    gen             interaction_above = above*qob_minus_kw

    ivregress 2sls  home_ownership nonwhite qob_minus_kw ///
                        i.qob (vet_wwko interaction_vet = ///
                        above interaction_above), robust
```

The coefficient on `vet_wwko` is the fuzzy RDD estimate: veteran status (and its mortgage subsidies) increased home ownership by approximately 17 percentage points at this margin.

#### Fuzzy RDD with `rdrobust`

```stata
* reload and limit bandwidth
    causaldata mortgages.dta, use clear download
    keep if         abs(qob_minus_kw) <= 12

* and run rdrobust
    rdrobust        home_ownership qob_minus_kw, c(0) ///
                        fuzzy(vet_wwko)
```

The `fuzzy()` option tells `rdrobust` to instrument treatment with the cutoff indicator, performing a local-polynomial fuzzy RDD. As with the sharp case, the automated and by-hand estimates may differ — here because `rdrobust` picks a much narrower bandwidth (around 3.4 quarters vs. our imposed 12). Whether the narrow or wide bandwidth is more appropriate is a substantive judgment about how far from the cutoff observations are still comparable.

> Do [Exercise 4 - First Stage]({{ site.baseurl }}/exercises/14-rdd-first-stage/)

> Do [Exercise 5 - Fuzzy RDD]({{ site.baseurl }}/exercises/14-rdd-fuzzy/)

### Diagnostic checks

RDD relies on the assumption that nothing other than treatment changes at the cutoff. We have two main ways to probe this assumption. This is directly analogous to the balance checks we do in experiments and the pre-trend tests we do in event studies ([Week 12]({{ site.baseurl }}/materials/12-event-studies/)).

#### Density test: checking for manipulation

If individuals can manipulate their running variable to sort onto the treated side, then the comparison at the cutoff is no longer quasi-random. We test for this by checking whether the **density** of the running variable is smooth at the cutoff. A discontinuity in the density suggests manipulation.

The intuition is simple: if track-and-field tryouts have a cutoff of 5:37 for a mile and the friendly timekeeper is shaving seconds off for people who run 5:38 or 5:39, you'll see a suspicious pile-up of people just below the cutoff. If nobody can manipulate the running variable, the density should be smooth across the cutoff — no pile-up, no gap.

In the government transfers data, manipulation is unlikely. The running variable is a predicted income score based on multiple factors, determined before anyone knew who would qualify. People couldn't easily manipulate it. But we should still check.

The `rural_roads` replication package includes a custom Stata command of this test called `dc_density` based on McCrary (2008). You must add the `dc_density` program from the replication code `00_setup.do` script to your `project.do` file so that it is available to use.

```stata
* load density data (includes obs outside estimation bandwidth)
    causaldata gov_transfers_density.dta, use clear download

* limit to the bandwidth ourselves
    keep if         abs(income_centered) < .02

* run the discontinuity check
    dc_density      income_centered, breakpoint(0) ///
                        generate(Xj Yj r0 fhat se_fhat) ///
                        graphname("density_plot.eps")
```

A non-significant test statistic is what we hope for: no evidence that individuals bunched on one side of the cutoff. The `dc_density` command automatically produces a plot for you to visually inspect for bunching. Look for a smooth distribution with no suspicious gap or pile-up at zero.

> Do [Exercise 6 - Density Test]({{ site.baseurl }}/exercises/14-rdd-density/)

#### Placebo outcomes: checking for other discontinuities

If treatment is the only thing that changes at the cutoff, then variables that treatment should **not** affect — such as pre-treatment demographic characteristics — should show no discontinuity. Simply re-run your RDD model with each control variable as the outcome:

```stata
* reload the data
    causaldata gov_transfers.dta, use clear download

* placebo check: run rdrobust on a variable treatment should not affect
    rdrobust        age income_centered, c(0)
```

Finding effects on placebo outcomes would cast doubt on the design. If you test a long list of placebo variables, expect a few to show nonzero effects by random chance — that's not necessarily fatal. But systematic failures suggest something is wrong at the cutoff.

> Do [Exercise 7 - Placebo Outcomes]({{ site.baseurl }}/exercises/14-rdd-placebo/)

### What does RDD estimate?

RDD estimates a **local average treatment effect (LATE)**: the effect of treatment for individuals right at the cutoff. This is fundamentally different from the ATE we might get from an experiment.

Whether LATE is useful depends on the question:
- If policy would be expanded by shifting the cutoff, then the LATE for people at the margin is exactly what we want. Knowing the effect for people who score 94 vs. 96 on the gifted-and-talented exam is directly relevant if we're deciding whether to move the cutoff from 95 to 93.
- If we want the effect for a broader population far from the cutoff, RDD cannot tell us that. A relief program cutoff at $75,000 income tells us nothing about the effect for households earning $20,000 — even though they received the same checks.

This mirrors the LATE interpretation from IV ([Week 13]({{ site.baseurl }}/materials/13-iv/)): both methods identify effects for compliers at the margin, not for the full population.

### Connecting to the toolkit

RDD completes the set of quasi-experimental methods in this course:

| Method | Identifies from | Key assumption |
|---|---|---|
| Fixed Effects | Within-unit variation | Time-invariant confounders only |
| DiD | Pre-post, treatment-control | Parallel trends |
| IV | Exogenous instrument | Exclusion restriction |
| **RDD** | **Cutoff in running variable** | **Continuity at the cutoff** |

Each method isolates a different source of identifying variation. The right choice depends on the structure of the data generating process and the available institutional features. All of them are strategies for solving the identification problem we first encountered in [Week 8]({{ site.baseurl }}/materials/08-identification/) — isolating the causal variation from the noise.

### Summary

- **Fuzzy Regression Discontinuity** occurs when treatment is not perfectly determined by the cutoff. In this case, we use the cutoff as an instrument for treatment.
- Always run **diagnostic checks** — density tests to rule out manipulation and placebo outcomes to rule out other discontinuities at the cutoff — just as you would check parallel trends in DiD or instrument validity in IV.
