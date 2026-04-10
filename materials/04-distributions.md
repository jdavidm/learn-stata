---
layout: page
element: notes
title: Distributions of Variables
language: Stata
---

When we collect data, we don’t just care about *individual* observations. We care about what values are common, what’s rare, and what’s extreme.

That’s what a **distribution** is:

> A description of the probability that each possible value of a variable will occur.

In this lecture we will:
- Define what we mean by the distribution of a variable  
- See how to describe distributions with **tables** in Stata  
- Learn how to **summarize** a distribution with a few key numbers (center and spread)

Throughout this lecture we will use the system data set `nlsw88.dta`. So start by loading it using the `sysuse` command. Remember, as we walk through these lectures, you should be taking notes and coding in a `.do` file.

### Distributions of data

Suppose we have a tiny dataset with four observations of exam scores:

- `score = 2, 5, 5, 6`

We can write down the distribution as a table:

| score | count | percent |
|-------|-------|---------|
| 2     | 1     | 25%     |
| 5     | 2     | 50%     |
| 6     | 1     | 25%     |
| **Total** | **4** | **100%** |

This table *is* the distribution:  
- It tells us which values occur (2, 5, 6)  
- And how often (counts and percentages)


### Tabular distributions for categorical / discrete variables

For **categorical** variables (e.g., major, race) and many **discrete** numerics (e.g., number of children, grade), we can usually show the whole distribution in a frequency table.

In Stata, the workhorse is `tabulate` or simply `tab`. Typical output looks like:

```stata
. tab race

       Race |      Freq.     Percent        Cum.
------------+-----------------------------------
      White |      1,637       72.89       72.89
      Black |        583       25.96       98.84
      Other |         26        1.16      100.00
------------+-----------------------------------
      Total |      2,246      100.00
```

How this describes the **distribution of `race`**:
- **Freq.** – How many individuals in each race (counts)  
- **Percent** – What fraction of all students (relative frequency)  
- **Cum.** – Cumulative percentage (useful for ordered categories)

These tables are especially helpful for:
- Finding the **mode** (most common category)  
- Spotting categories with very few observations  
- Checking whether categories look plausible (e.g., 90% “Other” might signal a coding problem)

> Do [Exercise 1 - Tabulate Data]({{ site.baseurl }}/exercises/04-tab/)


### Tabular summaries for continuous variables

For a continuous variable (like income), there are too many possible values to list one-by-one, so we either:
- Group values into bins (e.g., \$0–10k, 10–20k, …), or  
- Describe the distribution with **summary statistics** (mean, median, percentiles, etc.)
   - **Center** – where values tend to be (mean, median)  
   - **Spread** – how variable they are (standard deviation, range, IQR)  
   - **Extremes / outliers** – unusually small or large values

In Stata, we use `summarize` or simply `sum`:

```stata
. sum wage

   Variable |      Obs        Mean    Std. dev.       Min        Max
------------+-------------------------------------------------------
       wage |    2,246    7.766949    5.755523   1.004952   40.74659
```

What this tells us about the distribution of `wage`:
- **Obs** – sample size (N)  
- **Mean** – average wage (center)  
- **Std. dev.** – typical distance from the mean (spread)  
- **Min / Max** – extremes (range)

If you want more detail (like the median and percentiles), you can use:

```stata
   sum         wage, detail
```

This adds:
- **Median** (50th percentile)  
- **Other percentiles** (e.g., 25th, 75th)  
- Measures of skewness and kurtosis (we won’t dwell on those now)

> Do [Exercise 2.1 - Summarize Data]({{ site.baseurl }}/exercises/04-sum/)


### Stored results

When Stata runs `sum` (and many other commands), it doesn’t just print these numbers and forget them. It also stores them as returned results in something called `r()`. You can find what results Stata stores from a command at the very end of the help file for that command. You can also type `return list` right after a command and Stata will display the stored results and their spefici values.

When you run `sum`, Stata stores the results that it printed:
- `r(N)` – number of observations
- `r(mean)` – mean
- `r(sd)` – standard deviation
- `r(min)` – minimum
- `r(max)` – maximum
But also other results that it didn't print:
- `r(var)` - variance
- `r(sum)` - sum of variable

The awesome thing about these stored results is that you can use these directly in calculations or for other things. For example:

```stata
* summarize wage and print the mean
   sum            wage
   display        r(mean)

* print text for easier interpretation by humans
   sum            wage
   local          mean_wage = r(mean)
   display        "The mean wage is " `mean_wage'
```


### Summarizing the **center** of a distribution

Once you know the distribution, you can choose a few key summaries that capture the “middle” of the variable.

####  Mean

The **mean** is the familiar average:

$$
\text{mean} = \frac{\text{sum of all values}}{\text{number of observations}}
$$

For our toy example `2, 5, 5, 6`:

$$
\text{mean} = \frac{2 + 5 + 5 + 6}{4} = \frac{18}{4} = 4.5
$$

In Stata, the mean is in the `sum` output.

#### Median

The **median** is the 50th percentile: half the observations are below it and half are above it.

In our example `2, 5, 5, 6`, the median is 5 (the middle value when sorted).

In Stata, you can see the median using the `detail` option to `sum`.

The median is more robust to outliers than the mean. For example, if incomes are:

`20000, 22000, 25000, 26000, 1000000`

- The mean will be pulled way up by 1,000,000  
- The median (middle value) will still be around the typical salary (here, 25,000)

#### Mode

For categorical variables, a useful “center” is the **mode** – the most common category.

In our toy example `2, 5, 5, 6`, the mode is 5 (it shows up most often).

In Stata, the mode of a categorical variable shows up in the `tab` output as the row with the highest frequency.

> Do [Exercise 2.2 - 2.3 - Summarize Data]({{ site.baseurl }}/exercises/04-sum/)


### Summarizing the **spread** of a distribution

Describing the center alone isn’t enough. Two variables can have the same mean but very different variability.

#### Range

The **range** is:

$$
\text{range} = \text{max} - \text{min}
$$

From `sum`, you can see `Min` and `Max` and calculate the range yourself. Or you can let Stata compute the range for you using the stored results from `sum`:

```stata
* calculate range of wage
   sum            wage
   display        r(max) - r(min)
```

- Easy to understand  
- Very sensitive to outliers

#### Variance and standard deviation

There are a number of ways to summarize how far values tend to be from the mean, on average.
- **Variance** – average squared distance from the mean  
- **Standard deviation** – square root of variance; back on the original scale

You don’t need the full formula here; the key idea is: the standard deviation tells you how tightly clustered or spread out the data are around the mean.

Stata’s `sum` gives you the standard deviation directly.

#### Interquartile range (IQR)

The **interquartile range** (IQR) is:

$$
\text{IQR} = \text{75th percentile} - \text{25th percentile}
$$

It measures the spread of the “middle 50%” of the data and is robust to outliers.

You can see the 25th and 75th percentiles using the `detail` option to `sum` and then calculate the IQR. 

```stata
* calculate iqr of wage
   sum            wage, detail
   display        r(p75) - r(p25)
```

Or you can use the `tabstat` command to build a table with percentiles, including the IQR, using:

```stata
   tabstat        wage, stat(mean median sd p25 p75 iqr)
```

The `tabstat` command displays summary statistics for a series of numeric variables in one table.  It allows you to specify the list of statistics to be displayed. Statistics can be calculated (conditioned on) another variable. It allows substantial flexibility in terms of the statistics presented and the format of the table.

> Do [Exercise 3.1 - 3.2 - Use Stored Values]({{ site.baseurl }}/exercises/04-stored-vals/)


### Putting it together: a basic workflow

When you get a new variable, a good “distribution and summary” workflow in Stata is:

1. **Is it categorical or numeric?**  
   - Categorical / discrete: things like sex, region, number of children  
   - Continuous: income, height, yield  

2. **For categorical / discrete variables**

   ```stata
      tab         varname
   ```

   - Look at frequencies and percentages  
   - Identify the mode and rare categories  
   - Check for strange or unexpected codes  

3. **For continuous variables**

   ```stata
      sum         varname
      sum         varname, detail
   ```

   - Note center (mean, median)  
   - Note spread (standard deviation, range, IQR)  
   - Check min/max for impossible values or outliers  
### Summary

- A distribution conveys the probability of observing every possible value of a variable.
- Summary statistics condense distributions into key metrics like the mean and variance.
- Always look at the distribution of your variables before running regressions.
