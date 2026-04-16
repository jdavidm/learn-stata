---
layout: exercise
topic: Standard Errors
title: Wild Cluster Bootstrap
language: Stata
---

Clustered standard errors rely on asymptotic theory and require a large number of independent clusters (typically 42+) to be reliable. In this exercise you will test what happens when you cluster at a level with relatively few clusters, and then correct using the Wild Cluster Bootstrap.

- Using `Michler_JEEM.dta` (maize only), run the pooled IV regression clustering at the **ward** level (`ward_id`) instead of the household level.
- Now apply the Wild Cluster Bootstrap via post-estimation to get a more reliable p-value:


1. Adapt the table code from Exercise 5 to add a sixth and seventh column for the bootstrap results and export to Overleaf.
2. How many unique wards are there in the maize sample? Is this above or below the commonly cited minimum of 40 clusters?
3. Compare the analytical cluster-robust p-value with the wild cluster bootstrap p-value. Does the bootstrap make you more or less confident in the significance of the CA effect?

---
