---
layout: exercise
topic: Research design
title: Applying DAG Reasoning
language: Stata
---

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
