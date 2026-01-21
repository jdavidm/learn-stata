---
layout: exercise
topic: Data Management
title: Merge Data
language: Stata
---

Using the World Bank's LSMS data, we are going to practice merging datasets that represent different levels of aggregation (EA-level and household-level). Start by loading the `ea_summary.dta` file that you created in exercise 6. This will be the **master** file in memory.

1\. Use `isid` to determine what variable(s) uniquely identify the data. What are these variable(s)?

Think through the structure of the EA and household data:
- In the **EA summary** dataset, each `eaid`–`sector` combination should appear **once**.
- In the **household** dataset, each `eaid` appears many times (one row per household).  

This suggests a **one-to-many** merge: many households per EA, one EA-level summary per EA. Now merge the household data into the EA data.

2\. How many matched and unmatched observations are there?

Now each household observation contains both:
- Household-level variables (e.g., `totcons_USD`, `hh_dependency_ratio`), and  
- EA-level averages (`mean_totcons_usd`, `mean_dep_ratio`, etc.).

3\. Create a consumption gap variable called `cons_gap` that is total household consumption (USD) minus mean consumption at the EA. This measures how much a household’s consumption differs from the average consumption in its EA. Is the consumption gap larger for rural households or urban households?

**Save this merged data set as `household_ea.dta`.
