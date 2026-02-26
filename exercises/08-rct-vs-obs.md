---
layout: exercise
topic: Research design
title: RCT vs Observational Study
language: Stata
---

These exercises are meant to be done alongside the Identification and DAGs lectures.

This exercise compares an observational DGP to a randomized design in a different context than the lecture notes, and uses repetition to show sampling variation.

### Tasks

#### 1) Write a single .do file with clear sections

Create a `.do` file with these sections:

- `**# 0 - setup`  
- `**# 1 - functions and settings`  
- `**# 2 - observational vs randomized: repeated simulation`  
- `**# 3 - summary and interpretation`  

#### 2) Fix the outcome model (same in both designs)

Use these constants (you can store them as locals):

- `N = 1000` observations per replication  
- `R = 200` replications  
- True causal effect of training on wage: **1.0**  

Outcome model (ensure nonnegative):

- `ability ~ Normal(0,1)`  
- `eps ~ Normal(0,2)`  
- `wage_lat = 5 + 1.0*train + 2*ability + eps`  
- `wage = max(wage_lat, 0)`

#### 3) Observational design (confounded assignment)

In each replication:

1. Generate `ability` and noise.  
2. Assign training using a probability that depends on ability:

- `p_train = invlogit(-0.2 + 1.0*ability)`  
- `train = (runiform() < p_train)`

3. Compute the naive difference in mean wage between trained and not trained. Store it in `diff_obs[r]`.

#### 4) Randomized design (RCT assignment)

In each replication:

1. Generate a fresh sample (new `ability`, new noise).  
2. Randomize training:

- `train = (runiform() < 0.5)`

3. Compute the naive difference in mean wage. Store it in `diff_rct[r]`.

#### 5) Summarize the two distributions of estimates

After all replications, report for each design:

- mean of the naive estimates  
- standard deviation of the naive estimates  
- min and max of the naive estimates

You can store results in a dataset with two variables:

- `diff_obs` (length R)  
- `diff_rct` (length R)

Then use `summarize` on each.

#### 6) Interpretation (write as comments in your .do file)

Answer:

1. Which design produces an average estimate closer to the true effect (1.0), and why?  
2. Which design shows more variation across replications? Why might that be?  
3. In the observational design, what is the source of bias?
