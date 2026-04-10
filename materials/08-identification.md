---
layout: page
element: notes
title: Identification, DGPs, and Research Design
language: Stata
---

This week we pivot from describing data to using Stata as a tool for thinking about causal questions and research design. This forms the bridge between representing correlational relationships with tables and figures to estimating causal relationships with regression analysis.

This lecture focuses on:
- What a data generating process (DGP) is  
- What identification means (and why it’s different from association)  
- How simulations and conditional means help you reason about research design before we learn regression  

### The data generating process (DGP)

A data generating process is the (usually hidden) set of rules that create the data we observe.

Examples:

- Gravity is part of the DGP that generates data on falling objects  
- Supply and demand are part of the DGP that generates price/quantity data  
- In economics, preferences, technologies, policies, and constraints are pieces of a DGP  

The DGP is the causal story that created the dataset. We don’t observe that story directly—we only observe the variables it leaves behind. Identification is the problem of deciding when the variation we do observe is enough to pin down the causal effect we care about.

Stata gives us a superpower here: we can simulate data from a DGP we choose, so that we actually know the truth. Then we can see when simple comparisons get the right answer and when they’re biased.

### A simple DGP in Stata: fertilizer, soil, and yield

We’ll simulate a world where:

1. Plots differ in soil quality  
2. Plots with better soil are more likely to adopt fertilizer  
3. Fertilizer increases yield  
4. Soil quality also increases yield  

This is a classic confounding setup: soil quality is a common cause of both fertilizer use and yield.

A simple causal diagram (we’ll formalize these next lecture):

```text
soil_quality  →  fert
soil_quality  →  yield
fert          →  yield
```

#### Simulating the DGP

```stata
* simulate a DGP with confounding
    clear all
    set             seed 12345
    set             obs 2000

* unobserved soil quality (higher is better)
    gen             soil_q = rnormal(0, 1)

* fertilizer adoption: more likely on better plots
    gen             fert_latent = 0.5*soil_q + rnormal(0, 1)
    gen             fert = (fert_latent > 0)
    label           define fertlbl 0 "no fertilizer" 1 "fertilizer"
    label           values fert fertlbl

* true causal effect of fertilizer on yield is 0.5 tons/ha
* soil quality also matters
    gen             eps = rnormal(0, 1)
    gen             yield_lat = 2 + 0.5*fert + 1*soil_q + eps
    gen             yield = max(yield_lat, 0)
    drop            yield_lat
    label           var yield "yield (tons/ha)"

* peek at the data
    sum             soil_q fert yield
```

#### What the DGP implies (before looking at results)

- The true causal effect of fertilizer on yield is 0.5 (by construction)  
- Soil quality affects yield (coefficient 1.0)  
- Fertilizer is not randomly assigned: better soil → more fertilizer  

If you ignore soil quality and just compare mean yield with and without fertilizer, you’re mixing:

- The causal effect of fertilizer  
- Selection: good soil increases fertilizer use and yield  

#### Identification vs raw associations

What happens if we just compare average yield across fertilizer status?

```stata
* naive difference in means
    tabstat         yield, by(fert) stat(mean n)

* compute difference in means manually using stored results
    qui sum         yield if fert == 0, meanonly
    scalar          y0 = r(mean)

    qui sum         yield if fert == 1, meanonly
    scalar          y1 = r(mean)

    display         "Naive diff-in-means (fert - no fert): " %9.3f (y1 - y0)
```

This gives you the association between fertilizer and yield. But it does not have to equal the causal effect (0.5). The gap is bias from confounding by soil quality.

> Do [Exercise 1 - Simulating a Confounded DGP]({{ site.baseurl }}/exercises/08-confounded-dgp/)

### Conditioning to reduce confounding

In this DGP, soil quality is the confounder. There is what is known as a backdoor path `fert ← soil_q → yield`. If we could hold soil quality fixed, we’d block that path (`fert ← [soil_q] → yield`) and be able to identify the causal effect of fertilizer on yield.

We can approximate this by comparing treated and untreated plots within soil quality groups (quartiles):

```stata
* create soil quality quartiles
    xtile           soil_q4 = soil_q, nq(4)
    label           define soilq4 1 "worst soil" 2 "low" 3 "high" 4 "best soil"
    label           values soil_q4 soilq4

* mean yield by fert within each soil quartile
    bysort 			soil_q4 fert: ///
						sum yield
```

#### A simple visual check

```stata
* conditional difference in means in a soil group
    tabstat         yield if soil_q4 == 2, by(fert) stat(mean n)

* graph
    graph bar       (mean) yield if soil_q4 == 2, over(fert) ///
                        ytitle("Mean yield") ///
                        title("Fertilizer vs no fertilizer within soil group 2")
```

> Do [Exercise 2 - Conditioning on a Confounder]({{ site.baseurl }}/exercises/08-conditioning/)

### Variation vs identifying variation

Two ideas:

1. Variation: how a variable changes across observations  
2. Identification: using knowledge of the DGP to isolate variation that reveals the causal effect  

In our simulation:

- There is variation in fertilizer and yield  
- Some variation in fertilizer is driven by soil quality and is not identifying  
- Conditioning on soil quality gets closer to identifying variation  

### Randomized experiments in Stata

Most economists believe that the cleanest research design is randomized treatment assignment:

- Treatment is randomly assigned by the researcher (say via a lottery)  
- By construction, treatment is independent of pre-treatment characteristics  

Here is the same yield model with randomized fertilizer:

```stata
* randomized treatment: fert independent of soil_q
    clear all
    set             seed 9876
    set             obs 2000

    gen             soil_q = rnormal(0, 1)

* randomized fertilizer: 50% treated
    gen             u = runiform()
    gen             fert = (u < 0.5)
    label           define fertlbl 0 "control" 1 "treatment"
    label           values fert fertlbl

* same causal effect and same soil effect (truncate at 0)
    gen             eps = rnormal(0, 1)
    gen             yield_lat = 2 + 0.5*fert + 1*soil_q + eps
    gen             yield = max(yield_lat, 0)
    drop            yield_lat

* naive diff-in-means is now a valid causal estimate
    tabstat         yield, by(fert) stat(mean n)
```

In this world, the true causal effect is still 0.5, and the naive difference in means is a valid estimate (up to sampling noise).

> Do [Exercise 3 - RCT vs Observational Study]({{ site.baseurl }}/exercises/08-rct-vs-obs/)

### Connecting to real data and upcoming topics

In this lecture we practiced:
- Using simulations to make DGPs concrete  
- Seeing how identification depends on research design  
- Using difference-in-means and conditional means to reason about confounding  

Next week, regression with controls will automate conditioning. Later, FE, DiD, event studies, and IV are all about finding identifying variation when simple conditioning isn’t enough.

### Summary

- Identification isolates the precise variation required to infer a causal effect.
- The Data Generating Process (DGP) is the theoretical structural model creating your observed data.
- A solid research design ensures you only estimate the pathway of interest, ignoring confounding variance.
