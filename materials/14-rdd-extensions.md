---
layout: page
element: notes
title: Extensions of RDD
language: Stata
---

In the previous lecture, we covered the basics of Regression Discontinuity Design (RDD), including clear visual diagnostics and estimation of sharp RDDs using OLS and `rdrobust`. 

This lecture covers:
- Fuzzy RDD and the IV approach
- Diagnostic checks: density tests and placebo outcomes
- What RDD actually estimates (Local Average Treatment Effects)
- Connecting RDD to our broader causal inference toolkit

### Fuzzy RDD

When treatment is not perfectly determined by the cutoff, we have a fuzzy RDD. The solution is to use the cutoff as an **instrument** for treatment, scaling the reduced-form jump by the first-stage jump in treatment rates at the cutoff. This is the IV logic from [Week 13]({{ site.baseurl }}/materials/13-iv/) applied to the discontinuity setting.

Again, we will follow Chapter 20 of [*The Effect*](https://theeffectbook.net/ch-RegressionDiscontinuity.html) closely but in this lecture we will use [Fetter (2013)](https://doi.org/10.1257/pol.5.2.111) and its example data, which is called `mortgages.dta` and is available on the [list of datasets page]({{ site.baseurl }}/materials/datasets/). Fetter’s research question is what portion of the increase in home ownership in the mid-century US was due to mortgage subsidies given out by the government. To get at this question, Fetter looks at men who were about the right age to be veterans of World War II or the Korean War. Anyone who was a veteran of these wars received GI Bill benefits, including special mortgage subsidies.

The running variable is quarter of birth relative to Korean War eligibility (`qob_minus_kw`), centered so the cutoff is at zero. This partially determines if you were a veteran of WWII or the Korean War (vet_wwko). Not everyone born at the right time became a veteran, so this is a fuzzy design — treatment rates jump at the cutoff, but not from 0% to 100%.

#### Fuzzy RDD by hand with IV

We can implement fuzzy RDD using `ivregress` or `ivreg2`. The syntax is the same as for sharp RDD, except that we include the instrument in the second-stage regression. Just to get you experienve with more packages, add `ivreghdfe` to your `project.do` file. This is the IV version of the `reghdfe` package we used in [Week 12]({{ site.baseurl }}/materials/12-event-studies/).

```stata
* load mortgages data
    use "$data/mortgages.dta", clear

* create an above variable as an instrument
    gen             above = qob_minus_kw > 0

* impose a bandwidth of 12 quarters on either side
    keep if         abs(qob_minus_kw) < 12

* regress, using above as an instrument for veteran status.
* note that qob_minus_kw by itself doesn't need instrumentation
    gen             interaction_vet = vet_wwko*qob_minus_kw
    gen             interaction_above = above*qob_minus_kw

    ivreghdfe       home_ownership nonwhite qob_minus_kw ///
                        i.qob (vet_wwko interaction_vet = ///
                        above interaction_above), robust
```

The coefficient on `vet_wwko` is the fuzzy RDD estimate: veteran status (and its mortgage subsidies) increased home ownership by approximately 17 percentage points at this margin.

> Do [Exercise 4 - First Stage]({{ site.baseurl }}/exercises/14-rdd-first-stage/)

#### Fuzzy RDD with `rdrobust`

The `fuzzy()` option tells `rdrobust` to instrument treatment with the cutoff indicator, performing a local-polynomial fuzzy RDD. As with the sharp case, the automated and by-hand estimates may differ — here because `rdrobust` picks a much narrower bandwidth (around 3.4 quarters vs. our imposed 12). Whether the narrow or wide bandwidth is more appropriate is a substantive judgment about how far from the cutoff observations are still comparable.

```stata
* add the fuzzy option and run rdrobust
    rdrobust        home_ownership qob_minus_kw, c(0) ///
                        fuzzy(vet_wwko)
```

The output is very similar to the sharp RDD case, except that we now have a first-stage estimate and a fuzzy RDD estimate.

```text
.     rdrobust        home_ownership qob_minus_kw, c(0) ///
>                         fuzzy(vet_wwko)
Mass points detected in the running variable.

Fuzzy RD estimates using local polynomial regression.

      Cutoff c = 0 | Left of c  Right of c            Number of obs =      56901
-------------------+----------------------            BW type       =      mserd
     Number of obs |     28776       28125            Kernel        = Triangular
Eff. Number of obs |      6911        6756            VCE method    =         NN
    Order est. (p) |         1           1
    Order bias (q) |         2           2
       BW est. (h) |     2.797       2.797
       BW bias (b) |     5.225       5.225
         rho (h/b) |     0.535       0.535
        Unique obs |        12          12

First-stage estimates. Outcome: vet_wwko. Running variable: qob_minus_kw.
--------------------------------------------------------------------------------
                   | Point         | Robust Inference
                   | Estimate      | z-stat        P>|z|    [95% Conf. Interval]
-------------------+------------------------------------------------------------
         RD Effect | -.01172       | 0.4212        0.674    -.049723     .026274
--------------------------------------------------------------------------------

Treatment effect estimates. Outcome: home_ownership. Running variable: qob_minus_kw. Treatment Status: vet_wwko.
--------------------------------------------------------------------------------
                   | Point         | Robust Inference
                   | Estimate      | z-stat        P>|z|    [95% Conf. Interval]
-------------------+------------------------------------------------------------
         RD Effect |  1.8785       | 1.2601        0.208    -2.81729     12.9629
--------------------------------------------------------------------------------
Estimates adjusted for mass points in the running variable.
```

The core differences from a sharp RDD output are the two distinct estimation tables:

- **First-stage estimates**: This table shows the jump in the *treatment probability* (veteran status) exactly at the cutoff. According to the output, the optimal bandwidth of ~2.8 quarters yields a first stage that is actually negative and entirely non-significant (`P>|z| = 0.674`). This is a clear warning sign: within this very narrow bandwidth, the cutoff acts as a "weak instrument", meaning treatment rates don't meaningfully jump at the threshold for this thin slice of data.
- **Treatment effect estimates**: This is the fuzzy RDD estimate (the Wald estimator: the reduced-form jump in home ownership divided by the first-stage jump in veteran status). It estimates that veteran status increased home ownership by 1.88 percentage points. However, because our first stage is weak within this sample width, the treatment effect is highly imprecise and not statistically significant (`p=0.208`). Notice how different this is from the 17 percentage points we found by hand using a wider, 12-quarter bandwidth.
- **Unique obs**: The readout warns "Mass points detected" and shows only 12 unique observations on either side within the optimal bandwidth. Since quarter-of-birth is grouped into discrete quarters, an overly narrow bandwidth captures too few unique values of the running variable. This stifles the polynomial regression estimator and wildly inflates the standard errors.

> Do [Exercise 5 - Fuzzy RDD]({{ site.baseurl }}/exercises/14-rdd-fuzzy/)

### Diagnostic checks

RDD relies on the assumption that nothing other than treatment changes at the cutoff. We have two main ways to probe this assumption. This is directly analogous to the balance checks we do in experiments and the pre-trend tests we do in event studies ([Week 12]({{ site.baseurl }}/materials/12-event-studies/)).

#### Density test: checking for manipulation

If individuals can manipulate their running variable to sort onto the treated side, then the comparison at the cutoff is no longer quasi-random. We test for this by checking whether the **density** of the running variable is smooth at the cutoff. A discontinuity in the density suggests manipulation.

The intuition is simple: if track-and-field tryouts have a cutoff of 5:37 for a mile and the friendly timekeeper is shaving seconds off for people who run 5:38 or 5:39, you'll see a suspicious pile-up of people just below the cutoff. If nobody can manipulate the running variable, the density should be smooth across the cutoff — no pile-up, no gap.

In the government transfers data, manipulation is unlikely. The running variable is a predicted income score based on multiple factors, determined before anyone knew who would qualify. People couldn't easily manipulate it. But we should still check.

The `rural_roads` replication package that we are using for exercises this week includes a custom Stata command of this test called `dc_density` based on [McCrary (2008)](https://eml.berkeley.edu/~jmccrary/DCdensity/). The `dc_density` package is not available on SSC, so you must download it from the [course website]({{ site.baseurl }}/code/dc_density.ado) and the place it in the folder where Stata stores all the user written packages. Typically it is at `/Users/UserName/ado/plus` and then you copy it into the folder that has the the corresponding letter to the package name, in this case `d`.

```stata
* load density data (includes obs outside estimation bandwidth)
    use "$data/gov_transfers_density.dta, clear

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

If treatment is the only thing that changes at the cutoff, then variables that treatment should **not** affect — such as pre-treatment demographic characteristics — should show no discontinuity. Simply re-run your RDD model with control variables as the outcome:

```stata
* placebo check: run rdrobust on a variable treatment should not affect
    rdrobust        age income_centered, c(0)
```

Finding effects on placebo outcomes would cast doubt on the design. If you test a long list of placebo variables, expect a few to show nonzero effects by random chance — that's not necessarily fatal. But systematic failures suggest something is wrong at the cutoff.

> Do [Exercise 7 - Placebo Outcomes]({{ site.baseurl }}/exercises/14-rdd-placebo/)

### What does RDD estimate?

RDD estimates a **local average treatment effect (LATE)**: the effect of treatment for individuals right at the cutoff. This is fundamentally different from the **Average Treatment Effect (ATE)** that we typically want to estimate.

Whether estimating the LATE is useful depends on the question:
- If policy would be expanded by shifting the cutoff, then the LATE for people at the margin is exactly what we want. Knowing the effect for people who score 94 vs. 96 on the gifted-and-talented exam is directly relevant if we're deciding whether to move the cutoff from 95 to 93.
- If we want the effect for a broader population far from the cutoff, RDD cannot tell us that. A relief program cutoff at \\$75,000 income tells us nothing about the effect for households earning \\$20,000 — even though they received the same checks.

This mirrors the LATE interpretation from IV ([Week 13]({{ site.baseurl }}/materials/13-iv/)): both methods identify effects for compliers at the margin, not for the full population.

### Connecting to the toolkit

RDD completes the set of quasi-experimental methods in this course:

| Method | Identifies from | Key assumption |
|---|---|---|
| Fixed Effects | Within-unit variation | Time-invariant confounders only |
| DiD | Pre-post, treatment-control | Parallel trends |
| IV | Exogenous instrument | Exclusion restriction |
| **RDD** | Cutoff in running variable | Continuity at the cutoff |

Each method isolates a different source of identifying variation. The right choice depends on the structure of the data generating process and the available institutional features. All of them are strategies for solving the identification problem we first encountered in [Week 8]({{ site.baseurl }}/materials/08-identification/) — isolating the causal variation from the noise.

### Summary

- **Fuzzy Regression Discontinuity** occurs when treatment is not perfectly determined by the cutoff. In this case, we use the cutoff as an instrument for treatment.
- Always run **diagnostic checks** — density tests to rule out manipulation and placebo outcomes to rule out other discontinuities at the cutoff — just as you would check parallel trends in DiD or instrument validity in IV.
