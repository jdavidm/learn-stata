---
layout: page
element: notes
title: Causal Diagrams (DAGs) and Stata Simulations
language: Stata
---

In this lecture we introduce causal diagrams (directed acyclic graphs, or DAGs) and connect them to the simulations and identification ideas from the previous lecture.

This lecture focuses on:

- What DAGs are and what arrows mean  
- Three structures you should recognize: confounders, colliders, and mediators  
- Using Stata simulations to see how conditioning choices change associations  

Primary reading:

- https://theeffectbook.net/ch-CausalDiagrams.html  
- https://theeffectbook.net/ch-Identification.html  

### What is a DAG?

A directed acyclic graph (DAG) is:

- A set of nodes (variables)  
- Connected by directed arrows (causal relationships)  
- With no cycles (you can’t follow arrows and return to the start)

Example:

```text
fert   →  yield
soil_q →  fert
soil_q →  yield
```

A DAG is a picture of the DGP: it’s a way to write down assumptions about what causes what.

### Three key structures

#### Confounder

```text
C → T → Y
C → Y
```

- `C` is a common cause of treatment `T` and outcome `Y`  
- If you don’t adjust for `C`, the association between `T` and `Y` is confounded  

Rule of thumb: you typically adjust for confounders.

#### Mediator

```text
T → M → Y
T → Y
```

- `M` lies on a causal path from `T` to `Y`  
- Adjusting for `M` blocks the indirect effect through `M`

Rule of thumb:

- For the total effect, typically do not adjust for mediators  
- For the direct effect, you do adjust for mediators

#### Collider

```text
T → C ← Y
```

- `C` is a common effect of `T` and `Y`  
- Conditioning on `C` can create a spurious association between `T` and `Y`

Rule of thumb: avoid adjusting for colliders.

> Do [Exercise 4 - Drawing DAGs for Simple DGPs]({{ site.baseurl }}/exercises/08-draw-dags/)

### Confounding revisited (code)

We return to the fertilizer example from the identification lecture:

```stata
* simulate confounded DGP
    clear all
    set             seed 12345
    set             obs 2000

    gen             soil_q = rnormal(0, 1)
    gen             fert_latent = 0.5*soil_q + rnormal(0, 1)
    gen             fert = (fert_latent > 0)

    gen             eps = rnormal(0, 1)
    gen             yield = 0.5*fert + 1*soil_q + eps
```

#### DAG reasoning

- Backdoor path: `fert ← soil_q → yield`  
- Conditioning on `soil_q` blocks that path  

### Collider bias simulation

DAG:

```text
T → S ← Y
```

Simulate:

```stata
* simulate collider DGP
    clear all
    set             seed 2468
    set             obs 5000

* T and Y independent in the population
    gen             T = (runiform() < 0.5)
    gen             Y = rnormal(0, 1)

* selection depends on both T and Y
    gen             s_latent = -0.3 + 0.7*T + 0.7*Y + rnormal(0, 1)
    gen             S = (s_latent > 0)

* check independence in full population
    corr            T Y

* conditioning on collider (selection)
    corr            T Y if S == 1
```

> Do [Exercise 5 - Collider Bias Simulation]({{ site.baseurl }}/exercises/08-collider/)

### Mediation simulation: total vs direct effects

DAG:

```text
train  →  skills  →  wage
train  →  wage
```

Simulate:

```stata
* simulate mediation DGP
    clear all
    set             seed 1357
    set             obs 3000

    gen             train = (runiform() < 0.5)

    gen             u_s = rnormal(0, 1)
    gen             skills = 1.0*train + u_s

    gen             u_w = rnormal(0, 1)
    gen             wage = 0.2*train + 0.8*skills + u_w

* total effect
    tabstat         wage, by(train) stat(mean n)

* effect on mediator
    tabstat         skills, by(train) stat(mean n)

* approximate direct effect by comparing within skills bins
    xtile           skills_q4 = skills, nq(4)
    tabstat         wage, by(train skills_q4) stat(mean n)
```

> Do [Exercise 6 - Mediation and Conditional Means]({{ site.baseurl }}/exercises/08-mediation/)

### Using DAGs to choose adjustment sets

A simple workflow:

1. Draw a DAG for your question  
2. Identify confounders, mediators, and colliders  
3. Decide what effect you want (total vs direct)  
4. Choose an adjustment strategy consistent with the DAG  

This week, we implement these ideas with simulation and conditional means. Next week, regression will implement adjustment sets more directly.

> Do [Exercise 7 - Applying DAG Reasoning]({{ site.baseurl }}/exercises/08-apply-dag/)

### Looking ahead

The mindset shift we want:

> When you open Stata, don’t immediately think “What command do I run?”  
> First think “What does my DAG / DGP look like? Where is the identifying variation coming from?”  
> Then choose commands that match that design.
