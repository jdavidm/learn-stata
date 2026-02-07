---
layout: page
element: notes
title: Creating Theoretical Distributions
language: Stata
---

In this lecture, you’ll connect those observed distributions to **theoretical distributions**, and walk through a simple **hypothesis test** using Stata.

The plan:
- Observed vs theoretical distributions
- Simulating data from a theoretical distribution with `rnormal`
- Comparing a real variable to a normal distribution using `nlsw88`
- Using percentiles and tail areas
- Walking through the 5-step hypothesis testing procedure in Stata

### Observed vs theoretical distributions

Our **data** are a finite sample. What we *really* care about is the **theoretical distribution** that generated those data.
- Suppose we collect data on the age kids learn to share.
- We compute a **sample mean** (e.g., 4.2 years).
- But what we care about is the **true mean** age in the population, not just in our sample.

When describing and distinguishing observed and theoretical distributions, we typically use the following notation:
- **English letters** (like `x`) = observed data  
- **English letters with bars** (like $\bar{x}$) = statistics you compute from data (e.g., the sample mean)  
- **Greek letters** (like $\mu$) = the truth in the theoretical distribution (e.g., the true population mean)  
- **Greek letter with a hat** ($\hat{\mu}$) = your estimate of the truth  

The key point is:
- The **theoretical distribution** is the distribution of *everyone*, including people we didn’t sample.  
- Our **observed distribution** (histogram, kernel density) is just what we saw in our finite sample.

### Simulating from a normal theoretical distribution with `rnormal`

When trying to approximate the true distribution with observations, more data is typically better:
- If you only have **1 observation**, your observed distribution is a terrible representation of the theoretical distribution.
- As your **sample size grows**, your observed distribution gets closer to the theoretical distribution.
- In the limit (infinitely many observations), your observed distribution would *match* the theoretical distribution.

To demonstrate this idea, we are going to step away from `nlsw88` for a moment and create fake data that follows a normal distribution. Do to this we can use `rnormal()`, which draws from a **theoretical normal distribution** with mean 0 and sd 1. The variable `x` is our **simulated sample** from that theoretical distribution.

```stata
* start fresh, no data
    clear

* for reproducibility
    set seed        12345

* create a dataset with 1,000 observations
    set obs         1000

* Draw 1,000 observations from a standard normal distribution N(0,1)
    gen             x = rnormal()

* graph the distribution
    kdensity        x
```

#### Create “small-sample” versions

Use the first 10 and first 100 observations to mimic small samples:

```stata
* small sample: first 10 draws
    gen             x10 = x if _n <= 10

* graph n = 10
    kdensity        x10, normal ///
                        title("Sample of size 10 from N(0,1)") ///
                        xtitle("x") ytitle("Density")

* medium sample: first 100 draws
    gen             x100 = x if _n <= 100

* graph n = 100
    kdensity        x100, normal ///
                        title("Sample of size 100 from N(0,1)") ///
                        xtitle("x") ytitle("Density")
```

We can then confirm that all 1,000 observations are close to a normal distribution by adding the `normal` option when graphing the full sample.

```stata
* large sample: full 1000 draws
    gen             x1000 = x if _n <= 1000

* graph n = 1,000
    kdensity        x1000, normal ///
                        title("Sample of size 1000 from N(0,1)") ///
                        xtitle("x") ytitle("Density")
```

- These three variables represent **samples of different sizes** from the same theoretical normal.
- The more observations we have, the better our **observed distribution** approximates the **theoretical distribution** that generated it.
- *Is 1000 always enough?* (Answer: no, but it’s much better than 10.)

### Comparing real data to theoretical distributions

Now let's move back to real data to connect the idea of observed versus theoretical distributions. Load the `nlsw88` data using `sysuse`. Then apply some of our basic workflow for examining a new variable, `ttl_exp`.

```stata
* summarize total years of work experience
    sum             ttl_exp, detail

* look at its distribution
    histogram       ttl_exp, bin(20) percent ///
                        title("Histogram of total work experience")

    kdensity        ttl_exp, ///
                        title("Kernel density of total work experience")
```

- Does `ttl_exp` look **symmetric** or **right-skewed**?
- Are there many workers with low experience and a few with very high experience?

Now create a variable that *does* follow a normal theoretical distribution, with mean and standard deviation matched to `ttl_exp`. To do this, we will use Stata's stored results and save them as a number (scalar) that we can use later.

```stata
* get mean and standard deviation of ttl_exp
    sum             ttl_exp
    scalar          m_ttl = r(mean)
    scalar          s_ttl = r(sd)

* set a seed for reproducibility
    set seed        8675309

* generate a normal variable with same mean and sd as ttl_exp
    gen             ttl_exp_norm = rnormal(m_ttl, s_ttl)
```

What we have is:
- `ttl_exp` = real-world distribution (possibly skewed).
- `ttl_exp_norm` = data simulated from a **normal theoretical distribution** with the *same* mean and sd.
- If work experience truly followed that normal theoretical distribution, the distribution of `ttl_exp` would look like `ttl_exp_norm`.

Now draw kernel density plots of both variables on the same graph:

```stata
* graph observed and theoretical distributions
    twoway          (kdensity ttl_exp_norm, lpattern(solid)) || ///
                        (kdensity ttl_exp, lpattern(dash)), ///
                        title("Normal & observed distributions") ///
                        xtitle("Total work experience (years)") ///
                        ytitle("Density") ///
                        legend(order(1 "Simulated" 2 "Observed"))
```

- The **simulated normal** curve is symmetric and bell-shaped.
- The **observed `ttl_exp`** curve is likely right-skewed (more mass on the left, long tail to the right).

> Do [Exercise 6.1 - 6.2 - Random Numbers]({{ site.baseurl }}/exercises/04-rando/)

### Percentiles and tail areas

In the earlier *Distributions of Variables* lecture, you saw how to use `sum, detail` to get **percentiles** of a variable, including the 5th and 95th percentiles. Those numbers tell us where the **extreme tails** of the distribution begin.
- The **5th percentile** is a value such that 5% of observations are **below** it.
- The **95th percentile** is a value such that 95% of observations are **below** it (so 5% are above it).

Percentiles give us a way to describe the “middle 90%” of the data (between the 5th and 95th percentiles) and the extreme 5% tails on either side. Those tails are exactly the kinds of “rare events” we’ll care about when we do hypothesis testing.

We'll illustrate this using the `wage` variable.
- First we will summarize wage and save the stored values for the 5th and 95th percentile
- Second, we will graph the distribution of wages
- To this graph we will add two vertical lines (`xline`), one at `p5` and the other at `p95`
- We will also set the pattern of the line (`lpattern`) and the color (`lcolor`)

```stata
* get detailed summary of wage
    sum             wage, detail

* save the 5th and 95th percentiles as locals
    local           p5  = r(p5)
    local           p95 = r(p95)

* graph the distribution with percentile cutoffs
    kdensity        wage, ///
                        title("5th and 95th percentiles of wage") ///
                        xtitle("Hourly wage (1988 dollars)") ///
                        ytitle("Density") ///
                        xline(`p5' `p95', lpattern(dash) ///
                        lcolor(maroon))
```

What does this graph show?
- Most of the **area under the curve** lies between the dashed vertical lines at the 5th and 95th percentiles.
- The left-most tail (to the left of the 5th percentile) contains only about **5% of the workers**.
- The center region (between the 5th and 95th percentiles) contains about **90% of the workers**.

The tails are small “rare” regions, and the middle is where most observations lie. When we move to hypothesis testing, we’ll treat events that fall in those small tail regions (like 5% in each tail) as **unlikely under the null**.

> Do [Exercise 7.1 - 7.3 - Percentiles]({{ site.baseurl }}/exercises/04-percent/)


### Hypothesis testing in five steps (one-sample mean test)

This last section of the lecture draws directly from Chapter 3 of [The Effect](https://theeffectbook.net/ch-DescribingVariables.html#theoretical-distributions) that was part of your readings this week. Our **Goal**: test a hypothesis about the mean of a variable using a one-sample t-test. We’ll use `ttl_exp` and test:

> Null hypothesis: the mean total work experience is 10 years.

#### Step 1: State the hypotheses

We want to test whether the **true average** work experience in the population $(\mu)$ could reasonably be 10 years. We can state this in terms of a null and alternative hypothesis:
- $H_0$: $\mu = 12.3$ (the mean total work experience is 12.3 years)  
- $H_1$: $\mu \neq 12.3$ (the mean total work experience is not 12.3 years)

#### Step 2: Choose a test statistic with a known theoretical distribution

We need a statistic whose **theoretical distribution** we know under the null. For testing a difference in means, the usual choice is a **t-statistic**:
$$
\frac{(\text{sample mean} - \text{hypothesized mean})}{\text{standard error}}
$$

For large samples, this t-distribution is very close to a normal distribution.

In Stata, we’ll use the `ttest` command, which computes this test statistic and knows its theoretical distribution.

#### Step 3: Compute the test statistic in the data

Run the test in Stata: `ttest ttl_exp == 12.3`

```stata
One-sample t test
----------------------------------------------------------------------
Variable |   Obs      Mean  Std. err.   Std. dev.   [95% conf. inter.]
---------+------------------------------------------------------------
 ttl_exp | 2,246  12.53498  .0972782    4.610208    12.34421  12.72574
----------------------------------------------------------------------
    mean = mean(ttl_exp)                                  t =   2.4155
H0: mean = 12.3                          Degrees of freedom =     2245

   Ha: mean < 12.3         Ha: mean != 12.3           Ha: mean > 12.3
 Pr(T < t) = 0.9921     Pr(|T| > |t|) = 0.0158      Pr(T > t) = 0.0079 
```

- Stata reports:
  - The **sample mean** of `ttl_exp`
  - The **standard error** of the mean
  - The **t statistic**
  - The **degrees of freedom**
  - The **p-value** (for different alternatives)

#### Step 4: Use the theoretical distribution to get a p-value

Under $H_0: \mu = 12.3$, the t-statistic follows a **t-distribution**.
- We ask: *How likely is it to get a t-statistic this extreme (or more extreme) if $H_0$ were true?*
- That probability is the **p-value**.

In Stata’s output, look at the line labeled something like `Pr(|T| > |t|)`
- Small p-value → our observed mean is **unlikely** if the true mean were 12.3.
- Large p-value → our observed mean is **plausible** under $H_0$.

#### Step 5: Decide whether to reject the null hypothesis

We need a decision rule to tell us *how small is small enough* for us to be confident that the mean of `ttl_exp` is not equal to 12.3.
- We pick a threshold $\alpha$ (often 0.05).
- If p-value < $\alpha$, we **reject $H_0$**.
- If p-value ≥ $\alpha$, we **do not reject $H_0$**.

Looking at the Stata output
- For `Ha: mean > 12.3` (meaning our $H_0: \mu < 12.3$), we reject the hypothesis at the 1% level.
    - In the theoretical distribution, only 1% of observations are smaller and 99% of observations are larger
    - So it is highly likely, given the data we have, that the true mean is greater than 12.3
- For `Ha: mean != 12.3` (meaning our $H_0: \mu != 12.3$), we reject the hypothesis at the 5% level.
    - In the theoretical distribution, 5% of observations are smaller and 95% of observations are larger
    - So it is highly likely, given the data we have, that the true mean is not equal to 12.3
- For `Ha: mean < 12.3` (meaning our $H_0: \mu > 12.3$), we fail to reject the hypothesis at conventional levels.
    - In the theoretical distribution, 99% of observations are smaller and only 1% of observations are larger
    - So it is highly unlikely, given the data we have, that the true mean is less than 12.3

The key message is:
- Hypothesis testing is about whether our **observed data** are plausible under a given **theoretical distribution**.
- A statistically significant result means:
  - “This set of data would be unlikely if that theoretical distribution were true.”
- It does **not** mean:
  - “Our model is true,” or
  - “The result is important in the real world.”

> Do [Exercise 8.1 - 8.2 - Hypothesis Testing]({{ site.baseurl }}/exercises/04-ttest/)

### Summary

1. **Observed vs theoretical distributions**  
   - Our histograms and kernel densities show **observed distributions** from finite samples.
   - Theoretical distributions describe the **truth** if we could see everyone.

2. **Simulation and sample size**  
   - Using `rnormal`, we saw that **small samples** give noisy approximations to the theoretical normal.
   - **Larger samples** give observed distributions that look more like the theoretical distribution.

3. **Normal vs skewed in real data**  
   - `ttl_exp` in `nlsw88` is not perfectly normal; it’s often skewed.
   - A simulated normal with the same mean and sd looked quite different when graphed together with `ttl_exp`.

4. **Hypothesis testing**  
   - We formalized this idea with a 5-step procedure.
   - We used `ttest` to see if our data are consistent with a particular **theoretical mean** \(\mu\).
   - A small p-value means “this data would be rare if that theoretical distribution were true,” so we rule that theoretical distribution out.