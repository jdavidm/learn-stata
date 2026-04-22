---
layout: exercise
topic: Regression Discontinuity
title: Density Test
language: Stata
---

If villages can manipulate their population to cross the eligibility threshold, the quasi-random assignment at the cutoff breaks down. We test for manipulation by checking whether the density of the running variable is smooth at the cutoff.

- Load `"$rr/pmgsy_runningvar.dta"` (this file contains the running variable for the full universe of villages, not just the analysis sample).
- Keep observations within ±500 of the threshold (`abs(v_pop) <= 500`).
- Run the McCrary density test using the `dc_density` command (make sure you've downloaded it from the course website and copied the `dc_density` program into your `ado` directory):

*(Note: this will automatically run the test and export the graph. If you have an earlier `dc_density` graph, you may get a "already exists" error on the generated variables; you can type `cap drop Xj Yj r0 fhat se_fhat` before running it).*

```stata
* run density test
	dc_density      v_pop, breakpoint(0) ///
						generate(Xj Yj r0 fhat se_fhat) ///
						graphname("$answ/14-rdd-density-1.png")

```

1\. Export the graph and import it into your Overleaf document.

- Next, to match the formatting of our other graphs, create a standard histogram of the running variable with a vertical line at the cutoff:

```stata
* custom histogram of running variable
	twoway         (histogram v_pop if v_pop < 0, ///
                        width(10) color(navy%50)) ///
                        (histogram v_pop if v_pop >= 0, ///
                        width(10) color(maroon%50)), ///
                        xline(0, lcolor(black) lpattern(dash)) ///
                        xtitle("Population minus threshold") ///
                        ytitle("Density") ///
                        legend(order(1 "Below" 2 "Above") ///
                            ring(0) pos(1)) ///
                        graphregion(color(white))
	graph export	"$answ/14-rdd-density-2.png", replace
```

2\. Export the histogram and import it into your Overleaf document.

3\. What is the estimated log-difference in height at the cutoff (the parameter `theta` in the McCrary test output) and its standard error? Is there evidence of manipulation?

---
