---
layout: page
element: notes
title: Basic Regression Discontinuity
language: Stata
---

Difference-in-Differences and Instrumental Variables are powerful tools, but both require assumptions about unobservables — parallel trends, exclusion restrictions — that can be difficult to defend. This week we study a design where identification comes from something much more concrete: a **cutoff**.

San Diego is a large, prosperous US city. As you drive south through it, incomes decline a bit — maybe from \\$85,000 to \\$55,000 over 16 miles to the border district of San Ysidro. It's a smooth, gradual gradient. Then you take one step over the US-Mexico border into Tijuana and household incomes crash to \\$20,000. Nothing about geography or the people changes in that single step. What changes is the *policy regime*. That abrupt break — smooth trend, sudden jump — is the logic of regression discontinuity.

Whenever treatment is assigned based on whether a running variable crosses a threshold, individuals just on either side of that threshold are effectively randomly assigned. This is the core insight of **Regression Discontinuity Design (RDD)**.

This lecture covers:
- The intuition behind regression discontinuity
- Key terminology: running variable, cutoff, bandwidth
- Sharp vs fuzzy RDD
- Implementing RDD by hand with OLS
- The "zoom in and go simple" approach: bandwidth and kernel weighting
- Using the `rdrobust` package for local polynomial estimation

We follow Chapter 20 of [*The Effect*](https://theeffectbook.net/ch-RegressionDiscontinuity.html) closely and use its example data from [Manacorda, Miguel, and Vigorito (2011)](https://doi.org/10.1257/app.3.3.1) which is called `gov_transfers.dta` and is available on the [list of datasets page]({{ site.baseurl }}/materials/datasets/).

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
    use "$data/gov_transfers.dta", clear

preserve

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

restore
```

You should see a visible jump at the cutoff: observations to the left (lower income, eligible for transfers) show higher government support than observations to the right. This is the visual signature of RDD — a smooth trend with an abrupt break.

> Do [Exercise 1 - RD Plot]({{ site.baseurl }}/exercises/14-rdd-plot/)

#### The OLS approach

The simplest way to estimate an RDD is to run a regression with the running variable, a treatment indicator, and their interaction. Crucially, we must **center** the running variable so that the intercept shift at zero gives us the treatment effect directly.

The linear model is:

$$Y_i = \beta_0 + \beta_1 (Running_i - Cutoff) + \beta_2 Treated_i + \beta_3 (Running_i - Cutoff) \times Treated_i + \varepsilon_i$$

Since our running variable is already centered ($Cutoff = 0$), $\beta_2$ is the RDD estimate: the jump in the outcome at the cutoff. We allow the slope to differ on each side via the interaction $\beta_3$.

Notice the lack of control variables. This is intentional. The whole idea of RDD is that treatment assignment is effectively random at the cutoff. If that's true, there are no open back doors to close — adding controls implies you don't believe the design works. Controls are more common in fuzzy RDD (where there are other determinants of treatment) and can help with precision, but they should not be necessary for identification.

We can also use a second-order polynomial to allow for curvature:

```stata
* include the running variable, its square (by interaction with itself)
* and interactions of both with treatment, and robust standard errors
    reg     support i.participation##c.income_centered##c.income_centered, ///
                robust
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

> Do [Exercise 2 - Reduced-Form RD]({{ site.baseurl }}/exercises/14-rdd-ols/)

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

`rdrobust` reports the conventional estimate, the bias-corrected estimate, and a robust confidence interval. 

```text
.     rdrobust        support income_centered, c(0)
Mass points detected in the running variable.

Sharp RD estimates using local polynomial regression.

      Cutoff c = 0 | Left of c  Right of c          Number of obs =       1948
-------------------+----------------------          BW type       =      mserd
     Number of obs |      1127         821          Kernel        = Triangular
Eff. Number of obs |       291         194          VCE method    =         NN
    Order est. (p) |         1           1
    Order bias (q) |         2           2
       BW est. (h) |     0.005       0.005
       BW bias (b) |     0.010       0.010
         rho (h/b) |     0.509       0.509
        Unique obs |       841         639

Outcome: support. Running variable: income_centered.
-------------------------------------------------------------------------------
                 | Point         | Robust Inference
                 | Estimate      | z-stat        P>|z|    [95% Conf. Interval]
------------------+------------------------------------------------------------
       RD Effect |   .0247       | 0.6238        0.533    -.097391     .188325
-------------------------------------------------------------------------------
Estimates adjusted for mass points in the running variable.
```

There's a lot going on here compared to standard OLS output. Let's break it down:

- **Data-driven Bandwidth**: `BW type = mserd` means `rdrobust` chose an optimal bandwidth using an MSE-optimal selector. The chosen bandwidth `BW est. (h)` is 0.005, which is quite narrow!
- **Effective Observations**: Because the bandwidth is narrow, we're throwing away a lot of data. The full sample `Number of obs` is 1,948, but the `Eff. Number of obs` (observations actually within the bandwidth on either side of the cutoff) is only 291 on the left and 194 on the right.
- **Kernel Weighting**: `Kernel = Triangular` means it's applying a triangular kernel weight (giving more weight to observations closer to the cutoff), just like we did by hand.
- **Local Polynomial**: `Order est. (p) = 1` indicates it's fitting a local linear regression (an order 1 polynomial).
- **The Estimate**: The actual jump at the cutoff is the **Point Estimate**, which is `0.0247` (or about 2.5 percentage points). This is much smaller than our manual OLS estimate.
- **Robust Inference**: Because we threw away so much data by zooming in, our estimate is noisier. The z-statistic uses robust bias-corrected standard errors. Under these optimal settings, the effect has a p-value of `0.533` — it is no longer statistically significant! 

The `rdplot` command also produces a publication-quality binned-means graph with fitted polynomials on each side of the cutoff.

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

> Do [Exercise 3 - Using `rdrobust`]({{ site.baseurl }}/exercises/14-rdd-rdrobust/)

### Summary

- **Regression Discontinuity** exploits a cutoff in a running variable to identify causal effects, by comparing observations just on either side of the threshold where treatment is effectively randomly assigned
- Use `rdrobust` for data-driven bandwidth selection and bias-corrected local polynomial estimation, but always check sensitivity to bandwidth choice and never use polynomials above second order
