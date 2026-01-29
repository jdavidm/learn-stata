---
layout: exercise
topic: Hypothesis Testing
title: Hypothesis Testing
language: Stata
---

Using the `nlsw88` data and the variable `ttl_exp` (total years of work experience), this exercise walks you through the **five steps of hypothesis testing** from the *Creating Theoretical Distributions* lecture.

Work in a **do-file**, and include comments so you can remember what you did when you come back later.

---

## Setup

Start your do-file with:

```stata
* load national longitudinal survey of young women
    sysuse              nlsw88, clear
```

We will test a hypothesis about the **mean** of `ttl_exp`.

---

## 1. State the hypotheses

In the lecture, we considered the question:

> Is the **true average** total work experience in this population equal to 12.3 years?

1. In a comment in your do-file (and in your notes), write the null and alternative hypotheses:

   - \(H_0: \mu = 12.3\)  
   - \(H_1: \mu 
eq 12.3\)

2. Briefly explain in words what each hypothesis says about the population of women in `nlsw88`.

---

## 2. Compute the sample mean and standard deviation

1. Use `sum` to get basic summary statistics for `ttl_exp`:

    ```stata
    sum                 ttl_exp
    ```

2. From this output, record:

   1. The sample size \(N\)  
   2. The sample mean of `ttl_exp`  
   3. The sample standard deviation of `ttl_exp`

3. Using Stata’s stored results from `sum`, compute the **standard error of the mean**:

    ```stata
    sum                 ttl_exp
    display             "N = " r(N)
    display             "Mean ttl_exp = " r(mean)
    display             "SD ttl_exp = " r(sd)

* standard error of the mean
    scalar              se_mean = r(sd)/sqrt(r(N))
    display             "SE of mean ttl_exp = " se_mean
    ```

4. In your notes, write down the value of the standard error and what it represents.

---

## 3. Compute the t-statistic two ways

### 3.1 Manually using the formula

The t-statistic for testing \(H_0: \mu = 12.3\) is:

\[
t = \frac{\bar{x} - 12.3}{\text{SE}(\bar{x})}
\]

1. Use Stata to compute this t-statistic by hand:

    ```stata
* store the sample mean in a scalar
    sum                 ttl_exp
    scalar              mean_ttl = r(mean)
    scalar              se_mean  = r(sd)/sqrt(r(N))

* compute t-statistic for H0: mu = 12.3
    scalar              t_manual = (mean_ttl - 12.3)/se_mean
    display             "Manual t-statistic = " t_manual
    ```

2. Write the value of `t_manual` in your notes.

### 3.2 Using Stata’s built-in `ttest`

Now use Stata’s built-in one-sample t-test:

```stata
ttest                   ttl_exp == 12.3
```

1. From the output, find the t-statistic reported by Stata.

2. Compare it to your manually computed `t_manual`. Are they the same (up to rounding)?

3. Also note the **degrees of freedom** reported. How is this related to the sample size \(N\)?

---

## 4. Find and interpret the p-value

In the `ttest` output, Stata reports three different p-values:

- `Pr(T < t)` for the one-sided test \(H_1: \mu < 12.3\)  
- `Pr(|T| > |t|)` for the **two-sided** test \(H_1: \mu 
eq 12.3\)  
- `Pr(T > t)` for the one-sided test \(H_1: \mu > 12.3\)

1. For this exercise, we focus on the **two-sided** test \(H_1: \mu 
eq 12.3\).

   - Write down the value of `Pr(|T| > |t|)` from the output.

2. Suppose we choose a significance level of \(lpha = 0.05\).

   - Is the p-value **less than** or **greater than** 0.05?
   - Based on this, do we **reject** or **fail to reject** the null hypothesis \(H_0: \mu = 12.3\)?

3. In 2–3 sentences, explain in plain language what this decision means.  
   Your explanation should mention:

   - Whether the observed sample mean is “unlikely” under the null.
   - Whether the data provide evidence that the true mean total work experience differs from 12.3 years.

---

## 5. One-sided vs two-sided alternatives (thinking question)

This final part is more conceptual. No new code is needed.

1. Look again at the `ttest` output and find the one-sided p-values:

   - `Pr(T > t)` for \(H_1: \mu > 12.3\)  
   - `Pr(T < t)` for \(H_1: \mu < 12.3\)

2. Which one-sided test (greater than or less than) is more consistent with the direction of the sample mean relative to 12.3?

3. If an applied researcher was specifically interested in testing whether the mean total work experience is **greater than** 12.3 years, which p-value should they use, and why?

Write a short paragraph (3–4 sentences) in your notes that answers these questions and connects the direction of the alternative hypothesis to the choice of p-value.

---

By the end of this exercise, you should be comfortable:

- Writing down null and alternative hypotheses about a mean,
- Computing the t-statistic both manually and with `ttest`,
- Finding and interpreting p-values,
- And making a clear decision about whether to reject a null hypothesis.
