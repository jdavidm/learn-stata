---
layout: exercise
topic: Graphing
title: Challenge 4
language: Stata
---


In this challenge exercise you will recreate the **“PDF of total work experience with tails”** graph from lecture.

You will:

- Compute the kernel density of `ttl_exp`,
- Shade the **bottom 5%** and **top 5%** of the distribution,
- Mark the **5th percentile**, **mean**, and **95th percentile** with vertical lines,
- Label the tails with “5%” and “95%”, and
- Print the mean value below the x-axis.

Work in a **do-file**, and include comments so you can remember what you did when you come back later.

---

## 1. Load the data and get key summary stats

1. Load the data:

    ```stata
    * load data
        sysuse          nlsw88, clear
    ```

2. Get detailed summary statistics for `ttl_exp`:

    ```stata
    * get summary stats from ttl_exp
        quietly sum     ttl_exp, detail
    ```

3. Store the **mean**, **5th percentile**, and **95th percentile** in locals:

    ```stata
    * store values as locals
        local           mu  = r(mean)
        local           p5  = r(p5)
        local           p95 = r(p95)
    ```

Check in the Results window that these values look reasonable for total work experience.

---

## 2. Compute the kernel density and define tail regions

1. Ask Stata to compute the kernel density of `ttl_exp` and save the grid and density in new variables:

    ```stata
    * compute kernel density and save the grid + density
        kdensity        ttl_exp, gen(x_ttl d_ttl) nograph
    ```

   - `x_ttl` contains the x-values for the density grid.  
   - `d_ttl` contains the estimated density at each x-value.

2. Create variables for the **left** and **right** tails:

    ```stata
    * create left and right tail densities for shading
        gen             d_left  = d_ttl if x_ttl <= `p5'
        gen             d_right = d_ttl if x_ttl >= `p95'
    ```

   - `d_left` will be nonmissing only in the **bottom 5%** region.  
   - `d_right` will be nonmissing only in the **top 5%** region.

---

## 3. Find the cutoffs for shading and add a zero line

1. Find the **maximum** x-value in the left tail and the **minimum** x-value in the right tail. These will be used for vertical lines:

    ```stata
    * create locals for right and left cutoff
        quietly sum     x_ttl if !missing(d_left), meanonly
        local           lcut = r(max)

        quietly sum     x_ttl if !missing(d_right), meanonly
        local           rcut = r(min)
    ```

2. Create a variable of zeros for use with `rarea` (which shades between two curves):

    ```stata
    * a zero line for rarea (needed for shading)
        gen             zero = 0
    ```

3. Create nicely formatted labels for the 5th percentile, mean, and 95th percentile if you want to use them later:

    ```stata
    * create nicely formatted labels for tick marks
        local           p5lbl  : display %5.2f `p5'
        local           mulbl  : display %5.2f `mu'
        local           p95lbl : display %5.2f `p95'
    ```

---

## 4. Choose positions for the “5%” and “95%” labels

You want the text “5%” and “95%” to appear **inside** the shaded tail regions.

1. Compute the **x-position** for the center of the left tail and a y-position that is 60% of the maximum density in the left tail:

    ```stata
    * left tail center & height
        quietly sum     x_ttl if !missing(d_left), meanonly
        local           lx = (r(min) + r(max))/2

        quietly sum     d_ttl if !missing(d_left), meanonly
        local           ly = 0.6*r(max)
    ```

2. Do the same for the right tail:

    ```stata
    * right tail center & height
        quietly sum     x_ttl if !missing(d_right), meanonly
        local           rx = (r(min) + r(max))/2

        quietly sum     d_ttl if !missing(d_right), meanonly
        local           ry = 0.6*r(max)
    ```

These locals (`lx`, `ly`, `rx`, `ry`) will give Stata the coordinates for the text labels.

---

## 5. Draw the final graph

Now put everything together in a single `twoway` command. Type (or paste) the following into your do-file:

```stata
* final graph
twoway      (kdensity ttl_exp) ///
                (rarea d_left  zero x_ttl, sort c(navy%60)) ///
                (rarea d_right zero x_ttl, sort c(navy%60)), ///
                xline(`lcut' `mu' `rcut', lp(dash) lc(maroon)) ///
                xlabel(`mu' "`mulbl'", add) ///
                text(`ly' `lx' "5%",  place(c)) ///
                text(`ry' `rx' "95%", place(c)) ///
                title("PDF of total work experience") ///
                xtitle("Total work experience (years)") ///
                ytitle("Density") ///
                legend(off)
```

This should produce a graph with:

- The **kernel density** of `ttl_exp` in black,
- The **bottom 5%** and **top 5%** shaded in navy,
- Vertical dashed lines at the **5th percentile**, **mean**, and **95th percentile**,
- The labels **“5%”** and **“95%”** inside the shaded regions, and
- The numeric value of the **mean** printed below the x-axis at its location.
