---
layout: exercise
topic: Regression Discontinuity
title: Using `rdrobust`
language: Stata
---

In this exercise you will use the `rdrobust` package for data-driven bandwidth selection and then check how sensitive the estimate is to bandwidth choice — the RDD equivalent of the specification charts from [Week 10]({{ site.baseurl }}/materials/10-coefplot/).

- Load `"$rr/gjp_main_working.dta"` and keep only `year == 2012`.
- Run `rdrobust fires10km v_pop, c(0)` and note the conventional estimate, the bias-corrected estimate, and the optimal bandwidth selected.
- Now check bandwidth sensitivity. Loop over a set of bandwidths (25, 50, 75, 100, 150, 200) and store the conventional estimate and confidence interval at each bandwidth. Use the code below as a template:

```stata
* bandwidth sensitivity
	matrix			bw_results = J(6, 4, .)
	local			bandwidths 25 50 75 100 150 200
	local			row = 1

	foreach bw of local bandwidths {
		rdrobust	fires10km v_pop, c(0) h(`bw')
		matrix		bw_results[`row', 1] = `bw'
		matrix		bw_results[`row', 2] = e(tau_cl)
		matrix		bw_results[`row', 3] = e(ci_l_cl)
		matrix		bw_results[`row', 4] = e(ci_r_cl)
		local		++row
	}
```

- Convert the matrix to a dataset and create a `coefplot`-style graph showing the point estimate ± 95% CI at each bandwidth. Add a horizontal reference line at zero. Export the figure and import it into your Overleaf document.

```stata
* convert matrix to dataset for plotting
	preserve
	clear
	svmat			bw_results
	rename			(bw_results1 bw_results2 bw_results3 bw_results4) ///
						(bandwidth estimate ci_lo ci_hi)

	twoway			(rcap ci_lo ci_hi bandwidth, lcolor(navy)) ///
						(scatter estimate bandwidth, ///
						mcolor(navy) msymbol(circle)), ///
						yline(0, lcolor(maroon) lpattern(dash)) ///
						ytitle("RD Estimate") ///
						xtitle("Bandwidth") ///
						legend(off) ///
						graphregion(color(white))
	graph export	"$answ/14-rdd-bw.png", replace
	restore
```

1\. What bandwidth does `rdrobust` select by default? How many observations fall within that bandwidth?

2\. Is the fire-count estimate stable as you widen the bandwidth, or does it change substantially?

---
