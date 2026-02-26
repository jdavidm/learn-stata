---
layout: page
element: exercises
title: Week 8 – Research Design, Identification, and DAGs
language: Stata
---

These exercises are meant to be done alongside the **Identification** and **DAGs** lectures. All code should follow our **house style** (preamble, headings, comments, aligned commands).

Unless otherwise stated:

- Start from a clean session (`clear all`)  
- Run your `project.do` to set paths and open a log  
- Keep your simulation code in a single `.do` file for this week’s assignment

---

## Exercise 1 – Simulating a Confounded DGP

**Goal:** Practice simulating a DGP with **confounding** and comparing the true causal effect to a naive difference in means.

### Tasks

1. Create a new `.do` file with a proper preamble and a **setup** section (`**# 0 - setup`), following the house style.

2. In a new section `**# 1 - confounded DGP`:

   - Set the random seed to `12345`.  
   - Simulate 2,000 observations.  
   - Generate:
     - `soil_q` ~ Normal(0, 1)  
     - `fert_latent = 0.5*soil_q + e`, where `e` is normal noise  
     - `fert = 1` if `fert_latent > 0`, 0 otherwise  
     - `yield = 0.5*fert + 1*soil_q + eps`, with `eps` normal noise  

3. Use `tabstat` or `summarize` to compute the **naive difference in mean yield** between `fert == 1` and `fert == 0`. Store the two means in scalars and **display** the difference with a clear text message.

4. In comments under the code, write:

   - The *true* causal effect of fertilizer (from the DGP)  
   - The naive difference in means you obtained  
   - A one–two sentence explanation of why they differ, referencing **soil quality as a confounder**.

---

## Exercise 2 – Conditioning on a Confounder

**Goal:** See how **conditioning** on a confounder brings you closer to the true causal effect.

### Tasks

Continuing from Exercise 1 (you may reuse the same simulated data, or re-simulate with the same DGP):

1. Create soil quality quartiles using `xtile`:

   - `soil_q4` with `nq(4)` and descriptive value labels.

2. For each soil quartile:

   - Use `tabstat` to compute mean `yield` for `fert == 1` and `fert == 0`.  
   - In a loop, compute and `display` the difference in means for each quartile.

3. Pick one “middle” quartile (e.g., `soil_q4 == 2` or `3`):

   - Make a `graph bar (mean) yield, over(fert) if soil_q4 == <chosen>`  
   - Give the graph a clear title.

4. In comments:

   - Which is closer to the true causal effect of 0.5: the naive difference for the full sample, or the within-quartile differences?  
   - Why does conditioning on `soil_q` help, in terms of the DAG?

---

## Exercise 3 – RCT vs Observational Study

**Goal:** Compare an observational DGP (confounded) and an RCT DGP (randomized).

### Tasks

1. Create two sub-sections:

   - `**## 1.1 observational DGP`  
   - `**## 1.2 randomized DGP`

2. For **observational**, reuse the confounded fertilizer DGP.

   - Compute naive diff in mean `yield` by `fert`. Store in `diff_obs`.

3. For **randomized**:

   - Simulate 2,000 obs  
   - `soil_q` ~ Normal(0,1)  
   - `fert` randomized 50/50 independent of `soil_q`  
   - `yield = 0.5*fert + 1*soil_q + eps`  
   - Compute naive diff in mean `yield` by `fert`. Store in `diff_rct`.

4. Display:

```stata
    display         "True effect: 0.5"
    display         "Observational diff: " diff_obs
    display         "Randomized diff:    " diff_rct
```

5. In comments, explain why `diff_rct` is valid (design breaks soil→fert link), and why `diff_obs` is biased.

---

## Exercise 4 – Drawing DAGs for Simple DGPs

**Goal:** Translate stories into DAGs and connect them to your simulated variables.

### Tasks

1. Draw DAGs (paper/tablet) for:

   a. Fertilizer: soil quality, fertilizer, yield  
   b. Training: prior education, training, skills, wages  
   c. Selection: treatment, outcome, selection into sample  

2. For each DAG, identify:

   - Confounders (if any)  
   - Colliders (if any)  
   - Mediators (if any)  

3. In your `.do` file add a comment-only section describing arrows and roles.

4. For DAG (a), state which variable(s) you would condition on to identify the effect of fertilizer on yield.

---

## Exercise 5 – Collider Bias Simulation

**Goal:** See how conditioning on a collider creates spurious associations.

### Tasks

1. Simulate 5,000 obs with:

   - `T` ~ Bernoulli(0.5)  
   - `Y` ~ Normal(0,1) independent of `T`  
   - `S` depends on both `T` and `Y` via a latent index

2. Compute `corr T Y`:

   - In full sample  
   - In `if S == 1`  
   - (Optional) in `if S == 0`

3. Display results with clear labels.

4. In comments, explain collider bias using the path `T → S ← Y`.

---

## Exercise 6 – Mediation and Conditional Means

**Goal:** Distinguish total vs direct effects using conditional means.

### Tasks

1. Simulate 3,000 obs with:

   - `train` randomized (50%)  
   - `skills = 1.0*train + noise`  
   - `wage = 0.2*train + 0.8*skills + noise`

2. Compute:

   - Total effect: diff in mean wage by train  
   - Effect on mediator: diff in mean skills by train

3. Create `skills_q4` and compute mean wage by training within each quartile.

4. In comments, compare:

   - Total effect vs within-skills effect  
   - Which corresponds to direct effect (~0.2) and why conditioning on mediator blocks the indirect path.

---

## Exercise 7 – Applying DAG Reasoning to Ethiopia Data

**Goal:** Practice DAG thinking on real data (no regressions yet).

### Tasks

1. Load `eth_allrounds_final.dta` (using your project paths).

2. Choose a treatment–outcome pair, e.g.:

   - irrigation (`irr`) → yield (`yield_kg`)  
   - fertilizer use (`fert_any`) → yield (`yield_kg`)  

3. Draw a DAG with:

   - `T` and `Y`  
   - at least 2 plausible confounders  
   - one plausible mediator or collider

4. In Stata:

   - Compute mean `Y` by `T` using `tabstat` and `graph bar`  
   - Choose 1–2 confounders, bin with `xtile`, and compute conditional means of `Y` by `T` within bins

5. In comments:

   - Describe your DAG, label confounders/mediators/colliders  
   - Explain why the naive difference might be biased and how next week’s regression could implement the adjustment set.

---

## Exercise 8 – Build Your Own Tiny DGP (capstone)

**Goal:** Create your own story → DAG → DGP → simulation → compare naive vs adjusted estimates.

### Tasks

1. Choose a story with `T`, `Y`, and 1–2 additional variables.

2. Draw the DAG and write the DGP in words.

3. Simulate data in Stata encoding clear causal coefficients.

4. Compute:

   - naive diff-in-means of `Y` by `T`  
   - an adjusted comparison consistent with your DAG (e.g., within-strata)

5. In comments:

   - state the true causal effect  
   - compare naive vs adjusted estimates  
   - explain results using DAG language.
