---
layout: page
element: notes
title: Conditional Distributions
language: Stata
---

In this lecture we are going to move from just drawing scatter plots to more systematically describing **how one variable behaves, given another**. This lecture is about **conditional distributions**:

- How does yield vary **by** irrigation status?  
- How does fertilizer use differ **across** households with different assets?  
- How can we summarize these patterns with tables, graphs, and conditional means?

We’ll keep using the Ethiopia LSMS-ISA plot-level data, `eth_allrounds_final`.

### Conditional distributions: idea

A **conditional distribution** is the distribution of a variable `Y` for some subset defined by another variable `X`:
- Distribution of `yield_kg` **given** the plot is irrigated (`irr == 1`)  
- Distribution of `nitrogen_kg` **given** the household is in the top asset group  

We’ll mostly look at:
- Conditional distributions by **group** (discrete `X`), and  
- **Conditional means** when `X` is continuous (using simple binning).

### Conditional distributions by group

Start with a simple example: yield by irrigation status.
- `yield_kg` = plot-level yield in kilograms  
- `irr` = 1 if the plot is irrigated, 0 otherwise  

We can look at basic summaries within each group using `if`:

```stata
* yield for irrigated plots
    sum             yield_kg if irr == 1

* yield for rainfed plots
    sum             yield_kg if irr == 0
```

To see the **shape** of the conditional distributions, use histograms or kernel densities with `if`:

```stata
* histograms of yield by irrigation status
    histogram       yield_kg if irr == 1, percent ///
                        title("Yield (kg) - irrigated plots")

    histogram       yield_kg if irr == 0, percent ///
                        title("Yield (kg) - rainfed plots")
```

Or overlay kernel densities:

```stata
* kernel densities of yield by irrigation status
    twoway          (kdensity yield_kg if irr == 1) ///
                    (kdensity yield_kg if irr == 0), ///
                        legend(order(1 "Irrigated" 2 "Rainfed")) ///
                        title("Yield distributions by irrigation") ///
                        xtitle("Yield (kg)") ytitle("Density")
```

These graphs show the **conditional distributions** of yield, given irrigation status.

> Do [Exercise 3 - Conditional Distributions]({{ site.baseurl }}/exercises/05-ConDs/)

### Conditional means by group

Often we just want a **single number** for each group: the mean of `Y` given `X = g`.

For irrigated vs rainfed plots:

```stata
* mean yield by irrigation status in a table
    tabstat         yield_kg, by(irr) stat(mean sd n)
```

This gives you:

- $E[\text{yield\_kg} \mid \text{irrigated}=0]$
- $E[\text{yield\_kg} \mid \text{irrigated}=1]$

You can show the same information in a simple graph:

```stata
* bar graph of mean yield by irrigation status
    graph bar       (mean) yield_kg, over(irr) ///
                        ytitle("Mean yield (kg)") ///
                        title("Mean yield by irrigation status")
```

Try other group variables, for example:
- `female_manager` (1 = if female manages plot, 0 = if male manages)  
- `improved` (1 = if planted with improved seed, 0 = if traditional seed)

```stata
* mean yield by manager sex
    graph bar       (mean) yield_kg, over(female_manager) ///
                        ytitle("Mean yield (kg)") ///
                        title("Mean yield by manager sex")
```

> Do [Exercise 4 - Conditional Means (Discrete)]({{ site.baseurl }}/exercises/05-ConMds/)

### Conditional means for continuous `X` (binning)

When `X` is continuous (e.g., `plot_area_GPS` or `hh_asset_index`), we can’t make a separate group for every value. A simple approach is to **bin** `X` into categories and compute mean `Y` in each bin.

Example: mean yield by **plot size group** using quartiles of `plot_area_GPS`:

```stata
* create quartile bins of plot area
    xtile           area_q = plot_area_GPS, nq(4)

* check distribution of bins
    tab             area_q

* mean yield in each area bin
    tabstat         yield_kg, by(area_q) stat(mean n)
```

We can then plot the **mean yield** in each bin:

```stata
* graph mean yield by area quartile
    graph bar       (mean) yield_kg, over(area_q) ///
                        ytitle("Mean yield (kg)") ///
                        xtitle("Plot area quartile") ///
                        title("Mean yield by plot size group")
```

Similarly, we could look at conditional means of fertilizer use by household asset group:

```stata
* asset index quartiles
    xtile           asset_q = hh_asset_index, nq(4)

* mean nitrogen use by asset quartile
    graph bar       (mean) nitrogen_kg, over(asset_q) ///
                        ytitle("Mean nitrogen (kg)") ///
                        xtitle("Household asset quartile") ///
                        title("Nitrogen use by asset group")
```

These bar graphs are visual summaries of **conditional means**: average `Y` in slices of `X`.

> Do [Exercise 5 - Conditional Means (Continuous)]({{ site.baseurl }}/exercises/05-ConMcs/)

### A workflow for describing conditional distributions

When you want to understand how `Y` behaves given `X`:

```stata
* 1. Start with overall summaries
    sum             Y
    sum             Y, detail

* 2. For a discrete X (groups)
    sum             Y, detail if X == value
    tabstat         Y, by(X) stat(mean sd n)
    graph bar       (mean) Y, over(X)

* 3. For a continuous X (bins)
    xtile           Xbin = X, nq(4)        // or nq(5), etc.
    tabstat         Y, by(Xbin) stat(mean n)
    graph bar       (mean) Y, over(Xbin)
```

In the next lecture we’ll connect these conditional means to **line fitting**, where we summarize the relationship between `X` and `Y` with a straight line (or other simple functions) on top of a scatter plot.
