---
layout: exercise
topic: Data Management
title: Merge Data
language: Stata
---

Using the World Bank's LSMS data, 



## Part 3 – `merge` Household Data with EA-Level Summaries

**Goal:** Practice merging datasets that represent different levels of aggregation (EA-level and household-level).

You will:

1. Start from the appended household-level data `hh_allwaves.dta`.  
2. Merge it with the EA-level summary dataset `ea_summary.dta` you created in Part 1.

---

### Step 1 – Ensure EA summary dataset is available

If `ea_summary.dta` already exists from Part 1 and has the correct variables, you can skip re-creating it. Otherwise:

1. Re-open `hh_survey.dta` (or `hh_allwaves.dta` if appropriate).  
2. Run the `collapse` command from Part 1 again to generate `ea_summary.dta` with at least:

   - `eaid`  
   - `urban`  
   - `mean_hh_size`  
   - `mean_dep_ratio`  
   - `share_electricity`  
   - `share_nonfarm`  
   - `mean_totcons_usd`  

---

### Step 2 – Open the household-level data

1. Open the appended data:

   ```stata
   use "hh_allwaves.dta", clear
   ```

2. Inspect the variables `eaid` and `urban`; you will use these as **merge keys**.

---

### Step 3 – Merge EA-level summaries into the household data

Think through the structure:

- In the **household** dataset, each `eaid` appears many times (one row per household).  
- In the **EA summary** dataset, each `eaid`–`urban` combination should appear **once**.

This suggests a **many-to-one** merge: many households per EA, one EA-level summary per EA.

1. Run the merge:

   ```stata
   merge m:1 eaid urban using "ea_summary.dta"
   ```

2. Inspect the merge results using the `_merge` variable created by Stata:

   ```stata
   tab _merge
   ```

3. Confirm that:

   - Most observations are `"matched"` (usually coded as 3).  
   - There are no unexpected `master only` or `using only` observations (or explain any that appear).

4. After verification, drop `_merge`:

   ```stata
   drop _merge
   ```

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
