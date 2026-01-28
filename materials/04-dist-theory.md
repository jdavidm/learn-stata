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
- **English letters with bars** (like \(\bar{x}\)) = statistics you compute from data (e.g., the sample mean)  
- **Greek letters** (like \(\mu\)) = the truth in the theoretical distribution (e.g., the true population mean)  
- **Greek letter with a hat** (\(\hat{\mu}\)) = your estimate of the truth  

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

> Do [Exercise 7 - Percentiles]({{ site.baseurl }}/exercises/04-percent/)


### Hypothesis testing in five steps (one-sample mean test)

Now use the same five steps the book lays out, but in a simplified form and **implemented in Stata**.

Goal: test a hypothesis about the **mean** of a variable using a one-sample t-test.

We’ll use `ttl_exp` again and test:

> Null hypothesis: the mean total work experience is 10 years.

You can change “10” later if you prefer a different number.

#### Step 1: State the hypotheses

Explain to students:

- We want to test whether the **true average** work experience in the population (\(\mu\)) could reasonably be 10 years.

Write this on the board and in code comments:

- \(H_0\): \(\mu = 10\) (the mean total work experience is 10 years)  
- \(H_1\): \(\mu \neq 10\) (the mean total work experience is not 10 years)

```stata
* Step 1: State hypotheses
* H0: mean(ttl_exp) = 10
* H1: mean(ttl_exp) != 10
```

#### Step 2: Choose a test statistic with a known theoretical distribution

Explain in words:

- We need a statistic whose **theoretical distribution** we know under the null.
- For a mean, the usual choice is a **t-statistic**:
  - (sample mean – hypothesized mean) / standard error
- For large samples, this t distribution is very close to a normal distribution.

In Stata, we’ll use the `ttest` command, which computes this test statistic and knows its theoretical distribution.

```stata
* Step 2: We will use a one-sample t-test
* Test statistic: t = (mean(ttl_exp) - 10) / SE(mean)
```

You don’t need to write formulas in code; just say that `ttest` is doing this for us.

#### Step 3: Compute the test statistic in the data

Run the test in Stata:

```stata
* Step 3: Compute the test statistic using the data
ttest ttl_exp == 10
```

Show them the output:

- Stata reports:
  - The **sample mean** of `ttl_exp`
  - The **standard error** of the mean
  - The **t statistic**
  - The **degrees of freedom**
  - The **p-value** (for different alternatives)

Highlight: the t-statistic here is our **test statistic**, and its **theoretical distribution** under \(H_0\) is a t distribution with \(N-1\) degrees of freedom.

#### Step 4: Use the theoretical distribution to get a p-value

Connect back to the book:

- Under \(H_0: \mu = 10\), the t-statistic follows a **t-distribution**.
- We ask: *How likely is it to get a t-statistic this extreme (or more extreme) if \(H_0\) were true?*
- That probability is the **p-value**.

In Stata’s output:

- Look at the line labeled something like `Pr(|T| > |t|)` for the two-sided p-value.

Explain:

- Small p-value → our observed mean is **unlikely** if the true mean were 10.
- Large p-value → our observed mean is **plausible** under \(H_0\).

You can point at the specific p-value in the output and read it out.

#### Step 5: Decide whether to reject the null hypothesis

Explain the decision rule:

- We pick a threshold \(\alpha\) (often 0.05).
- If p-value < \(\alpha\), we **reject \(H_0\)**.
- If p-value ≥ \(\alpha\), we **do not reject \(H_0\)**.

Write this in the do-file as comments:

```stata
* Step 5: Decision
* If p-value < 0.05, reject H0 that mean(ttl_exp) = 10.
* If p-value >= 0.05, do not reject H0.
```

Then interpret in words (you’ll fill in based on the actual output in class):

> At the 5% significance level, we (do / do not) reject the hypothesis that the mean total work experience is 10 years.  
> This means that our sample provides (evidence / no strong evidence) that the true mean differs from 10.

Emphasize the book’s key message:

- Hypothesis testing is about whether our **observed data** are plausible under a given **theoretical distribution**.
- A statistically significant result means:
  - “This set of data would be unlikely if that theoretical distribution were true.”
- It does **not** mean:
  - “Our model is true,” or
  - “The result is important in the real world.”

---

### Summary to tell students

Wrap up the lecture by connecting all three pieces:

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

Tell them that in upcoming weeks, you’ll use these tools (distributions and hypothesis tests) as building blocks for more complicated models and causal questions.

