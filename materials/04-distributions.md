---
layout: page
element: notes
title: Distributions of variables
language: Stata
---

# Distributions and Summaries

## 1. Why distributions matter

When we collect data, we don’t just care about *individual* observations. We care about **what values are common, what’s rare, and what’s extreme**.

That’s what a **distribution** is:

> For a variable, the distribution tells you how often each value (or range of values) shows up in your data.

In this lecture we will:

- Define what we mean by the distribution of a variable  
- See how to describe distributions with **tables** in Stata  
- Learn how to **summarize** a distribution with a few key numbers (center and spread)

We’ll *mention* graphs (histograms, density plots), but save Stata graphing commands for the next lecture.

---

## 2. What is a distribution? (small example)

Suppose we have a tiny dataset with four observations of exam scores:

- `score = 2, 5, 5, 6`

We can write down the **distribution** as a table:

| score | count | percent |
|-------|-------|---------|
| 2     | 1     | 25%     |
| 5     | 2     | 50%     |
| 6     | 1     | 25%     |
| **Total** | **4** | **100%** |

This table *is* the distribution:  

- It tells us **which values occur** (2, 5, 6)  
- And **how often** (counts and percentages)

For a continuous variable (like income), there are too many possible values to list one-by-one, so we either:

- Group values into **bins** (e.g., \$0–10k, 10–20k, …), or  
- Describe the distribution with **summary statistics** (mean, median, percentiles, etc.)

---

## 3. Tabular distributions for categorical / discrete variables

For **categorical** variables (e.g., major, region) and many **discrete** numerics (e.g., number of children), we can usually show the *whole* distribution in a frequency table.

In Stata, the workhorse is:

```stata
tabulate major
* or simply:
tab major
```

Typical output looks like:

```stata
. tab major

     major |      Freq.     Percent        Cum.
-----------+-----------------------------------
   Econ    |         40       20.00       20.00
   Finance |         60       30.00       50.00
   Other   |        100       50.00      100.00
-----------+-----------------------------------
     Total |        200      100.00
```

How this describes the **distribution of `major`**:

- **Freq.** – How many students in each major (counts)  
- **Percent** – What fraction of all students (relative frequency)  
- **Cum.** – Cumulative percentage (useful for ordered categories)

These tables are especially helpful for:

- Finding the **mode** (most common category)  
- Spotting categories with very few observations  
- Checking whether categories look plausible (e.g., 90% “Other” might signal a coding problem)

---

## 4. Tabular summaries for continuous variables

For continuous variables like income, test scores, or yield, we often can’t list every value. Instead, we describe the distribution with **summary statistics** that capture key features:

- **Center** – where values tend to be (mean, median)  
- **Spread** – how variable they are (standard deviation, range, IQR)  
- **Extremes / outliers** – unusually small or large values

In Stata, a first pass is:

```stata
summarize income
* or:
sum income
```

Example output:

```stata
. sum income

    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
      income |        500    24500.32    10250.11    1500.00   78500.00
```

What this tells us about the distribution of `income`:

- **Obs** – sample size (N)  
- **Mean** – average income (center)  
- **Std. dev.** – typical distance from the mean (spread)  
- **Min / Max** – extremes (range)

We’ll dig into what these summary stats *mean* in the next sections.

If you want more detail (like the median and percentiles), you can use:

```stata
summarize income, detail
```

which adds:

- **Median** (50th percentile)  
- **Other percentiles** (e.g., 25th, 75th)  
- Measures of skewness and kurtosis (we won’t dwell on those now)

---

## 5. Summarizing the **center** of a distribution

Once you know the distribution, you can choose a few key **summaries** that capture the “middle” of the variable.

### 5.1 Mean

The **mean** is the familiar average:

\[
\text{mean} = \frac{\text{sum of all values}}{\text{number of observations}}
\]

For our toy example `2, 5, 5, 6`:

\[
\text{mean} = \frac{2 + 5 + 5 + 6}{4} = \frac{18}{4} = 4.5
\]

In Stata, the mean is in the `summarize` output:

```stata
sum score
```

Interpretation:

- The mean is a **representative value** of the distribution.  
- If “income” is how many dollars a slot machine pays out and the mean is \$4.50, then if the game costs \$4.50, you’d break even *on average* by playing many times.

### 5.2 Median

The **median** is the **50th percentile**:

- Half the observations are **below** it,  
- Half are **above** it.

In our example `2, 5, 5, 6`, the median is 5 (the middle value when sorted).

In Stata, you can see the median using:

```stata
sum score, detail
```

The median is more **robust to outliers** than the mean. For example, if incomes are:

`20000, 22000, 25000, 26000, 1000000`

- The mean will be pulled way up by 1,000,000  
- The median (middle value) will still be around the typical salary (here, 25,000)

### 5.3 Mode

For categorical variables, a useful “center” is the **mode** – the most common category.

In our toy example `2, 5, 5, 6`, the mode is 5 (it shows up most often).

In Stata, the mode of a categorical variable shows up in the `tab` output as the row with the highest frequency.

---

## 6. Summarizing the **spread** of a distribution

Center alone isn’t enough. Two variables can have the same mean but very different variability.

### 6.1 Range

The **range** is:

\[
\text{range} = \text{max} - \text{min}
\]

From `sum`, you can see `Min` and `Max` and calculate the range yourself.

- Easy to understand  
- Very sensitive to **outliers**

### 6.2 Variance and standard deviation

Variance and standard deviation summarize **how far values tend to be from the mean**, on average.

- **Variance** – average squared distance from the mean  
- **Standard deviation** – square root of variance; back on the original scale

You don’t need the full formula here; the key idea is:

> The standard deviation tells you how tightly clustered or spread out the data are around the mean.

Stata’s `summarize` gives you the standard deviation directly.

### 6.3 Interquartile range (IQR)

The **interquartile range** (IQR) is:

\[
\text{IQR} = \text{75th percentile} - \text{25th percentile}
\]

It measures the spread of the “middle 50%” of the data and is **robust to outliers**.

You can see the 25th and 75th percentiles with:

```stata
sum income, detail
```

or build a table with percentiles using:

```stata
tabstat income, statistics(mean median sd p25 p75)
```

---

## 7. Percentiles as a way to describe the distribution

Percentiles are a very direct way of describing a distribution:

> The X-th percentile is the value such that X% of observations are **below** it.

Examples:

- 5th percentile of income: 5% of people make *less* than this  
- 95th percentile: 95% make less, 5% make more

In Stata, you can work with percentiles via:

```stata
sum income, detail          // shows key percentiles
tabstat income, stat(p10 p25 p50 p75 p90)
```

Percentiles and IQR are especially helpful when distributions are **skewed** (like income). The mean gets pulled around by extreme values, but percentiles still tell you where most people are.

---

## 8. Putting it together: a basic workflow

When you get a new variable, a good “distribution and summary” workflow in Stata is:

1. **Is it categorical or numeric?**  
   - Categorical / discrete: things like sex, region, number of children  
   - Continuous: income, height, yield  

2. **For categorical / discrete variables**

   ```stata
   tab varname
   ```

   - Look at frequencies and percentages  
   - Identify the mode and rare categories  
   - Check for strange or unexpected codes  

3. **For continuous variables**

   ```stata
   sum varname
   sum varname, detail
   tabstat varname, stat(mean median sd p25 p75)
   ```

   - Note center (mean, median)  
   - Note spread (standard deviation, range, IQR)  
   - Check min/max for impossible values or outliers  

4. **Describe in words**

   - “Median income is \$25,000, with an IQR from \$18,000 to \$32,000; the distribution is right-skewed, with a few very high incomes raising the mean to \$30,000.”

All of this follows the idea from *The Effect*: once you know the distribution, you can pick a few numbers that describe it well enough for the task at hand.

(Next time: we’ll switch from tables to **graphs**—histograms and kernel density plots—to visualize these distributions.)
