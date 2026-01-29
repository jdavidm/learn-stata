---
layout: exercise
topic: Hypothesis Testing
title: Hypothesis Testing
language: Stata
---

Using the `nlsw88` data, this exercise asks you to *apply* the five-step hypothesis testing procedure from the **Creating Theoretical Distributions** lecture to **new variables and new hypotheses**.

Work in a **do-file**, and include comments so you can remember what you did when you come back later.

```stata
* load national longitudinal survey of young women
    sysuse              nlsw88, clear
```

---

1. **Test whether women work 40 hours per week on average**

   The variable `hours` records usual hours worked per week.

   1. Use `sum hours` to find the **sample mean**, **standard deviation**, and **sample size**.
   2. In your do-file and notes, write down the hypotheses for testing whether women work 40 hours per week on average:
      - \(H_0: \mu = 40\)
      - \(H_1: \mu \neq 40\)
   3. Use `ttest` to perform a one-sample t-test of this hypothesis.
      - Report: the sample mean of `hours`, the t-statistic, the degrees of freedom, and the **two-sided p-value**.
   4. At the 5% significance level, do you **reject** or **fail to reject** the null hypothesis that women work 40 hours per week on average?
   5. In 2–3 sentences, interpret your result in plain language. Your explanation should mention whether 40 hours per week seems **plausible** as the true mean.

---

2. **Hypothesis test for a subgroup: college graduates’ wages**

   Now we will test a hypothesis about the mean **hourly wage** for **college graduates only**.

   1. Use `tab collgrad` to see how many women are college graduates (`collgrad == 1`).
   2. Use `sum wage if collgrad == 1` to summarize the wages of college graduates.
      - Record the sample size, mean, and standard deviation for this subgroup.
   3. Suppose someone claims that **college graduates in this sample earn $10 per hour on average**. Set up the hypotheses:
      - \(H_0: \mu = 10\)
      - \(H_1: \mu \neq 10\)
   4. Use a one-sample t-test **restricted to college graduates** to test this claim.
      - Report the t-statistic, degrees of freedom, and two-sided p-value.
   5. At the 5% significance level, what is your decision about \(H_0\)?
   6. Write a short paragraph (3–4 sentences) explaining what your results say about wages for college graduates in this sample.

---

3. **Compare two different null hypotheses for the same variable**

   In part 2 you tested whether the mean wage for college graduates is $10. Now you’ll see how the choice of **null value** changes the test.

   1. Pick a **second value** for the null hypothesis about college graduates’ mean wage that you think is **more plausible** than $10 based on your summary statistics (for example, the sample mean rounded to the nearest dollar).
   2. Write down a new set of hypotheses:
      - \(H_0: \mu = a\) (where \(a\) is your new chosen value)
      - \(H_1: \mu \neq a\)
   3. Run a second `ttest` for college graduates using your new null value.
      - Record the t-statistic and two-sided p-value.
   4. Compare the p-values from the two tests (for $10 and for your chosen value):
      - For which null value is the p-value **smaller**?
      - For which null value do the data look **more consistent** with the null?
   5. In 3–4 sentences, explain how changing the null value affects:
      - The size of the t-statistic.
      - The p-value.
      - Your conclusion about the plausibility of the null hypothesis.

---

4. **One-sided vs two-sided alternatives (conceptual)**

   Consider again the college graduates’ wages in part 2.

   1. Look back at your `ttest` output for the null \(H_0: \mu = 10\). Find the **one-sided** p-values:
      - `Pr(T > t)` (for \(H_1: \mu > 10\))
      - `Pr(T < t)` (for \(H_1: \mu < 10\))
   2. Based on the sample mean you found, which one-sided alternative makes more sense to consider?
      - \(H_1: \mu > 10\), or
      - \(H_1: \mu < 10\)?
   3. If a researcher’s question is specifically:
      > “Do college graduates in this sample earn **more than $10 per hour on average**?”
      which p-value should they look at, and why?
   4. Write a short paragraph connecting:
      - The **direction** of the alternative hypothesis.
      - The choice between **one-sided** and **two-sided** p-values.
      - How this shows up in the `ttest` output.

By the end of this exercise, you should be able to:

- Apply the five-step hypothesis testing procedure to **new variables** and **new null values**.
- Understand how changing the null value changes the t-statistic and p-value.
- Distinguish between **two-sided** and **one-sided** alternatives and choose the p-value that matches the research question.
