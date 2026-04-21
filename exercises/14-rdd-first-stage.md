---
layout: exercise
topic: Regression Discontinuity
title: First Stage
language: Stata
---

The Garg et al. (2021) RDD is **fuzzy**: crossing the population threshold increases the *probability* of receiving a road but does not guarantee it. Before running the fuzzy RD, we need to verify that the first stage is strong — that the threshold indicator actually predicts road construction.

- Define a global for the baseline controls:

```stata
* baseline controls
    global      blcontrols primary_school med_center elect ///
                    tdist irr_share ln_land pc01_lit_share ///
                    pc01_sc_share bpl_landed_share ///
                    bpl_inc_source_sub_share bpl_inc_250plus
```

- Run the first-stage regression: regress `receivedroad` on `t left right $blcontrols` using `reghdfe`, with triangular kernel weights `[aw = kernel_tri_ik]`, absorbing `year` and `dist_thresh_id` fixed effects, and clustering standard errors at `village_id`. Store as `fs`.


1\. Use `rdplot` to visualize the first stage. Plot `receivedroad` against `v_pop` with the cutoff at 0. Restrict to `abs(v_pop) <= 250` and use 20 bins per side. Export the figure and import it into your Overleaf document.

2\. What is the coefficient on `t`? Interpret it in words: by how many percentage points does crossing the threshold increase the probability of receiving a road?

3\. Is the first stage strong? Check the F-statistic against the conventional rule-of-thumb threshold of $F > 10$.

---
