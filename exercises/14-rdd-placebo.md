---
layout: exercise
topic: Regression Discontinuity
title: Placebo Outcomes
language: Stata
---

If the RDD is valid, baseline covariates — things determined *before* treatment — should not jump at the cutoff. This is the RDD analogue of the balance checks you would run in an experiment or the pre-trend tests in DiD ([Week 12]({{ site.baseurl }}/materials/12-event-studies/)).

- Load `"$rr/gjp_main_working.dta"` and keep only `year == 2012`.
- Define the list of baseline covariates to test:

```stata
* placebo outcome list
	local			placebos primary_school med_center elect ///
						tdist irr_share ln_land pc01_lit_share ///
						pc01_sc_share bpl_landed_share ///
						bpl_inc_source_sub_share bpl_inc_250plus
```

- Loop over each variable in the list and run `rdrobust` with that variable as the outcome and `v_pop` as the running variable (cutoff at 0). Store estimates in a matrix for plotting:

```stata
* run placebo tests
	local			nvars : word count `placebos'
	matrix			placebo_res = J(`nvars', 3, .)
	matrix rownames	placebo_res = `placebos'
	local			row = 1

	foreach var of local placebos {
		qui rdrobust	`var' v_pop, c(0)
		matrix		placebo_res[`row', 1] = e(tau_cl)
		matrix		placebo_res[`row', 2] = e(ci_l_cl)
		matrix		placebo_res[`row', 3] = e(ci_r_cl)
		local		++row
	}
```

- Convert the matrix to a dataset and create a coefficient plot of all placebo estimates with 95% CIs and a vertical reference line at zero. Export and import into your Overleaf document:

```stata
* convert to dataset for plotting
	preserve
	clear
	svmat			placebo_res
	rename			(placebo_res1 placebo_res2 placebo_res3) ///
						(estimate ci_lo ci_hi)
	gen				id = _n
	local			row = 1
	foreach var of local placebos {
		label define	idlbl `row' "`var'", add
		local			++row
	}
	label values	id idlbl

	twoway			(rcap ci_lo ci_hi id, horizontal ///
						lcolor(navy)) ///
						(scatter id estimate, ///
						mcolor(navy) msymbol(circle)), ///
						xline(0, lcolor(maroon) lpattern(dash)) ///
						xtitle("RD Estimate") ///
						ytitle("") ///
						ylabel(1/`nvars', valuelabel angle(0) ///
							labsize(vsmall)) ///
						legend(off) ///
						graphregion(color(white))
	graph export	"$answ/14-rdd-placebo.png", replace
	restore
```

1\. Do any baseline covariates show a statistically significant discontinuity at the 5% level?

2\. If one out of eleven variables is significant at the 10% level, is that a concern? Why or why not? (*Hint*: think about what you would expect by random chance when running multiple tests.)

---
