---
layout: exercise
topic: Regression Discontinuity
title: Challenge 14
language: Stata
---

This challenge ties together the full RDD workflow from the week: first stage, reduced form, fuzzy RD, bandwidth sensitivity, and subgroup analysis. You will replicate parts of the main results from Garg (2021) and present them in publication-quality tables and figures.

#### Part 1 — Replicate Table 2

Replicate the core results of Table 2 from Garg (2021). The table has five columns: (1) first stage, (2) reduced-form fires, (3) IV fires, (4) reduced-form PM 2.5, and (5) IV PM 2.5.

- Load `"$rr/gjp_main_working.dta"`.
- Define the baseline controls (same as previous exercises).
- Run the following five specifications, all with triangular kernel weights, district-threshold and year FE, and standard errors clustered at the village level:
  1. **First stage**: `reghdfe receivedroad t left right $blcontrols [aw = kernel_tri_ik], a(year dist_thresh_id) vce(cluster village_id)`. Store as `fs`. Save the control-group mean of `receivedroad` (for villages where `t == 0`).
  2. **Reduced-form fires**: `reghdfe fires10km t left right fires2001_10km $blcontrols [aw = kernel_tri_ik], a(year dist_thresh_id) cluster(village_id)`. Store as `rf_fires`. Save the control-group mean of `fires10km`.
  3. **IV fires**: `ivreghdfe fires10km (receivedroad = t) left right fires2001_10km $blcontrols [aw = kernel_tri_ik], a(year dist_thresh_id) cluster(village_id)`. Store as `iv_fires`. Save the control-group mean.
  4. **Reduced-form PM 2.5**: Same as (2) but with `pm25` and baseline `pm25_bl2001`. Store as `rf_pm`.
  5. **IV PM 2.5**: Same as (3) but with `pm25` and baseline `pm25_bl2001`. Store as `iv_pm`.
- For each model, use `estadd scalar depvarmean = r(mean)` to attach the control-group mean.
- Export all five columns to a single LaTeX table:

```stata
* export table 2 replication
	esttab			fs rf_fires iv_fires rf_pm iv_pm ///
						using "$answ/14-challenge-tab2.tex", replace ///
						b(3) se(3) ///
						keep(t receivedroad) ///
						coeflabels(t "Above threshold" ///
							receivedroad "Road built") ///
						star(* 0.10 ** 0.05 *** 0.01) ///
						mgroups("Road" "Annual fire activity" ///
							"Annual average PM 2.5", ///
							pattern(1 1 0 1 0) ///
							prefix(\multicolumn{@span}{c}{) ///
							suffix(}) span ///
							erepeat(\cmidrule(lr){@span})) ///
						mtitles("1st stage" "RF" "IV" "RF" "IV") ///
						stats(N depvarmean, ///
							labels("Observations" ///
								"Control group mean") ///
							fmt(0 2)) ///
						noobs booktabs nonum collabels(none) ///
						nobaselevels nogaps fragment label ///
						prehead("\begin{tabular}{l*{5}{c}} " ///
							"\\[-1.8ex]\hline \hline \\[-1.8ex]") ///
						postfoot("\hline \hline \\[-1.8ex] " ///
							"\multicolumn{6}{p{\linewidth}}{\small " ///
							"\noindent \textit{Note}: All models " ///
							"include baseline controls, " ///
							"district-threshold and year FE, and " ///
							"triangular kernel weights. Std.\ errors " ///
							"clustered at village level. " ///
							"* p$<$0.10, ** p$<$0.05, " ///
							"*** p$<$0.01.} " ///
							"\end{tabular}")
```

#### Part 2 — Bandwidth Sensitivity

- Using the IV fires specification from Part 1, re-estimate the model at several bandwidth windows. You can impose different bandwidths by restricting the sample to `abs(v_pop) <= bw`. Loop over bandwidths of 25, 50, 75, 100, 150, 200, and 250:

```stata
* bandwidth sensitivity for IV fires
	matrix			bw_iv = J(7, 4, .)
	local			bws 25 50 75 100 150 200 250
	local			row = 1

	foreach bw of local bws {
		cap noisily ivreghdfe fires10km (receivedroad = t) ///
						left right fires2001_10km $blcontrols ///
						if abs(v_pop) <= `bw', ///
						a(year dist_thresh_id) cluster(village_id)
		if _rc == 0 {
			matrix	bw_iv[`row', 1] = `bw'
			matrix	bw_iv[`row', 2] = _b[receivedroad]
			matrix	bw_iv[`row', 3] = _b[receivedroad] - ///
						1.96 * _se[receivedroad]
			matrix	bw_iv[`row', 4] = _b[receivedroad] + ///
						1.96 * _se[receivedroad]
		}
		local		++row
	}
```

- Convert the matrix to a dataset and create a coefficient plot showing the IV estimate ± 95% CI at each bandwidth. Add a horizontal reference line at zero and a vertical reference line at the IK default bandwidth (look up what `rdrobust` chose in Exercise 3). Export and import into Overleaf.

#### Part 3 — Subgroup Analysis

The paper argues that road access increases agricultural fires because roads reduce the cost of transporting crops to market, making mechanized harvesting (which leaves flammable stubble) more profitable. This mechanism should be strongest in areas that grow crops whose residue is commonly burned (rice and sugarcane).

- Using the main working data, create indicators for "high rice or high sugar" districts — the variables `rice_hi` and `sugar_hi` are already defined in the dataset (created during the merge step). Generate a combined indicator:

```stata
* subgroup indicators
	gen				burning_crops = (rice_hi == 1 | sugar_hi == 1)
```

- Re-run the IV fires and IV PM 2.5 specifications separately for `burning_crops == 1` and `burning_crops == 0`. Store as `iv_fires_hi`, `iv_pm_hi`, `iv_fires_lo`, `iv_pm_lo`. Save the control-group mean for each.
- Export a four-column table to LaTeX:

```stata
* subgroup table
	esttab			iv_fires_hi iv_pm_hi iv_fires_lo iv_pm_lo ///
						using "$answ/14-challenge-subgroup.tex", ///
						replace ///
						b(3) se(3) ///
						keep(receivedroad) ///
						coeflabels(receivedroad "Road built") ///
						star(* 0.10 ** 0.05 *** 0.01) ///
						mgroups("High rice/sugar" ///
							"Low rice/sugar", ///
							pattern(1 0 1 0) ///
							prefix(\multicolumn{@span}{c}{) ///
							suffix(}) span ///
							erepeat(\cmidrule(lr){@span})) ///
						mtitles("Fires" "PM 2.5" ///
							"Fires" "PM 2.5") ///
						stats(N depvarmean, ///
							labels("Observations" ///
								"Control group mean") ///
							fmt(0 2)) ///
						noobs booktabs nonum collabels(none) ///
						nobaselevels nogaps fragment label ///
						prehead("\begin{tabular}{l*{4}{c}} " ///
							"\\[-1.8ex]\hline \hline \\[-1.8ex]") ///
						postfoot("\hline \hline \\[-1.8ex] " ///
							"\multicolumn{5}{p{\linewidth}}{\small " ///
							"\noindent \textit{Note}: All models " ///
							"include baseline controls, " ///
							"district-threshold and year FE. " ///
							"Std.\ errors clustered at village " ///
							"level. " ///
							"* p$<$0.10, ** p$<$0.05, " ///
							"*** p$<$0.01.} " ///
							"\end{tabular}")
```

#### Part 4 — Interpretation

1. Does the effect of road construction on fires concentrate in high rice/sugar regions? What does that tell you about the *mechanism* linking roads to fires?
2. Why is the subgroup analysis informative for the paper's argument, and how does it differ from simply adding an interaction term?

---
