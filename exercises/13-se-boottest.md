---
layout: exercise
topic: Standard Errors & Inference
title: Wild Cluster Bootstrap
language: Stata
---

Clustered standard errors rely on asymptotic theory and require a large number of independent clusters (typically 40+) to be reliable. In this exercise you will test what happens when you cluster at a level with relatively few clusters, and then correct using the Wild Cluster Bootstrap.

- Using `Michler_JEEM.dta` (maize only), run the panel IV regression clustering at the **ward** level (`ward_id`) instead of the household level:

```stata
* panel iv clustered at ward level
	xtivreg2        lnyield lnbasal lntop lnseed lnaream2 pdate pdate2 ///
	                    i.year (CA = wardNGO), fe cluster(ward_id)
```

- Note the p-value on `CA` from this regression.
- Now apply the Wild Cluster Bootstrap via post-estimation to get a more reliable p-value:

```stata
* wild cluster bootstrap for CA coefficient
	boottest        CA
```

*(Note: You may need to run `ssc install boottest` first.)*

1\. How many unique wards are there in the maize sample? Is this above or below the commonly cited minimum of 40 clusters?
2\. Compare the analytical cluster-robust p-value (from `xtivreg2`) with the wild cluster bootstrap p-value (from `boottest`). Does the bootstrap make you more or less confident in the significance of the CA effect?

---
