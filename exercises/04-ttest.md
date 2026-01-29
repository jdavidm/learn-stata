---
layout: exercise
topic: Hypothesis Testing
title: Hypothesis Testing
language: Stata
---

Using the `nlsw88` data, this exercise asks you to *apply* the five-step hypothesis testing procedure from the **Creating Theoretical Distributions** lecture:

1\. Test whether women work 40 hours per week on average. The variable `hours` records usual hours worked per week.
   - Use `sum` to find the sample mean, standard deviation, and sample size.
   - As a comment in your do-file, write down the hypotheses for testing whether women work 40 hours per week on average:
      - $H_0: \mu = 40$
      - $H_1: \mu \neq 40$
   - Use `ttest` to perform a one-sample t-test of this hypothesis.
    
    1\. What is the sample mean of `hours`?
    2\. What is the t-statistic? 
    3\. How many degrees of freedom are there?
    4\. What is the two-sided p-value?
    5\. At the 5% significance level, do you **reject** or **fail to reject** the null hypothesis that women work 40 hours per week on average?


2\. Now we will test a hypothesis about the mean hourly `wage` for college graduates only.
   - Use `tab` with and without the `nolab` option to determine which numerical value college grade takes.
   - Use `sum` with `if` to summarize the wages of just college graduates.
   - Suppose someone claims that college graduates in this sample earn $10 per hour on average. Set up the hypotheses:
      - $H_0: \mu = 10$
      - $H_1: \mu \neq 10$
   4. Use a one-sample t-test **restricted to college graduates** to test this claim.
      - Report the t-statistic, degrees of freedom, and two-sided p-value.
   5. At the 5% significance level, what is your decision about \(H_0\)?
   6. Write a short paragraph (3–4 sentences) explaining what your results say about wages for college graduates in this sample.
