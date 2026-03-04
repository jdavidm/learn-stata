---
layout: exercise
topic: Research Design
title: RCT vs Observational Study
language: Stata
---

This exercise builds directly on Exercise 1 and 2. You already created an *observational* training variable `train` that is **confounded by unobserved ability**, and you saw how conditioning on ability reduces bias. Now you will create a **randomized version of the training assignment** inside the same dataset, generate the corresponding RCT outcome, and compare the naive estimates from the *observational* data.

Before starting this exercise, you should have the dataset in memory from Exercises 1 and 2 that includes: `ability`, `p_train`, `train`, `eps`, `wage_lat`, `wage`, and `ability_q4`. If you don’t, re-run your `.do` file so that it runs Exercises 1 and 2 first.

Start by adding an RCT treatment assignment to your existing data. To make the comparison clean, we will set the RCT treatment probability to match the *observed* training rate in your observational data. To do this:
- Use `egen` to compute the share trained individuals in the observational data: `p_rct = mean(train)`
- Create a variable (`u_rct`) and is a random variable with a uniform distribution (`runiform()`)
- Create `train_rct` so that it takes a value of 1 if the value of `u_rct` is below the value of `p_rct` (the mean training value in the observational data) and 0 if `u_rct` is greater than `p_rct`
- Add variable and value labels

Now, generate the RCT outcome using the same outcome model. Keep the *same structural outcome equation* you used in Exercise 1, but swap in `train_rct`:
- `wage_rct_lat = 10 + 2*train_rct + 4*ability + eps`
- `wage_rct     = max(wage_rct_lat, 0)`
- Add variable labels so your output is easy to read.

1\. Compare naive differences in means: observational vs RCT
- Observational estimate (you did this in Exercise 1): $E[wage \mid train=1] - E[wage \mid train=0]$
- RCT estimate: $E[wage\_rct \mid train\_rct=1] - E[wage\_rct \mid train\_rct=0]$

Use `sum, meanonly`, use `r()` to store group means as `scalar`, and display the differences with a formatted `display` statement. What is the naive mean in the observational data, in the rct data, and what is the true causal effect size (again, some of these you have already calculated or know)?

2\. Show why the observational estimate is biased by demonstrating selection in the observational data (i.e., `ability` differs by training status). If there is no selection, mean values should be close to 0 adn the differences in ability by training should also be close to zero. Use `tabstat` (recommended) or `summarize` with `if`.
    1\. What is mean `ability` by `train`?
    2\. What is the difference in mean `ability` by `train`?
    3\. What is mean `ability` by `train_rct`? 
    4\. What is the difference in mean `ability` by `train_rct`?

---