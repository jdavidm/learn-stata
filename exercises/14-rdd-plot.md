---
layout: exercise
topic: Regression Discontinuity
title: RD Plot
language: Stata
---

For all the exercises this week we use data from the nationwide rural road construction program, Pradhan Mantri Gram Sadak
Yojana (PMGSY) in India ([Garg et al., 2024](https://doi.org/10.1257/pol.20220422)). In Garg et al. (2021), the authors examine how building rural roads causes movement of workers out of agriculture and induces farmers to use fire — a labor-saving but polluting technology — to clear agricultural residue or to make harvesting less labor-intensive. Under PMGSY, villages above a population threshold were eligible for a new all-weather road. The running variable `v_pop` measures each village's population minus its state-specific threshold, so the cutoff is at zero.

Before doing any exercises, add a global to the top of this week's assignment do-file that points to the rural roads data. Because the replication package is quite large, you will be accessing it from OneDrive. The start of your path will vary depending on your computer, but it will end with `OneDrive - University of Arizona/Michler, Jeffrey David - (jdmichler)'s files - rural_roads`. 

```stata
* define rural roads data path (modify the start of the path for your computer)
	global			rr "C:/Users/YourName/OneDrive - University of Arizona/Michler, Jeffrey David - (jdmichler)'s files - rural_roads/data"
```

- Load `"$rr/gjp_main_working.dta"`.
- Use `rdplot` to create a binned-means RD plot of `fires10km` (annual fire count within 10 km) against the running variable `v_pop`, with the cutoff at 0. Restrict the range to ±250 using the `subset()` or an `if` condition (`if abs(v_pop) <= 250`), set 20 bins per side with `nbins(20 20)`, and add descriptive axis titles.

1. Export the graph and import it into your Overleaf document.

2. Is there visual evidence of a discontinuity in fire activity at the population threshold? Describe what you see.

---
