---
layout: exercise
topic: Research design
title: Simulating a Confounded DGP
language: Stata
---

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
