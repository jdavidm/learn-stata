---
layout: exercise
topic: Data Management
title: Change Variables
language: Stata
---

Using the World Bank's LSMS data, 

1\. Use `collapse` to create an EA-level dataset (grouped by `eaid` and `urban`) that contains the following EA-level variables:

   - Mean household size: based on `hh_size`  
   - Mean dependency ratio: based on `hh_dependency_ratio`  
   - Share of households with electricity: based on `hh_electricity_access`  
   - Share of households with a nonfarm enterprise: based on `nonfarm_enterprise`  
   - Mean total consumption in USD: based on `totcons_USD`  

2\. Assign clear new names to the collapsed variables, e.g.:

   - `mean_hh_size`  
   - `mean_dep_ratio`  
   - `share_electricity`  
   - `share_nonfarm`  
   - `mean_totcons_usd`  

3\. Are average EA-level consumption (`mean_totcons_usd`) and electricity access (`share_electricity`) higher in urban or rural areas?

4\. Save the EA-level dataset as `ea_summary.dta` in your data folder.
