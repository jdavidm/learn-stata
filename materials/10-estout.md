---
layout: page
element: notes
title: Producing Tables with estout
language: Stata
---

Journals, advisors, and referees expect **tables** — neatly formatted, with standard errors in parentheses, significance stars, and informative notes. Doing this by hand is tedious and error-prone. The `estout` package automates the entire process and can export complete LaTeX code ready for your Overleaf document.

This lecture covers:
- The `estimates store` → `esttab` workflow
- Summary statistics tables
- Single- and multi-column regression tables
- Customization: stars, labels, notes, formatting
- Exporting to LaTeX (`.tex` files)
- Integrating tables into Overleaf with `\input{}`

If you don't have the `estout` package already installed, add it to the list of packages in your `project.do` file, change `$pack = 1` and run `project.do`. Then change `$pack = 0`.

We'll use the maize-only `eth_allrounds_final` data for all lecture examples. Before we start, we need to create the following variables

```stata
* create per ha inputs
    gen             fert = nitrogen_kg / plot_area_GPS
    lab var         fert "fertilizer (kg/ha)"
    gen             labor = total_labor_days / plot_area_GPS
    lab var         labor "labor (days/ha)"
    gen             seed = seed_value_USD / plot_area_GPS
    lab var         seed "seed (USD/ha)"
```

### The `eststo` → `esttab` workflow

The core idea:

1. Run a regression with `reg`
2. Store the results with `eststo name`
3. Repeat for additional models
4. Display all stored models in one table with `esttab`

```stata
* step 1: run and store
    reg             yield_kg fert labor, vce(cluster hh_id_obs)
    eststo          m1

* step 2: display
    esttab          m1
```

`esttab` produces a formatted table in the Stata results window. By default it shows coefficients, standard errors, t-statistics, and significance stars.

### Summary statistics tables

Before showing regression results, most papers include a table of summary statistics. `estout` handles this with `estpost summarize`:

```stata
* summary statistics
    estpost         sum yield_kg fert labor seed, detail

* display as a table
    esttab,         cells("count mean sd min max") ///
                        noobs nonumber nomtitle ///
                        title("Summary Statistics") ///
                        label
```

The `booktabs` option in your preamble produces cleaner horizontal rules (`\toprule`, `\midrule`, `\bottomrule`).

> Do [Exercise 3 - Summary Statistics Table]({{ site.baseurl }}/exercises/10-sumstats/)

### Regression tables

```stata
* run and store a regression
    reg             yield_kg fert labor i.irr i.admin_1, ///
                        vce(cluster hh_id_obs)
    eststo          m_full

* display with customization and export to LaTeX
    esttab          m_full using "$answ/10-yield-regs.tex", replace ///
                        b(3) se(3) ///
                        keep(fert labor 1.irr) ///
                        label booktabs
```

To produce a `.tex` file that you can `\input{}` in Overleaf, add `using "filename.tex"`:

Key options:
- `b(3)` and `se(3)` — format coefficients and standard errors to 3 decimal places
- `keep(...)` — show only the variables of interest (hides fixed effects)
- `label` — use variable labels instead of variable names
- `booktabs` — uses cleaner horizontal rules (`\toprule`, `\midrule`, `\bottomrule`) in LaTeX output

Build up specifications column by column to create a multi-column table:

```stata
* model 1: baseline
    reg             yield_kg fert labor, vce(cluster hh_id_obs)
    eststo          c1

* model 2: add irrigation
    reg             yield_kg fert labor i.irr, vce(cluster hh_id_obs)
    eststo          c2

* model 3: add region FE
    reg             yield_kg fert labor i.irr i.admin_1, ///
                        vce(cluster hh_id_obs)
    eststo          c3

* model 4: full specification
    reg             yield_kg fert labor seed i.irr i.intercropped ///
                        i.admin_1 i.wave, vce(cluster hh_id_obs)
    eststo          c4

* four-column table
* export the four-column table to LaTeX
    esttab          c1 c2 c3 c4 using "$answ/10-yield-regs.tex", replace ///
                        se star(* 0.10 ** 0.05 *** 0.01) ///
                        keep(fert labor seed 1.irr 1.intercropped) ///
                        order(fert labor seed 1.irr 1.intercropped) ///
                        label booktabs ///
                        mtitles("(1)" "(2)" "(3)" "(4)") ///
                        indicate("Region FE = *.admin_1" ///
                                 "Wave FE = *.wave") ///
                        note("Standard errors clustered " ///
                             "at household level in parentheses. " ///
                             "* p<0.10, ** p<0.05, *** p<0.01") ///
                        stats(N r2, labels("Observations" "R-squared") ///
                              fmt(0 3))
```

Key options for multi-column tables:

- `order(...)` — controls the row order of variables
- `mtitles(...)` — column headers
- `indicate(...)` — adds "Yes/No" rows showing which fixed effects are included
- `stats(N r2, ...)` — adds model statistics at the bottom
- `fmt(...)` — controls decimal formatting

Then in your Overleaf document:

```latex
\begin{table}[htbp]
    \centering
    \label{tab:yield_regs}
    \input{10-yield-regs.tex}
\end{table}
```

> Do [Exercise 4 - Basic `esttab` Table]({{ site.baseurl }}/exercises/10-esttab-basic/)

### More customizations

#### Controlling decimal places

```stata
* different formats for different statistics
    esttab          c1 c2, ///
                        b(3) se(3) ///
                        star(* 0.10 ** 0.05 *** 0.01)
```

`b(3)` formats coefficients to 3 decimal places. `se(3)` does the same for standard errors.

#### Using t-statistics instead of standard errors

```stata
* show t-statistics in brackets
    esttab          c1 c2, ///
                        t star(* 0.10 ** 0.05 *** 0.01) ///
                        brackets
```

#### Adding scalars

You can add custom scalars (e.g., mean of the dependent variable):

```stata
* store mean of Y with estimation results
    reg             yield_kg fert labor, vce(cluster hh_id_obs)
    sum             yield_kg if e(sample)
    estadd          scalar ymean = r(mean)
    estimates       store c1_extra

* include in table
    esttab          c1_extra, ///
                        stats(ymean N r2, ///
                              labels("Mean dep. var." "Observations" "R-squared") ///
                              fmt(1 0 3))
```

#### Custom table header with `prehead`

The `prehead()` option lets you write raw LaTeX that appears **before** the table body. This is useful for adding grouped column headers that span multiple columns with `\multicolumn`, or custom horizontal rules with `\cline`:

```stata
* custom header with grouped columns
    esttab          c1 c2 c3 c4 using "$answ/10-yield-regs.tex", replace ///
                        b(3) se(3) ///
                        keep(fert labor seed 1.irr 1.intercropped) ///
                        label booktabs nonum nomtitle ///
                        prehead("\begin{tabular}{l*{4}{c}} \hline \hline \\[-1.8ex] " ///
                        "& \multicolumn{2}{c}{Baseline} & \multicolumn{2}{c}{With FE} \\ " ///
                        "\cline{2-3} \cline{4-5} \\[-1.8ex]")
```

The `prehead` string is passed directly into the `.tex` file. Here we open the `tabular` environment with 4 centered columns, add a grouped header row using `\multicolumn` to span pairs of columns, and use `\cline` to draw partial horizontal rules under each group.

#### Custom table footer with `postfoot`

The `postfoot()` option works the same way but for the **bottom** of the table. Use it to add notes and close the `tabular` environment:

```stata
* custom footer with table note
    esttab          c1 c2 c3 c4 using "$answ/10-yield-regs.tex", replace ///
                        b(3) se(3) ///
                        keep(fert labor seed 1.irr 1.intercropped) ///
                        label booktabs nonum nomtitle ///
                        postfoot("\hline \hline \\[-1.8ex] " ///
                        "\multicolumn{5}{p{0.8\linewidth}}{\small " ///
                        "\textit{Note}: Standard errors clustered at " ///
                        "household level in parentheses.} \end{tabular}")
```

#### The `fragment` option

When you supply your own `prehead` and `postfoot`, you are writing the full `\begin{tabular}...\end{tabular}` wrapper yourself. Add the `fragment` option to tell `esttab` **not** to generate its default tabular wrapper, avoiding duplicate environments:

```stata
    esttab          ..., fragment prehead("...") postfoot("...")
```

#### Clean-up options

Several options remove default table elements that clutter a publication table:

| Option | What it suppresses |
|---|---|
| `nonum` | Model numbers above columns |
| `nomtitle` | Model titles above columns |
| `collabels(none)` | Column labels (e.g., the "(1)" header) |
| `nobaselevels` | Base-level rows for factor variables |
| `nogaps` | Extra spacing between groups of variables |
| `noobs` | Observation count (useful when you report N via `stats` instead) |

#### Putting it all together

Here is a publication-ready table from a solar-stove experiment. It combines every customization we've covered — `prehead` for grouped column headers, `postfoot` for a detailed note, `fragment` for full control, `keep` to show only the treatment effect, and `stats` for bottom-panel statistics:

```stata
	esttab 			dLPM dLPMc mshare msharec dshare dsharec ///
						wshare wsharec tshare tsharec ///
						using "$output/ss_use.tex", b(3) se(3) replace ///
							prehead("\begin{tabular}{l*{10}{c}} \\[-1.8ex]\hline \hline \\[-1.8ex] " ///
							"& \multicolumn{2}{c}{Dish} & \multicolumn{2}{c}{Meal} " ///
							"& \multicolumn{2}{c}{Day} & \multicolumn{2}{c}{Week} " ///
							"& \multicolumn{2}{c}{Overall} \\ \cline{2-3} " ///
							"\cline{4-5} \cline{6-7} \cline{8-9} \cline{10-11} " ///
							"\\[-1.8ex] " ///
							"& \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} " ///
							"& \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} " ///
							"& \multicolumn{1}{c}{(5)} & \multicolumn{1}{c}{(6)} " ///
							"& \multicolumn{1}{c}{(7)} & \multicolumn{1}{c}{(8)} " ///
							"& \multicolumn{1}{c}{(9)} & \multicolumn{1}{c}{(10)} " ///
							"\\ \midrule") ///
							keep(treat_assign) noobs ///
							booktabs nonum nomtitle collabels(none) ///
							nobaselevels nogaps fragment label ///
							stat(dep_mean N cov r2, ///
							labels("Mean in Control" "Observations" ///
							"Covariates" "Adjusted R$^2$") ///
							fmt(%4.3f %9.0fc %4.3f)) ///
							postfoot("\hline \hline \\[-1.8ex] " ///
							"\multicolumn{11}{p{\linewidth}}{\small " ///
							"\noindent \textit{Note}: Dependent variable " ///
							"is the number of dishes, or the share of " ///
							"dishes in a given meal, day, week, etc., for " ///
							"which a solar stove was used. All regressions " ///
							"include two levels of strata fixed effects: " ///
							"village and Agricultural and Aquatic Systems " ///
							"(AAS) group. For regressions with more than one " ///
							"observation per household (columns 1-8), we " ///
							"calculate Liang-Zeger cluster-robust standard " ///
							"errors since the unit of randomization is the " ///
							"household. For regressions with only one " ///
							"observation per household (columns 9-10), we " ///
							"calculate Eicker-Huber-White (EHW) robust " ///
							"standard errors. Standard errors are presented " ///
							"in parentheses " ///
							"(*** p$<$0.001, ** p$<$0.01, * p$<$0.05).} " ///
							"\end{tabular}")
```

This table has 10 columns grouped into five outcome categories (Dish, Meal, Day, Week, Overall), each with a without-covariates and with-covariates specification. The `prehead` builds two header rows — one with grouped labels and one with column numbers — while the `postfoot` includes a detailed methodological note spanning the full table width. The `fragment` option ensures `esttab` doesn't wrap the output in its own `\begin{tabular}...\end{tabular}`, since `prehead` and `postfoot` already handle that.

> Do [Exercise 5 - Multi-Column Table with Notes]({{ site.baseurl }}/exercises/10-esttab-multi/)

### Quick reference

| Task | Command |
|---|---|
| Store results | `estimates store name` |
| Display table | `esttab m1 m2 ...` |
| Export to LaTeX | `esttab m1 m2 using "file.tex", replace booktabs` |
| Summary stats | `estpost summarize vars` → `esttab` |
| Standard errors | `se` option |
| Significance stars | `star(* 0.10 ** 0.05 *** 0.01)` |
| Keep/drop variables | `keep(...)` or `drop(...)` |
| Variable labels | `label` |
| Fixed effects indicators | `indicate("label = pattern")` |
| Model stats | `stats(N r2, labels(...) fmt(...))` |
| Column titles | `mtitles("(1)" "(2)")` |
| Custom header | `prehead("...")` |
| Custom footer | `postfoot("...")` |
| Suppress default wrapper | `fragment` |

### Summary

- `estout`/`esttab` automates the production of publication-ready tables
- The workflow is: `reg` → `estimates store` → `esttab`
- Summary statistics: `estpost summarize` → `esttab`
- Use `booktabs` and `label` for clean LaTeX output
- Export with `using "file.tex"` and include in Overleaf with `\input{}`
- Multi-column tables let readers see how results evolve across specifications
- Use `prehead` and `postfoot` with `fragment` for full control over the LaTeX table layout
- Always add notes documenting your standard error approach and significance levels

With the tools from this week — LaTeX, `coefplot`, and `esttab` — you can produce a complete, professional results section entirely from your Stata code.
