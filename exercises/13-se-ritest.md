---
layout: exercise
topic: Standard Errors
title: Randomization Inference
language: Stata
---

If standard errors are theoretically messy or you want a fully non-parametric p-value, you can bypass the standard error calculation entirely using Randomization Inference (RI). RI randomly permutes the treatment variable thousands of times, generating a distribution of placebo coefficients. Your actual coefficient is then compared against this distribution.

- Using `Michler_JEEM.dta` (maize only), first run the OLS regression of `lnyield` on `CA` with the same controls (`lnbasal lntop lnseed lnaream2 pdate pdate2 i.year`), clustering at `rc`, and save the true coefficient on `CA` in a local called `true_b`.
- Run `ritest` to permute `CA` 1,000 times setting the seed at 0 and then save (`saving`) the permutation distribution in a file called `ri_yield`.
- Finally, save the p-value from the randomization inference in a local called `ri_p`.

```stata
* save ri p-value
	matrix          pvalues = r(p)
	local           ri_p = pvalues[1,1]
	local           ri_p : di %5.3f `ri_p'
```

1\. Load the saved permutation data and create a kernel density plot of the placebo distribution, marking the true coefficient and the RI p-value and output it to your Overleaf file.

```stata
* plot permutation distribution
	twoway          (kdensity _pm_1, lwidth(medthick) ///
	                    lcolor(sky) lpattern(dash)), ///
	                    ytitle("Density") ///
	                    xtitle("Hypothetical treatment effect estimate") ///
	                    title("CA effect on yield (t/ha)") ///
	                    xline(`true_b', lpattern(solid) ///
	                        lwidth(thin) lcolor(sky)) ///
	                    text(.18 `=`true_b'-.01' "CA TE", ///
	                        color(sky) j(left) size(vsmall) ///
	                        place(nw) orient(vertical)) ///
	                    text(2.2 `=`true_b'-.01' ///
	                        "p-value = `ri_p'", color(sky) ///
	                        j(left) size(vsmall) place(nw) ///
	                        orient(vertical)) ///
	                    legend(off)
	graph export    "$answ/13-ri-kdensity.png", replace
```

2\. What is the RI p-value?
3\. How does the RI p-value compare to the p-value from the standard `ivreg2` regression?

---
