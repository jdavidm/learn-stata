---
layout: exercise
topic: Standard Errors & Inference
title: Failing with Few Clusters
language: Stata
---

What if our data is clustered? For example, countries might be clustered within `region`. As we learned previously, we can use `vce(cluster region)`. However, clustered standard errors rely on asymptotic theory—they require a *large number of clusters* (typically $>40$) to be accurate. 

Our dataset only has 3 regions! This means `vce(cluster)` will severely miscalculate the standard error. The solution is the **Wild Cluster Bootstrap**, a computationally intensive method deployed using David Roodman's `boottest` package.

*(Note: You may need to run `ssc install boottest` first).*

- Run the standard clustered regression:

```stata
* clustered regression
	reg             lexp gnppc, vce(cluster region)
```

- Note the p-value on `gnppc`. Is it surprisingly small?
- Now run the wild cluster bootstrap via post-estimation on that variable:

```stata
* wild cluster bootstrap
	boottest        gnppc
```

1. Does having only 3 clusters inflate our standard significance initially, or does wild bootstrapping confirm we are highly significant?

---
