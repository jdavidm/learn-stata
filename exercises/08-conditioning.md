---
layout: exercise
topic: Research design
title: Conditioning on a Confounder
language: Stata
---

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
