---
layout: page
element: notes
title: Making and Beautifying Scatter Plots
language: Stata
---

In Week 5 we move from describing **single variables** to describing **relationships between variables**. The main tool for seeing relationships between two numeric variables is the **scatter plot**.

For this lecture we’ll use the plot-level panel dataset from Ethiopia, `eth_allrounds_final`, based on the World Bank LSMS-ISA survey. Each row is (roughly) a plot-year observation with variables on production, inputs, and household characteristics.

As always, you should be taking notes and coding in a `.do` file as we go.

### Why scatter plots?

When we suspect that one variable might be related to another (for example, yield and fertilizer), a scatter plot lets us:
- Put one variable on the x-axis and one on the y-axis  
- See whether values tend to **move together** (positive or negative correlation)  
- Spot **nonlinear patterns**, **clusters**, and **outliers**

Today we’ll focus on:
- Making basic scatter plots in Stata  
- Tweaking labels and appearance so the plots are readable and useful

The basic Stata syntax is:

```stata
    scatter         yvar xvar
```

As an example, look at the relationship between `harvest_kg` and `plot_area_GPS`:

```stata
* basic scatter plot: harvest vs plot area
    scatter         harvest_kg plot_area_GPS
```

Here:
- `harvest_kg` = kilograms of output on the plot is on the **y-axis** 
- `plot_area_GPS` = plot size from GPS (e.g., hectares) is on the **x-axis**

> Questions to ask looking at this scatter plot:
> - Do larger plots tend to have higher total harvest?  
> - Is there a lot of spread for a given plot size?  
> - Are there any extreme outliers in harvest or area?

Try a few other pairs:

```stata
* value of yield vs nitrogen applied
    scatter         yield_value_USD nitrogen_kg

* yield per hectare vs total labor
    scatter         yield_kg total_labor_days
```

### Adding titles and axis labels

Always label graphs so someone else (or you in two weeks) can understand them.

```stata
* labeled scatter plot: harvest vs plot area
    scatter         harvest_kg plot_area_GPS, ///
                        title("Plot-level harvest vs plot size") ///
                        xtitle("Plot area (ha)") ///
                        ytitle("Harvest (kg)")
```

- `title()` adds a main title  
- `xtitle()` and `ytitle()` label the axes  

Get in the habit of doing this for any figure you care about.

### Labelling tick marks on the axes

By default Stata chooses where to place tick marks and what numbers to show on each axis. Often that’s fine, but sometimes you want more control.

You can use `xlabel()` and `ylabel()` to set tick locations and labels:

```stata
* choose specific tick marks on both axes
    scatter         harvest_kg plot_area_GPS, ///
                        title("Harvest vs plot size") ///
                        xtitle("Plot area (ha)") ///
                        ytitle("Harvest (kg)") ///
                        xlabel(0(1)5) ///
                        ylabel(0(1000)5000)
```

- `xlabel(0(1)5)` puts x-axis ticks at 0, 1, 2, 3, 4, 5  
- `ylabel(0(1000)5000)` puts y-axis ticks at 0, 1000, 2000, …, 5000  

You can also give custom text labels:

```stata
* custom text labels on the x-axis
    scatter         harvest_kg plot_area_GPS, ///
                        xtitle("Plot size") ///
                        xlabel(0 "0" 1 "1 ha" 2 "2 ha" 3 "3 ha+", ///
                        labsize(small))
```

Simple rules of thumb:
- Don’t add too many labeled ticks — it gets cluttered fast.  
- Make sure the tick labels match the scale and units in your axis titles.

### Controlling marker look

Scatter plots with many observations can get cluttered. You can change marker style to improve readability.

```stata
* smaller hollow circles
    scatter         harvest_kg plot_area_GPS, ///
                        msymbol(Oh) msize(small)

* tiny points
    scatter         harvest_kg plot_area_GPS, ///
                        msymbol(point) msize(vsmall)
```

- `msymbol()` controls marker shape  (circle, diamond, triangle, square, hollow, filled)
- `msize()` controls marker size (vtiny, small, medium, vlarge, vhuge)

When you have many plot observations, small and/or hollow symbols usually look better.

If the x-variable is discrete or takes on only a few values, points can stack on top of each other. You can add a bit of **jitter**:

```stata
* add horizontal jitter to household size vs yield value
    scatter         yield_value_USD hh_size, jitter(2)
```

This spreads points slightly along the x-axis to reveal overlapping observations.

> Do [Exercise 1 - Basic Scatter Plots]({{ site.baseurl }}/exercises/05-bscatter/)

### Coloring by group

We often want to see how a relationship looks for different groups, such as irrigated vs non-irrigated plots. We can overlay separate scatter plots for each group using `twoway`.

Example: yield per hectare vs nitrogen use, by irrigation:

- `yield_kg` (or a yield-per-area measure you construct)  
- `nitrogen_kg` = kilograms of nitrogen applied  
- `irr` = 1 if the plot is irrigated, 0 otherwise

```stata
* yield vs nitrogen, colored by irrigation status
    twoway          (scatter yield_kg nitrogen_kg ///
                        if irr == 1, mcolor(blue)) ///
                    (scatter yield_kg nitrogen_kg ///
                        if irr == 0, mcolor(red)), ///
                        title("Yield vs nitrogen by irrigation") ///
                        xtitle("Nitrogen applied (kg)") ///
                        ytitle("Yield (kg)") ///
                        legend(order(1 "Irrigated" 2 "Rainfed"))
```

> Questions:
> - Do irrigated plots tend to apply more nitrogen?  
> - At similar nitrogen levels, do irrigated plots appear to have higher yields?

You can also facet the scatter plot into separate panels using `by()` with a household or manager characteristic, such as `female_manager`:

```stata
* same relationship, separate panels by manager sex
    scatter         yield_kg nitrogen_kg, ///
                        by(female_manager, legend(off) ///
                            title("Yield vs nitrogen by manager sex"))
```

### Focusing on a subset

Sometimes extreme values make the main pattern hard to see. You can **restrict** the data to a more typical range:

```stata
* focus on plots with moderate area and yield
    scatter         yield_kg plot_area_GPS ///
                        if plot_area_GPS <= 5 & yield_kg <= 5000, ///
                        title("Yield vs plot size (trimmed range)") ///
                        xtitle("Plot area (<= 5 ha)") ///
                        ytitle("Yield (<= 5000 kg)")
```

When you trim the range, make that clear in the title or in your notes.

> Do [Exercise 2 - Grouped Scatter Plots]({{ site.baseurl }}/exercises/05-gscatter/)

---

In the next lectures this week, we’ll build on scatter plots to:

- Look at **conditional distributions** (what yield or input use looks like for given levels of another variable or across groups), and  
- Fit and interpret **lines** through scatter plots to summarize relationships.

### Summary

- Scatter plots are the primary tool for assessing the bivariate relationship between continuous variables.
- They reveal correlation direction, non-linearities, and influential outliers.
- Proper formatting (labels, titles, legends) is essential for professional delivery.
