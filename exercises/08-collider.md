---
layout: exercise
topic: Research design
title: Collider Bias Simulation
language: Stata
---

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
