---
layout: page
element: notes
title: Regression Discontinuity
language: Stata
---

Difference-in-Differences and Instrumental Variables are powerful tools, but both require assumptions about unobservables — parallel trends, exclusion restrictions — that can be difficult to defend. This week we study a design where identification comes from something much more concrete: a **cutoff**.

San Diego is a large, prosperous US city. As you drive south through it, incomes decline a bit — maybe from $85,000 to $55,000 over 16 miles to the border district of San Ysidro. It's a smooth, gradual gradient. Then you take one step over the US-Mexico border into Tijuana and household incomes crash to $20,000. Nothing about geography or the people changes in that single step. What changes is the *policy regime*. That abrupt break — smooth trend, sudden jump — is the logic of regression discontinuity.

Whenever treatment is assigned based on whether a running variable crosses a threshold, individuals just on either side of that threshold are effectively randomly assigned. This is the core insight of **Regression Discontinuity Design (RDD)**.

This lecture covers:
- The intuition behind regression discontinuity
- Key terminology: running variable, cutoff, bandwidth
- Sharp vs fuzzy RDD
- Implementing RDD by hand with OLS
- The "zoom in and go simple" approach: bandwidth and kernel weighting
- Using the `rdrobust` package for local polynomial estimation
- Diagnostic checks: density tests and placebo outcomes

We follow Chapter 20 of [*The Effect*](https://theeffectbook.net/ch-RegressionDiscontinuity.html) closely and use its example data from [Manacorda, Miguel, and Vigorito (2011)](https://doi.org/10.1257/app.3.3.1) and [Fetter (2013)](https://doi.org/10.1257/pol.5.2.111). The `causaldata` package provides both datasets. If you have not installed `causaldata`, add it to your `project.do` package loop, set `$pack = 1`, run `project.do`, then set `$pack = 0`.

### The idea behind regression discontinuity

Imagine a government poverty program that gives cash transfers to households whose predicted income falls below a threshold. Households just barely below the cutoff receive the transfer; households just barely above it do not. These two groups are, in every meaningful sense, nearly identical — except one group received cash and the other did not.

This is the logic of RDD: compare observations **just on either side** of a cutoff in a running variable. If assignment to treatment is determined (or strongly influenced) by crossing that cutoff, and we believe that nothing else jumps at the same point, then any discontinuity in the outcome at the cutoff can be attributed to the treatment.

#### Connecting RDD to the identification toolkit

Recall from [Week 8]({{ site.baseurl }}/materials/08-dags/) that we identify causal effects by blocking back-door paths. In RDD, we don't need to find and close every back door individually. Instead, by focusing on variation **only at the cutoff**, we isolate the front-door path:

```text
RunningVariable  →  AboveCutoff  →  Treatment  →  Outcome
```

Everything else — all the back doors through unobservables — washes out because nothing else jumps at the cutoff. This is conceptually similar to what IV does (isolating a front-door path), but the source of identifying variation is the cutoff rather than an external instrument.

### Key terminology

- **Running variable** (also called the *forcing variable*): the variable that determines treatment. For the poverty program, this is predicted income.
- **Cutoff**: the threshold value. Below the cutoff you get the transfer, above it you do not (or vice versa).
- **Bandwidth**: how far from the cutoff we are willing to look. Observations close to the cutoff are more comparable, but a narrow bandwidth means fewer observations and less precision. This is the fundamental bias-variance tradeoff in RDD.

### Sharp vs fuzzy RDD

In a **sharp** RDD, the cutoff perfectly determines treatment: everyone below gets treated, everyone above does not. Treatment rates jump from 0% to 100% at the cutoff.

In a **fuzzy** RDD, crossing the cutoff changes the *probability* of treatment but does not determine it completely. For example, reaching pension eligibility age sharply increases the retirement rate, but not everyone retires the moment they become eligible. In this case, the cutoff is used as an **instrument** for treatment, and we scale our estimate using IV — exactly as we did in [Week 13]({{ site.baseurl }}/materials/13-iv/).

### Implementing sharp RDD by hand

We use data from Manacorda, Miguel, and Vigorito (2011), which studies whether receiving government cash transfers in Uruguay increased political support for the incumbent government. The running variable (`income_centered`) is a predicted income score, already centered so the cutoff is at zero. The outcome (`support`) measures government approval. Treatment (`participation`) indicates receipt of the transfer.

#### Visualizing the discontinuity

Before estimating anything, we should graph the data. A plot of binned means is the standard RDD visual diagnostic — and it's *nearly compulsory* (Chapter 20 emphasizes this). We slice the running variable into bins, compute the mean outcome in each bin, and look for a jump at the cutoff.

```stata
* load government transfers data
    causaldata gov_transfers.dta, use clear download

* create bins. 15 bins on either side of the cutoff from
* -.02 to .02, plus 0, means we want "steps" of...
    local step = (.02)/15
    egen bins = cut(income_centered), at(-.02(`step').02)

* means within bins
    collapse (mean) support, by(bins)

* and graph with a cutoff line
    twoway          (line support bins) || ///
                        (function y = 0, horiz range(support)), ///
                        xti("Centered Income") yti("Support")
```

You should see a visible jump at the cutoff: observations to the left (lower income, eligible for transfers) show higher government support than observations to the right. This is the visual signature of RDD — a smooth trend with an abrupt break.

> Do [Exercise 1 - Binned Means Plot]({{ site.baseurl }}/exercises/14-rdd-binplot/)

#### The OLS approach

The simplest way to estimate an RDD is to run a regression with the running variable, a treatment indicator, and their interaction. Crucially, we must **center** the running variable so that the intercept shift at zero gives us the treatment effect directly.

The linear model is:

$$Y_i = \beta_0 + \beta_1 (Running_i - Cutoff) + \beta_2 Treated_i + \beta_3 (Running_i - Cutoff) \times Treated_i + \varepsilon_i$$

Since our running variable is already centered ($Cutoff = 0$), $\beta_2$ is the RDD estimate: the jump in the outcome at the cutoff. We allow the slope to differ on each side via the interaction $\beta_3$.

Notice the lack of control variables. This is intentional. The whole idea of RDD is that treatment assignment is effectively random at the cutoff. If that's true, there are no open back doors to close — adding controls implies you don't believe the design works. Controls are more common in fuzzy RDD (where there are other determinants of treatment) and can help with precision, but they should not be necessary for identification.

We can also use a second-order polynomial to allow for curvature:

```stata
* reload the data
    causaldata gov_transfers.dta, use clear download

* include the running variable, its square (by interaction with itself)
* and interactions of both with treatment, and robust standard errors
    reg             support i.participation##c.income_centered ///
                        ##c.income_centered, robust
```

The coefficient on `1.participation` is the RDD estimate: approximately 9.3 percentage points increase in government support.

**A warning about polynomials:** [Gelman and Imbens (2019)](https://doi.org/10.1080/07350015.2017.1366909) show that high-order polynomials (third-order and above) should not be used in RDD. More flexible shapes sound appealing in principle, but they make increasingly wild predictions near the edges of the data — exactly where the cutoff sits. A fourth- or sixth-order polynomial can veer off dramatically at the cutoff, giving you a "precise" estimate that is entirely an artifact of the polynomial's bad behavior. The recommended approach: never go above a second-order polynomial. If the shape is complex, zoom in with a bandwidth and use a linear model instead.

#### Adding a kernel weight and bandwidth

Rather than fitting a global polynomial, we can restrict our attention to observations close to the cutoff using a **bandwidth** and weight observations by their distance from the cutoff using a **triangular kernel**. This is the "zoom in and go simple" approach — use a linear model, but only on data near the cutoff. A triangular kernel gives full weight to observations right at the cutoff and linearly decreasing weight as you move away, reaching zero at the bandwidth boundary.

```stata
* create the triangular kernel weight. to start at a weight of 0 at x = 0,
* and impose a bandwidth of .01, we need a "slope" of -1/.01 = 100
* and to go in either direction use the absolute value
    gen             w = 1 - 100*abs(income_centered)

* if further away than .01, the weight is 0, not negative
    replace         w = 0 if w < 0

    reg             support i.participation##c.income_centered ///
                        [aw = w], robust
```

The kernel-weighted estimate here is smaller and less precise than the polynomial version. That's the bias-variance tradeoff at work: by zooming in close, we reduce bias (observations far from the cutoff can't distort our estimate), but we also lose observations. The data was already limited to a narrow range around the cutoff, so further restricting the bandwidth is aggressive here.

> Do [Exercise 2 - OLS Regression Discontinuity]({{ site.baseurl }}/exercises/14-rdd-ols/)

### Using `rdrobust`

Manual RDD estimation requires many decisions: polynomial order, bandwidth, kernel shape, standard error correction. The `rdrobust` package (Calonico, Cattaneo, and Titiunik) handles all of these with data-driven defaults:

1. **Optimal bandwidth selection** — automatically chooses the bandwidth that balances bias and variance
2. **Local polynomial regression** — fits a local linear (or polynomial) regression with a triangular kernel
3. **Robust standard errors** — uses a heteroskedasticity-robust estimator tailored to the RDD structure
4. **Bias correction** — adjusts for the bias introduced by the optimal bandwidth procedure

Install `rdrobust` by adding it to your `project.do` package loop:

```stata
* install rdrobust
    ssc install    rdrobust, replace
```

```stata
* reload the data
    causaldata gov_transfers.dta, use clear download

* run the RDD model and plot it. note, by default,
* rdrobust and rdplot use different
* numbers of polynomial terms.
* you can set the p() option to standardize them.
    rdrobust        support income_centered, c(0)
    rdplot          support income_centered, c(0)
```

`rdrobust` reports the conventional estimate, the bias-corrected estimate, and a robust confidence interval. The `rdplot` command produces a publication-quality binned-means graph with fitted polynomials on each side of the cutoff.

The output from `rdrobust` may differ substantially from our by-hand estimates — possibly even in sign — because it selects a potentially narrower bandwidth. This illustrates an important lesson: **you should not blindly accept the defaults**. Just because we have a pre-packaged command does not mean we can let it make all the decisions. Explore the sensitivity of your results to different bandwidths and polynomial orders.

#### Bandwidth sensitivity

In practice, researchers report how the RDD estimate changes across a range of bandwidths. This is exactly what you would do in a specification chart ([Week 10]({{ site.baseurl }}/materials/10-coefplot/)) — vary an analytic choice and show whether the result is stable:

```stata
* check sensitivity to different bandwidths
    foreach bw in .005 .008 .01 .015 .02 {
        di as text "Bandwidth = `bw'"
        rdrobust    support income_centered, c(0) h(`bw')
    }
```

If the estimate is fairly stable across bandwidths, that's reassuring. If it swings wildly, you should think carefully about which bandwidth range is most credible given the context.

> Do [Exercise 3 - Using rdrobust]({{ site.baseurl }}/exercises/14-rdd-rdrobust/)

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

> Do [Exercise 4 - Fuzzy RDD]({{ site.baseurl }}/exercises/14-rdd-fuzzy/)

### Diagnostic checks

RDD relies on the assumption that nothing other than treatment changes at the cutoff. We have two main ways to probe this assumption. This is directly analogous to the balance checks we do in experiments and the pre-trend tests we do in event studies ([Week 12]({{ site.baseurl }}/materials/12-event-studies/)).

#### Density test: checking for manipulation

If individuals can manipulate their running variable to sort onto the treated side, then the comparison at the cutoff is no longer quasi-random. We test for this by checking whether the **density** of the running variable is smooth at the cutoff. A discontinuity in the density suggests manipulation.

The intuition is simple: if track-and-field tryouts have a cutoff of 5:37 for a mile and the friendly timekeeper is shaving seconds off for people who run 5:38 or 5:39, you'll see a suspicious pile-up of people just below the cutoff. If nobody can manipulate the running variable, the density should be smooth across the cutoff — no pile-up, no gap.

In the government transfers data, manipulation is unlikely. The running variable is a predicted income score based on multiple factors, determined before anyone knew who would qualify. People couldn't easily manipulate it. But we should still check.

The `rddensity` package implements the test from Cattaneo, Jansson, and Ma (2020). Install it by adding it to your `project.do` package loop (use `findit rddensity` if it is not on SSC).

```stata
* load density data (includes obs outside estimation bandwidth)
    causaldata gov_transfers_density.dta, use clear download

* limit to the bandwidth ourselves
    keep if         abs(income_centered) < .02

* run the discontinuity check
    rddensity       income_centered, c(0)
```

A non-significant test statistic is what we hope for: no evidence that individuals bunched on one side of the cutoff. You should also **plot** the density to visually inspect for bunching — the `rddensity` command can produce this with a `plot` option. Look for a smooth distribution with no suspicious gap or pile-up at zero.

#### Placebo outcomes: checking for other discontinuities

If treatment is the only thing that changes at the cutoff, then variables that treatment should **not** affect — such as pre-treatment demographic characteristics — should show no discontinuity. Simply re-run your RDD model with each control variable as the outcome:

```stata
* reload the data
    causaldata gov_transfers.dta, use clear download

* placebo check: run rdrobust on a variable treatment should not affect
    rdrobust        age income_centered, c(0)
```

Finding effects on placebo outcomes would cast doubt on the design. If you test a long list of placebo variables, expect a few to show nonzero effects by random chance — that's not necessarily fatal. But systematic failures suggest something is wrong at the cutoff.

> Do [Exercise 5 - Diagnostics]({{ site.baseurl }}/exercises/14-rdd-diagnostics/)

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

- **Regression Discontinuity** exploits a cutoff in a running variable to identify causal effects, by comparing observations just on either side of the threshold where treatment is effectively randomly assigned
- Use `rdrobust` for data-driven bandwidth selection and bias-corrected local polynomial estimation, but always check sensitivity to bandwidth choice and never use polynomials above second order
- Always run **diagnostic checks** — density tests to rule out manipulation and placebo outcomes to rule out other discontinuities at the cutoff — just as you would check parallel trends in DiD or instrument validity in IV
