---
layout: exercise
topic: Causal Effects
title: Simulating a Confounded DGP
language: Stata
---

In this exercise we are going to practice simulating a confounded DGP and diagnosing bia. In your `.do` file:
- Set the random seed to `24601` and simulate 30,000 observations.
- Generate an unobserved confounder called `ability` that is distributed Normal(0, 1)
- Generate a variable called `p_train` using a probability rule (`invlogit`) that increases with ability: `-0.2 + 1.0*ability`
- Then assign training as a Bernoulli draw `train = (runiform() < p_train)`
- Generate wages so they are never negative:

- Let the true causal effect of training be **+2** (by construction).  
- Let ability also raise wages.  
- Add noise.  
- Enforce `wage >= 0` by truncating at 0.

One acceptable structure is:

- `wage_lat = 10 + 2*train + 4*ability + eps`  
- `wage = max(wage_lat, 0)`  

Use `eps ~ Normal(0, 3)` so there is meaningful noise.

5. Add variable labels and value labels for `train` (0/1).

#### 2) Compute the naive difference in means

In a new section `**# 2 - naive diff-in-means`:

1. Use `tabstat` to show mean wage by training status.

2. Compute the naive difference in means *manually* using `summarize, meanonly`:

- store mean wage for `train==0` in scalar `w0`  
- store mean wage for `train==1` in scalar `w1`  
- display `w1 - w0` with a formatted display statement

#### 3) Show that selection is happening

In a new section `**# 3 - evidence of selection (confounding)`:

1. Show that `ability` differs by training status:

- report mean `ability` by `train` (use `tabstat` or `summarize` with `if`)  

2. In 1–2 sentences (as comments in the `.do` file), explain why this implies the naive wage difference mixes:

- the causal effect of training  
- selection due to ability

#### 4) Conditional comparison within ability groups

In a new section `**# 4 - conditional means within ability bins`:

1. Create ability quartiles:

- `xtile ability_q4 = ability, nq(4)`

2. Compute mean wage by training status within each ability quartile using `tabstat` with `by(train ability_q4)`.

3. Optional (recommended): pick one quartile (e.g., `ability_q4==2`) and make a bar chart of mean wage by training status in that quartile.

### Deliverables

At the end of your `.do` file (in a comment-only block), write short answers:

1. What is the true causal effect of training on wage in your DGP?  
2. Is the naive difference in mean wage close to that true effect? Why or why not?  
3. Do the within-ability comparisons move you closer to the true effect? Explain in words.
