---
layout: exercise
topic: Research design
title: Mediation and Conditional Means
language: Stata
---

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
