---
layout: page
element: notes
title: Graphing Regression Results
language: Stata
---

Tables are good for recording numbers. But when you want your audience to **see** the story in your results — the direction, magnitude, and precision of effects — a graph is almost always better. This lecture introduces tools for visualizing regression output.

This lecture covers:
- Why coefficient plots beat tables for communication
- `coefplot`: plotting coefficients from one or more regressions
- Customizing `coefplot`: labels, colors, reference lines
- Multi-model coefficient plots
- Specification charts: showing how your key result holds across many specifications
- Exporting graphs for LaTeX

If you don’t have the `coefplot` package already installed, add it to the list of packages in your `project.do` file, change `$pack = 1` and run `project.do`. Then change `$pack = 0`.

We'll use the maize-only `eth_allrounds_final` data for all lecture examples. You should already have the following variables from previous exercises but if you don't, create them now.

```stata
* create per ha inputs
    gen             fert = nitrogen_kg / plot_area_GPS
    lab var         fert "fertilizer (kg/ha)"
    gen             labor = total_labor_days / plot_area_GPS
    lab var         labor "labor (days/ha)"
    gen             seed = seed_value_USD / plot_area_GPS
    lab var         seed "seed (USD/ha)"
```

### Why coefficient plots?

Consider running three regressions and reporting the coefficient on `fert` each time. In a table, the reader has to scan rows and columns, mentally comparing numbers. In a coefficient plot, the comparison is instant and visual.

A coefficient plot shows:
- A **point** for each coefficient estimate
- A **horizontal line** (confidence interval) around each point
- A **reference line** at zero

If the confidence interval crosses zero, the coefficient is not significant at the corresponding level.

### Basic `coefplot`

```stata
* run a regression
    reg             yield_kg fert labor seed i.admin_1, ///
                        vce(cluster hh_id_obs)

* basic coefficient plot
    coefplot,       drop(_cons) xline(0) ///
                        title("Yield regression coefficients") ///
                        xtitle("Coefficient estimate")
```

The `drop(_cons)` option removes the constant (which is usually not interesting). `xline(0)` adds a vertical reference line at zero.

### Customizing `coefplot`

#### Selecting and reordering coefficients

Often you want to show only the variables of interest:

```stata
* show only key variables
    coefplot,       keep(fert labor seed) xline(0) ///
                        title("Key coefficients") ///
                        xtitle("Effect on yield (kg/ha)")
```

#### Changing colors and markers

```stata
* customize the look
    coefplot,       keep(fert labor seed) xline(0) ///
                        mcolor(edkblue) ciopts(lcolor(edkblue)) ///
                        msymbol(D) ///
                        title("Yield regression") ///
                        xtitle("Coefficient") ///
                        graphregion(color(white))
```

#### Adding coefficient labels

By default, `coefplot` uses variable names. You can relabel:

```stata
* relabel coefficients
    coefplot,       keep(fert labor seed) xline(0) ///
                        rename(fert = "Fertilizer (kg/ha)" ///
                               labor = "Labor (days/ha)" ///
                               seed = "Seed (USD/ha)") ///
                        title("Yield regression") ///
                        xtitle("Coefficient")
```

> Do [Exercise 6 - Basic Coefplot]({{ site.baseurl }}/exercises/10-coefplot-basic/)

### Multi-model coefficient plots

The real power of `coefplot` is comparing coefficients across models. The workflow:

1. Run each regression
2. Store the estimates with `eststo`
3. Plot them together

```stata
* model 1: baseline
    reg             yield_kg fert labor seed, vce(cluster hh_id_obs)
    eststo          m1

* model 2: add controls
    reg             yield_kg fert labor seed i.irrigated i.intercropped, ///
                        vce(cluster hh_id_obs)
    eststo          m2

* model 3: add region & wave FE
    reg             yield_kg fert labor seed i.irrigated i.intercropped i.admin_1 i.wave, ///
                        vce(cluster hh_id_obs)
    eststo          m3

* multi-model coefplot: compare fert across specs
	coefplot		(m1, label("Baseline")) ///
					(m2, label("+ Controls")) ///
					(m3, label("+ Region & Wave FE")), ///
						keep(fert labor seed) ///
						xline(0) levels(90) ///
						title("Input coefficient across specifications") ///
						xtitle("Effect on yield (kg/ha)") ///
						graphregion(color(white))	
```

This shows at a glance whether the effect of measured inputs is stable as you add controls — a key test of robustness.

### Exporting graphs for LaTeX

After creating any graph, export it for use in your Overleaf document:

```stata
* export the graph as PNG
    graph export    "$answ/coefplot_fert.png", replace
```

Then in your LaTeX file:

```latex
\begin{figure}[htbp]
    \centering
    \caption{Input impact on yield}
    \label{fig:coefplot_fert}
    \includegraphics[width=0.8\textwidth]{coefplot_fert.png}
\end{figure}
```

> Do [Exercise 7 - Multi-Model Coefplot]({{ site.baseurl }}/exercises/10-coefplot-multi/)

### Specification charts

A **specification chart** takes the multi-model idea further. Instead of comparing 3–4 models, you run **many** specifications (varying the controls, sample, dependent variable, etc.) and plot the key coefficient from each one. The bottom of the chart shows which specification choices are active in each column.

This is a powerful tool for showing that your result is (or isn't) robust across many researcher degrees of freedom.

#### Building a specification chart

The approach is:

1. Run many regressions in a loop, storing the coefficient, CI, and specification indicators
2. Collapse the results into a dataset
3. Sort by effect size
4. Plot the coefficients on top and specification indicators on the bottom

Here is a simplified example using our yield data. We'll vary the controls and dependent variable:

```stata
* set up a results dataset
    clear all
    use             "$data/eth_allrounds_final.dta", clear
    keep if         crop_name == "MAIZE"
    gen             fert = nitrogen_kg / plot_area_GPS
    gen             labor = total_labor_days / plot_area_GPS
    gen             seed = seed_value_USD / plot_area_GPS
    gen             ln_yield = ln(yield_kg)

* create a temporary dataset to store results
    tempfile        results
    postfile        handle spec beta se ci_lo ci_up ///
                        depvar controls cluster_hh ///
                        using `results'

* define specifications and loop
    local           spec = 0

    foreach dv in yield_kg ln_yield {
        foreach ctrl in 0 1 2 {
            foreach cl in 0 1 {

                local       spec = `spec' + 1

                * set dep var indicator
                local       dv_ind = cond("`dv'" == "yield_kg", 1, 2)

                * set controls
                local       rhs "fert labor"
                if `ctrl' >= 1  local rhs "`rhs' i.irr i.admin_1"
                if `ctrl' == 2  local rhs "`rhs' seed i.intercropped i.wave"
                local       ctrl_ind = `ctrl' + 1

                * set clustering
                local       vce_opt ""
                local       cl_ind = `cl' + 1
                if `cl' == 1    local vce_opt ", vce(cluster hh_id_obs)"

                * run regression
                cap reg     `dv' `rhs' `vce_opt'
                if _rc == 0 {
                    local   b = _b[fert]
                    local   s = _se[fert]
                    local   lo = `b' - 1.96*`s'
                    local   hi = `b' + 1.96*`s'
                    post    handle (`spec') (`b') (`s') (`lo') (`hi') ///
                                (`dv_ind') (`ctrl_ind') (`cl_ind')
                }
            }
        }
    }

    postclose       handle

* load results and prepare for plotting
    use             `results', clear

* flag significance
    gen             b_sig = beta if (ci_lo > 0 | ci_up < 0)
    gen             b_ns  = beta if b_sig == .
```

#### Plotting the specification chart

The chart has two parts: coefficients on a y-axis (right) and specification indicators below (left). We stack indicator values and use a dual y-axis:

```stata
* sort by effect size
    sort            beta
    gen             obs = _n

* stack specification indicators
    gen             k1 = depvar
    gen             k2 = controls + 3
    gen             k3 = cluster_hh + 7

* set axis ranges
    qui sum         ci_up
    global          bmax = r(max)
    qui sum         ci_lo
    global          bmin = r(min)
    global          brange = $bmax - $bmin
    global          from_y = $bmin - 2.5*$brange
    global          gheight = 12

* plot the specification chart
    twoway          (scatter k1 k2 k3 obs, ///
                        xsize(10) ysize(6) xtitle("") ytitle("") ///
                        msize(small small small) ///
                        mcolor(gs10 gs10 gs10) ///
                        ylabel( ///
                            1 "Yield (kg)" 2 "Ln(yield)" ///
                            3 "{bf:Dep. Var.}" ///
                            4 "Baseline" 5 "+ Region/Irr" 6 "+ Full" ///
                            7 "{bf:Controls}" ///
                            8 "Default" 9 "Clustered" ///
                            10 "{bf:Std. Errors}" 12 " ", ///
                            angle(0) labsize(vsmall) tstyle(notick)) ///
                        plotregion(margin(4 4 4 7))) ///
                    || (scatter b_sig obs if beta > 0, yaxis(2) ///
                        mcolor(edkblue%75) msymbol(+) ///
                        ylab(, axis(2) labsize(vsmall) angle(0)) ///
                        yscale(range($from_y $bmax) axis(2))) ///
                    || (scatter b_sig obs if beta < 0, yaxis(2) ///
                        mcolor(maroon%75) msymbol(+)) ///
                    || (scatter b_ns obs, yaxis(2) ///
                        mcolor(black%75) msymbol(Th)) ///
                    || (rbar ci_lo ci_up obs if b_sig == ., ///
                        barwidth(.3) color(black%50) yaxis(2)) ///
                    || (rbar ci_lo ci_up obs if b_sig != . & beta > 0, ///
                        barwidth(.3) color(edkblue%50) yaxis(2)) ///
                    || (rbar ci_lo ci_up obs if b_sig != . & beta < 0, ///
                        barwidth(.3) color(maroon%50) yaxis(2) ///
                        yline(0, lcolor(maroon) axis(2) lstyle(solid))), ///
                    legend(order(5 "Not sig." 6 "Sig. (positive)" ///
                                 7 "Sig. (negative)") ///
                        cols(3) size(small) pos(6)) ///
                    title("Specification chart: fertilizer effect on yield")

    graph export    "$answ/spec_chart.png", replace
```

The key features of this chart:

- Each column is one specification, sorted by coefficient size
- **Blue** markers/bars = significant and positive
- **Red/maroon** markers/bars = significant and negative
- **Black/grey** = not significant
- The bottom rows show which choices (dep var, controls, SEs) are active
- A horizontal reference line at zero

If most blue and maroon markers cluster on one side of zero and the result is stable across specifications, the researcher can be more confident in the finding.

> Do [Exercise 9 - Specification Chart]({{ site.baseurl }}/exercises/10-spec-chart/)

### Summary

- **Coefficient plots** visualize regression results more effectively than tables
- `coefplot` makes it easy to plot coefficients from one or more models
- **Multi-model coefplots** show robustness at a glance
- **Specification charts** systematically test how sensitive your result is to researcher choices
- Always `graph export` your plots for inclusion in LaTeX documents

Next up: completing the final challenge exercise for this week.
