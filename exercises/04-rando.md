---
layout: exercise
topic: Graphing
title: Random Numbers
language: Stata
---

Using the `nlsw88` data,

1\. Simulate and then graph a theoretical log-normal distribution.
   - Start by setting the seed to the same seed that we set when we simulated a normal distribution for `ttl_exp`.
   - Next, create a variable called `wage_norm` that has a normal distribution with mean 1.831 and standard deviation of 0.6615.
   - To make a log-normal distribution, we need to exponentiate `wage_norm` using Stata's built in math function `exp()`. Call this new variable `wage_logn`.
   - Finally, draw the distribution of this new variable using `kdensity`.

2\. Graph `wage` and the log-normal distribution on same graph.
   - Give the graph a descriptive title as well as labelling the x-axis and y-axis.
   - Create a legend and place it below the graph (`pos`) and in two columns (`col`).
   - Label the two lines as "Simulated log-normal" and "Observed wage".
   
---
