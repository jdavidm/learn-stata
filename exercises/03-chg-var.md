---
layout: exercise
topic: Data Management
title: Change Variables
language: Stata
---

Before undertaking this exercise, make sure you save the household-level version of that data that is currently in Stata's memory. Save the file into your data folder and call it `household_all.dta`. Make sure you use the option `replace` so that when you run the `.do` file again it writes over any pre-existing versions of the data.

Using the World Bank's LSMS data, use `collapse` to create an EA-level dataset (grouped by `eaid` and `sector`) that contains the following EA-level variables:
   - Mean household size: based on `hh_size` 
   - Share of households with electricity: based on `hh_electricity_access`  
   - Share of households with a nonfarm enterprise: based on `nonfarm_enterprise`  
   - Mean total consumption in USD: based on `totcons_USD`  

After the collapse, rename these variables as
   - `ea_hh_size` 
   - `ea_electricity_access`  
   - `ea_nonfarm_enterprise`  
   - `ea_totcons_USD`  

1. What is the average EA-level household size in urban and rural areas?

2. What percentage of urban households, on average, have electricity access? What percentage of rural households, on average, have electricity access? 

3. What percentage of urban households, on average, have a non-farm enterprise? What percentage of rural households, on average, have a non-farm enterprise? 

4. Is average EA-level consumption (`mean_totcons_usd`) higher in urban or rural areas?

**Save this EA-level file as `ea_summary.dta`.**