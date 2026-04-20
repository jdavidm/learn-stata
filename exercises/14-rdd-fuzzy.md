---
layout: exercise
topic: Regression Discontinuity
title: Fuzzy RDD
language: Stata
---

Now we estimate the fuzzy RD — the causal effect of **actually receiving a road** on fire activity and air pollution. Following the IV logic from [Week 13]({{ site.baseurl }}/materials/13-iv/), we use the population threshold `t` as an instrument for `receivedroad`.

- Load `"$rr/gjp_main_working.dta"`.
- Define the baseline controls (same global as Exercise 4).
- Run the fuzzy RD for fires using `ivreghdfe`:

```stata
* fuzzy rd - fires
	ivreghdfe		fires10km (receivedroad = t) left right ///
						fires2001_10km $blcontrols ///
						[aw = kernel_tri_ik], ///
						a(year dist_thresh_id) cluster(village_id)
	eststo			iv_fires
	su				fires10km if e(sample) & t == 0
	estadd scalar	depvarmean = r(mean)
```

- Run the same specification for `pm25` (replace `fires10km` with `pm25` and `fires2001_10km` with `pm25_bl2001` as the baseline control). Store as `iv_pm`.
- Make sure you still have the reduced-form estimates from Exercise 2 (`rf2`) and the first-stage estimate from Exercise 4 (`fs`) stored. Export a four-column table:

```stata
* four-column table
	esttab			fs rf2 iv_fires iv_pm ///
						using "$answ/14-rdd-fuzzy.tex", replace ///
						b(3) se(3) ///
						keep(t receivedroad) ///
						coeflabels(t "Above threshold" ///
							receivedroad "Road built") ///
						star(* 0.10 ** 0.05 *** 0.01) ///
						mtitles("Road" "Fires" "Fires" "PM 2.5") ///
						stats(N depvarmean, ///
							labels("Observations" ///
								"Control group mean") ///
							fmt(0 2)) ///
						noobs booktabs nonum collabels(none) ///
						nobaselevels nogaps fragment label ///
						prehead("\begin{tabular}{l*{4}{c}} " ///
							"\\[-1.8ex]\hline \hline \\[-1.8ex] " ///
							"& \multicolumn{1}{c}{1st Stage} " ///
							"& \multicolumn{1}{c}{RF} " ///
							"& \multicolumn{2}{c}{Fuzzy RD (IV)}" ///
							" \\ \midrule") ///
						postfoot("\hline \hline \\[-1.8ex] " ///
							"\multicolumn{5}{p{\linewidth}}{\small " ///
							"\noindent \textit{Note}: All models " ///
							"include baseline controls, " ///
							"district-threshold and year FE, and " ///
							"triangular kernel weights. Std.\ errors " ///
							"clustered at village level. " ///
							"* p$<$0.10, ** p$<$0.05, " ///
							"*** p$<$0.01.} " ///
							"\end{tabular}")
```

1\. How does the IV (fuzzy RD) fire estimate compare to the reduced-form estimate from Exercise 2? Why are they different? (*Hint*: think about the first-stage coefficient.)

2\. Does road construction increase or decrease air pollution? Is this consistent with the direction of the fire effect?

---
