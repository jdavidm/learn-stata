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

---

### Step 4 – Use the merged data for a simple analysis

Now each household observation contains both:

- Household-level variables (e.g., `totcons_USD`, `hh_dependency_ratio`), and  
- EA-level averages (`mean_totcons_usd`, `mean_dep_ratio`, etc.).

1. **Create a consumption gap variable**

   ```stata
   gen cons_gap = totcons_USD - mean_totcons_usd
   ```

   This measures how much a household’s consumption differs from the **average consumption in its EA**.

2. **Compare urban vs rural patterns**

   For **urban** and **rural** households separately:

   - Compute the mean of `cons_gap`.  
   - Compute the mean of `hh_dependency_ratio` and `mean_dep_ratio`.

   You may find commands like this useful:

   ```stata
   by urban: summarize cons_gap hh_dependency_ratio mean_dep_ratio
   ```

   or

   ```stata
   tabstat cons_gap hh_dependency_ratio mean_dep_ratio, by(urban) statistics(mean)
   ```

3. **Short interpretation**

   In comments in your `.do` file or a separate markdown file, briefly answer:

   - Do households in richer EAs (higher `mean_totcons_usd`) tend to have higher or lower own consumption relative to their EA mean (`cons_gap`)?  
   - Is there any visible difference in this pattern between urban and rural households?

---
