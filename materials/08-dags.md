---
layout: page
element: notes
title: Causal Diagrams (DAGs) and Stata Simulations
language: Stata
---

In this lecture we introduce **causal diagrams**—directed acyclic graphs (DAGs)—and connect them to the simulations and identification ideas from the previous lecture. We will
- Define DAGs and basic pieces (nodes, arrows, paths)  
- Introduce **confounders**, **colliders**, and **mediators**  
- Use Stata simulations to show how conditioning on different variables affects associations  
- Connect DAGs back to identification and future regression work

### What is a DAG?

A **directed acyclic graph (DAG)** is:
- A set of nodes (variables)  
- Connected by directed arrows (causal relationships)  
- With no cycles (you can’t follow arrows and return to the start)

Example:

```text
fert  →  yield
soil_q →  fert
soil_q →  yield
```

Interpretation:
- `soil_q` causally affects both fertilizer use and yield  
- `fert` causally affects yield  

A DAG is your **picture of the DGP** (assumptions), not something “proven” by the data.

### Three key structures

#### 1) Confounder

```text
T ← U → Y
```

- `U` is a **common cause** of treatment `T` and outcome `Y`  
- If you don’t adjust for `U`, the association between `T` and `Y` is confounded  

This is what `soil_q` is in our previous example. It is a common cause of both `fert` and `yield`. Rule-of-thumb: you typically **do** adjust for confounders.

### 2) Mediator

```text
T → M → Y
```

- `M` lies on a causal path from `T` to `Y`  
- Adjusting for `M` blocks the indirect effect through `M`

Rule-of-thumb: for the total effect, you typically **do not** adjust for mediators but for the direct effect, you **do** adjust.

### 3) Collider

```text
T → C ← Y
```

- `C` is a **common effect** of `T` and `Y`  
- Conditioning on `C` can *create* a spurious association between `T` and `Y`

Rule-of-thumb: you typically **avoid** adjusting for colliders.

> Do [Exercise 4 - Drawing DAGs for Simple DGPs]({{ site.baseurl }}/exercises/08-draw-dags/)

### Confounding revisited (code)

```stata
* simulate confounded DGP
    clear all
    set             seed 12345
    set             obs 2000

    gen             soil_q = rnormal(0, 1)
    gen             fert_latent = 0.5*soil_q + rnormal(0, 1)
    gen             fert = (fert_latent > 0)

    gen             eps = rnormal(0, 1)
    gen             yield_lat = 2 + 0.5*fert + 1*soil_q + eps
    gen             yield = max(yield_lat, 0)
    drop            yield_lat
```

DAG reasoning:

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

Interpretation:

- In the full sample, `T` and `Y` are (approximately) uncorrelated  
- After restricting to `S==1`, you often see a strong correlation: collider bias

> Do [Exercise 5 - Collider Bias Simulation]({{ site.baseurl }}/exercises/08-collider/)

### Mediation simulation: total vs direct effects

DAG:

```text
train → skills → wage
train → wage
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
    gen             wage_lat = 5 + 0.2*train + 0.8*skills + u_w
    gen             wage = max(wage_lat, 0)
    drop            wage_lat

* total effect
    tabstat         wage, by(train) stat(mean n)

* effect on mediator
    tabstat         skills, by(train) stat(mean n)

* approximate direct effect by comparing within skills bins
    xtile           skills_q4 = skills, nq(4)
    forvalues        q = 1/4 {
        di as text "skills_q4 == `q'"
        tabstat         wage if skills_q4 == `q', by(train) stat(mean n)
    }
```

Interpretation:

- Difference in mean wage by training is the **total effect**  
- Within-skills comparisons approximate the **direct effect** (holding mediator fixed)

> Do [Exercise 6 - Mediation and Conditional Means]({{ site.baseurl }}/exercises/08-mediation/)

## Using DAGs to choose adjustment sets

Practical workflow:

1. Draw a DAG for your question  
2. Identify confounders, mediators, colliders  
3. Decide what effect you want (total vs direct)  
4. Choose an adjustment strategy consistent with the DAG  

This week we implement ideas with simulation + conditional means. Next week regression will implement adjustment sets more directly.
