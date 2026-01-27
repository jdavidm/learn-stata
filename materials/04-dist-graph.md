---
layout: page
element: notes
title: Graphing Distributions
language: Stata
---

In the last lecture you saw how to describe a distribution using tables (`tab`) and summary statistics (`sum`). In this lecture we’ll focus on graphs for a *single* numeric variable:

- How to make and interpret **histograms**
- How to make and interpret **kernel density plots**
- How to use key options to control these graphs

Throughout this lecture we will continue to use the system data set `nlsw88.dta`. Remember, as we walk through these lectures, you should be taking notes and coding in a .do file.
---

### Why graphs?

When we use `sum` Stata calculates statistics that give numerical summaries of the distribution of a variable. Last lecture we focused on the **center** and **spread** of a distribution. Both of those words have a clear visual component - in your mind you picture center and spread as positions in space. So, it makes sense that we would like to actually visualize these concepts, not just have numbers to summarize them. Graphs let us see the entire shape of that distribution — where values are common, where they’re rare, how spread out they are, and whether there’s skew or different “lumps” in the data.

Two big ideas for today:
- A **histogram** cuts the x-axis into bins and counts how many observations fall in each bin.
- A **kernel density plot** is like a smoothed histogram — instead of bars, you get a smooth curve that shows where observations are concentrated.

Both plots are different ways of visualizing the same thing: the distribution of a variable.

### Histograms in Stata

A `histogram` (`hist`) is the most basic of Stata graphing commands:

```stata
* basic histogram of hourly wage
    histogram            wage
```

By default, Stata puts wage on the x-axis and density on the y-axis. “Density” is just a rescaling so that the *area* under the bars adds up to 1; the shape is what we care about.

> Ask students to read the plot:
> - Where do most wages fall (center)?
> - Does it look **right-skewed** (a long tail to the right)?
> - Are there any very high wages (possible outliers)?

Histograms are best for continuous-ish variables like income or height, but they can also be used for integer-valued counts, like age. 

```stata
* treat age as discrete: one bar per age
    hist            age, discrete frequency
```

The `discrete` option tells Stata to make one bin for each unique value of `age`, which is usually what you want for integer-valued variables.

#### Changing what `hist` shows you

Stata lets you choose what the y-axis displays. As we saw above, the default is density. Other options include:

```stata
* proportion of observations (0–1)
    hist            wage, fraction

* percent of observations (0–100)
    hist            wage, percent

* raw counts (number of workers in each bin)
    hist            wage, frequency
```

Notice that the shape of the histogram does **not** change when you switch between `density`, `fraction`, `percent`, or `frequency`. Only the label and scale of the y-axis changes.

> Ask them:
> - When might you want frequencies? (e.g., “about 200 workers earn between $5 and $7”)
> - When might you want percentages? (e.g., “about 10% of workers earn between $5 and $7”)

The choice of **bins** matters: too few bins → overly chunky; too many → noisy. Stata chooses a default for you, but you can override it.

```stata
* fewer, wider bins
    hist            wage, bin(10) frequency

* more, narrower bins
    hist            wage, bin(40) frequency
```

Alternatively, you can control bin width and starting point:

```stata
* bin width of $1, starting at $0
    hist            wage, width(1) start(0) frequency
```

Compare `bin(10)` vs `bin(40)`.
- With more bins, small bumps appear and the picture is less smooth.
- With fewer bins, you see the big-picture pattern but lose smaller details.

> Do [Exercise 4.1 - 4.2 - Histograms]({{ site.baseurl }}/exercises/04-hist/)

#### Chaning the the look of `hist`

Because `hist` is so basic a command, you don’t need to go wild with formatting. But some clear labeling makes graphs much easier to read.

```stata
* label histogram of wages
    hist            wage, ///
                        bin(25) percent ///
                        title("Distribution of hourly wages") ///
                        xtitle("Hourly wage (1988 dollars)") ///
                        ytitle("Percent of workers")
```

> Do [Exercise 4.3 - Histograms]({{ site.baseurl }}/exercises/04-hist/)


### Kernel density plots

A **kernel density plot** shows the same idea as a histogram — where values are common or rare — but instead of bars, we get a smooth curve.

Stata’s `kdensity` command:

```stata
kdensity wage
```

Conceptually:

- Imagine a histogram with *very* many very narrow bins, then smoothed out.
- `kdensity` uses a **kernel** (a smooth bump function) and a **bandwidth** (how wide each bump is) to produce the curve.

You don’t need to go into the math; emphasize:

- Taller parts of the curve = **more** observations around that wage
- Flatter parts = **fewer** observations

As with histograms, look for center, spread, and skew (long tail to the right for wages).

---

#### Bandwidth / smoothing (`bwidth()`)

The main option you’ll care about in `kdensity` is the **bandwidth**, set by `bwidth()`. Stata chooses a default bandwidth based on the data, but you can change it.

```stata
* Default bandwidth (Stata chooses)
kdensity wage

* Less smoothing (smaller bandwidth)
kdensity wage, bwidth(1)

* More smoothing (larger bandwidth)
kdensity wage, bwidth(3)
```

Classroom discussion:

- With **small bandwidth**, the curve wiggles more — it follows the data closely (less bias, more noise).
- With **large bandwidth**, the curve is smoother — easier to read big patterns, but small bumps disappear (more bias, less noise).

Tie back to the bin choice in histograms: both are about trading off detail vs smoothness.

---

#### Different kernels (`kernel()`)

Stata supports several kernel shapes (Epanechnikov, Gaussian, etc.):

```stata
* Default kernel (Epanechnikov)
kdensity wage

* Gaussian kernel
kdensity wage, kernel(gaussian)
```

Teaching message:

- For most applied work, the **bandwidth** matters much more than kernel choice.
- You don’t need to worry about picking the perfect kernel in this course.

---

### Overlaying histogram and kernel density

A nice visualization is to put a **histogram and kernel density on the same plot** so students can see how they relate.

Using `twoway`:

```stata
twoway  ///
    (histogram wage, bin(25)) ///
    || ///
    (kdensity wage)
```

Alternatively, with the one-command approach:

```stata
histogram wage, bin(25) kdensity
```

Talk through the figure:

- The histogram bars show **counts (or proportions) in bins**.
- The kernel density curve is a **smoothed version** of that same pattern.
- Where the bars are high, the curve is high; where bars are low, the curve is low.

---

## 5. Reading and describing distributions from graphs

Now that students can make the graphs, push them to **describe what they see**, connecting back to the previous lecture’s numeric summaries.

Using `wage`:

1. **Center**
   - Roughly where is the bulk of the mass?
   - How does that compare to the mean and median from `sum wage, detail`?

2. **Spread**
   - How wide is the distribution on the x-axis?
   - Does the graph match the standard deviation and IQR they computed earlier?

3. **Skew**
   - Is there a long right tail?
   - Does that fit what we expect for income-type variables (many with modest wages, a few with very high wages)?

4. **Outliers / unusual features**
   - Any isolated bars or weird little bumps?
   - Are there gaps (no observations) in parts of the wage range?

Encourage students to write short verbal descriptions like:

> “The distribution of hourly wages is right-skewed, with most workers earning between $3 and $10, a median of about $7, and a long tail of higher wages up to about $40. The standard deviation is fairly large, reflecting the wide spread in wages.”

This ties together **numerical summaries** (mean, median, sd, IQR) from Lecture 1 with **visual summaries** (histogram, kernel density) from this lecture.

---

## 6. A practical workflow for a new numeric variable

When you get a new continuous variable in Stata, a good workflow now is:

```stata
* 1. Numerical summaries
sum varname
sum varname, detail

* 2. Histogram (try a couple of bin choices)
histogram varname, bin(20) percent
histogram varname, bin(40) percent

* 3. Kernel density
kdensity varname

* 4. Overlay (optional)
twoway (histogram varname, bin(25)) || (kdensity varname)
```

Then describe:

- Center, spread, skew, and any outliers — in words — based on both numbers and graphs.

No theoretical distributions, no hypothesis tests yet — just getting very comfortable **seeing and describing** how a single variable behaves in the data.
