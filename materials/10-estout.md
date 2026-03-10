---
layout: page
element: notes
title: Producing Tables with estout
language: Stata
---

Journals, advisors, and referees expect **tables** — neatly formatted, with standard errors in parentheses, significance stars, and informative notes. Doing this by hand is tedious and error-prone. The `estout` package automates the entire process and can export complete LaTeX code ready for your Overleaf document.

This lecture covers:
- Installing `estout` and its companion `esttab`
- The `estimates store` → `esttab` workflow
- Summary statistics tables
- Single- and multi-column regression tables
- Customization: stars, labels, notes, formatting
- Exporting to LaTeX (`.tex` files)
- Integrating tables into Overleaf with `\input{}`

We'll use the maize-only `eth_allrounds_final` data for all lecture examples.

### Setup

```stata
* install estout (only need to do this once)
    ssc             install estout, replace

* load and prepare data
    use             "$data/eth_allrounds_final.dta", clear
    keep if         crop_name == "MAIZE"
    gen             fert = nitrogen_kg / plot_area_GPS
    lab var         fert "fertilizer (kg/ha)"
    gen             labor = total_labor_days / plot_area_GPS
    lab var         labor "labor (days/ha)"
    gen             seed = seed_value_USD / plot_area_GPS
    lab var         seed "seed (USD/ha)"
```

### The `estimates store` → `esttab` workflow

The core idea:

1. Run a regression with `reg`
2. Store the results with `estimates store name`
3. Repeat for additional models
4. Display all stored models in one table with `esttab`

```stata
* step 1: run and store
    reg             yield_kg fert labor, vce(cluster hh_id_obs)
    estimates       store m1

* step 2: display
    esttab          m1
```

`esttab` produces a formatted table in the Stata results window. By default it shows coefficients, standard errors, t-statistics, and significance stars.

### Summary statistics tables

Before showing regression results, most papers include a table of summary statistics. `estout` handles this with `estpost summarize`:

```stata
* summary statistics
    estpost         summarize yield_kg fert labor seed, detail

* display as a table
    esttab,         cells("count mean sd min max") ///
                        noobs nonumber nomtitle ///
                        title("Summary Statistics") ///
                        label
```

To export to LaTeX:

```stata
* export summary stats to .tex
    esttab          using "$answ/10-sumstats.tex", replace ///
                        cells("count(fmt(0)) mean(fmt(2)) sd(fmt(2)) min(fmt(1)) max(fmt(1))") ///
                        noobs nonumber nomtitle ///
                        title("Summary Statistics") ///
                        booktabs label
```

The `booktabs` option produces cleaner horizontal rules (`\toprule`, `\midrule`, `\bottomrule`) — these require `\usepackage{booktabs}` in your LaTeX preamble.

### Single regression table

```stata
* run and store a regression
    reg             yield_kg fert labor i.irr i.admin_1, ///
                        vce(cluster hh_id_obs)
    estimates       store m_full

* display with customization
    esttab          m_full, ///
                        se star(* 0.10 ** 0.05 *** 0.01) ///
                        keep(fert labor 1.irr) ///
                        label ///
                        title("Yield regression") ///
                        note("Clustered SEs at household level")
```

Key options:
- `se` — show standard errors in parentheses below coefficients
- `star(* 0.10 ** 0.05 *** 0.01)` — significance stars at conventional levels
- `keep(...)` — show only the variables of interest (hides fixed effects)
- `label` — use variable labels instead of variable names
- `title(...)` and `note(...)` — add a title and footnote

### Multi-column regression tables

This is where `esttab` really shines. Build up specifications column by column:

```stata
* model 1: baseline
    reg             yield_kg fert labor, vce(cluster hh_id_obs)
    estimates       store c1

* model 2: add irrigation
    reg             yield_kg fert labor i.irr, vce(cluster hh_id_obs)
    estimates       store c2

* model 3: add region FE
    reg             yield_kg fert labor i.irr i.admin_1, ///
                        vce(cluster hh_id_obs)
    estimates       store c3

* model 4: full specification
    reg             yield_kg fert labor seed i.irr i.intercropped ///
                        i.admin_1 i.wave, vce(cluster hh_id_obs)
    estimates       store c4

* four-column table
    esttab          c1 c2 c3 c4, ///
                        se star(* 0.10 ** 0.05 *** 0.01) ///
                        keep(fert labor seed 1.irr 1.intercropped) ///
                        order(fert labor seed 1.irr 1.intercropped) ///
                        label ///
                        mtitles("(1)" "(2)" "(3)" "(4)") ///
                        title("Yield regressions: building up specifications") ///
                        indicate("Region FE = *.admin_1" ///
                                 "Wave FE = *.wave") ///
                        note("Standard errors clustered at household level in parentheses." ///
                             "* p<0.10, ** p<0.05, *** p<0.01") ///
                        stats(N r2, labels("Observations" "R-squared") ///
                              fmt(0 3))
```

Key new options:

- `order(...)` — controls the row order of variables
- `mtitles(...)` — column headers
- `indicate(...)` — adds "Yes/No" rows showing which fixed effects are included
- `stats(N r2, ...)` — adds model statistics at the bottom
- `fmt(...)` — controls decimal formatting

> Do [Exercise 6 - Basic esttab Table]({{ site.baseurl }}/exercises/10-esttab-basic/)

### Exporting to LaTeX

To produce a `.tex` file that you can `\input{}` in Overleaf, add `using "filename.tex"`:

```stata
* export the four-column table to LaTeX
    esttab          c1 c2 c3 c4 using "$answ/10-yield-regs.tex", replace ///
                        se star(* 0.10 ** 0.05 *** 0.01) ///
                        keep(fert labor seed 1.irr 1.intercropped) ///
                        order(fert labor seed 1.irr 1.intercropped) ///
                        label booktabs ///
                        mtitles("(1)" "(2)" "(3)" "(4)") ///
                        title("Yield regressions") ///
                        indicate("Region FE = *.admin_1" ///
                                 "Wave FE = *.wave") ///
                        note("Standard errors clustered at household level in parentheses." ///
                             "\sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)") ///
                        stats(N r2, labels("Observations" "R-squared") ///
                              fmt(0 3))
```

The `booktabs` option and the `\sym{}` notation in the note produce clean LaTeX output.

Then in your Overleaf document:

```latex
\begin{table}[htbp]
    \centering
    \input{10-yield-regs.tex}
    \label{tab:yield_regs}
\end{table}
```

> Do [Exercise 7 - Multi-Column Table with Notes]({{ site.baseurl }}/exercises/10-esttab-multi/)

### More customization

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

> Do [Exercise 8 - Summary Statistics Table]({{ site.baseurl }}/exercises/10-sumstats/)

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

### Summary

- `estout`/`esttab` automates the production of publication-ready tables
- The workflow is: `reg` → `estimates store` → `esttab`
- Summary statistics: `estpost summarize` → `esttab`
- Use `booktabs` and `label` for clean LaTeX output
- Export with `using "file.tex"` and include in Overleaf with `\input{}`
- Multi-column tables let readers see how results evolve across specifications
- Always add notes documenting your standard error approach and significance levels

With the tools from this week — LaTeX, `coefplot`, and `esttab` — you can produce a complete, professional results section entirely from your Stata code.
