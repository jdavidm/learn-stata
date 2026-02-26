---
layout: exercise
topic: Research design
title: Conditioning on a Confounder
language: Stata
---

These exercises are meant to be done alongside the Identification and DAGs lectures.

This exercise focuses on conditioning to reduce confounding, but using a different story and variables than the lecture’s fertilizer example.

### Tasks

#### 1) Simulate a confounded DGP (do not copy the lecture code)

1. Set `seed` to `314159` and create **4,000** observations.

2. Generate:

- `ability` ~ Normal(0, 1)

3. Treatment assignment (different from the lecture):

- Create a probability of training that depends on ability and a second factor `motivation`:

  - `motivation` ~ Normal(0, 1)  
  - `p_train = invlogit(-0.5 + 0.9*ability + 0.6*motivation)`  
  - `train = (runiform() < p_train)`

4. Outcome (ensure nonnegative):

- Let the true causal effect of training be **+1.5**.  
- Let both `ability` and `motivation` affect wages.  
- Add noise and truncate at 0:

  - `wage_lat = 8 + 1.5*train + 3*ability + 2*motivation + eps`  
  - `eps` ~ Normal(0, 2)  
  - `wage = max(wage_lat, 0)`

Label `train` with values `0 "no training"` and `1 "training"`.

#### 2) Start with the naive comparison

1. Report mean wage by training status with:

- `tabstat wage, by(train) stat(mean n)`

2. Compute the naive difference in means manually using `summarize, meanonly`:

- store mean wage for `train==0` in scalar `w0`  
- store mean wage for `train==1` in scalar `w1`  
- display `w1 - w0` with a formatted display statement

#### 3) Condition using two different strategies

You will compare two ways of “holding ability fixed.”

**Strategy A: quartiles of ability**

1. Create `ability_q4` using:

- `xtile ability_q4 = ability, nq(4)`

2. Use `tabstat` to report mean wage by `train` within `ability_q4`.

3. In a loop over quartiles, compute and display the within-quartile difference in mean wage (train − no train). Your output should have one line per quartile.

**Strategy B: strata by training propensity**

1. Create a binary indicator for “high propensity to train”:

- `high_p = (p_train > 0.5)`

2. Compute mean wage by `train` within `high_p` (two strata: high propensity vs low propensity).

3. Compare how much the train/no-train wage gap changes between low and high propensity strata.

#### 4) Interpretation (write as comments in your .do file)

Answer in 3–6 sentences:

1. Why is the naive wage gap biased in this DGP?  
2. Which conditioning strategy seems to reduce the bias more: conditioning on `ability_q4`, or conditioning on `high_p`?  
3. In this DGP, what variables are acting like confounders?
