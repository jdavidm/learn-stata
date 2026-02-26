---
layout: exercise
topic: Causal Effects
title: Simulating a Confounded DGP
language: Stata
---

**Goal:** Practice simulating a confounded DGP and diagnosing bias, but in a new setting (not fertilizer/soil/yield).

In the lecture notes, the example uses soil quality as a confounder of fertilizer and yield. This exercise asks you to build a similar *structure* in a different story so you have to translate ideas into new variable names and a new treatment assignment rule. fileciteturn6file0

### Setup

1. Create a new `.do` file with a proper preamble and a setup section (`**# 0 - setup`), following the house style.

### Tasks

#### 1) Simulate a confounded training DGP

In a new section `**# 1 - confounded training DGP`:

1. Set the random seed to `24601` and simulate **3,000** observations.

2. Generate an unobserved confounder:

- `ability` ~ Normal(0, 1)

3. Generate treatment (training) using a *probability rule* (not a threshold rule):

- Create a training probability that increases with ability:  

  `p_train = invlogit(-0.2 + 1.0*ability)`

- Then assign training as a Bernoulli draw:

  `train = (runiform() < p_train)`

4. Generate wages so they are never negative:

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
