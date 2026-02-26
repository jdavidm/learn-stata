---
layout: exercise
topic: Research design
title: RCT vs Observational Study
language: Stata
---

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
