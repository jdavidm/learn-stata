---
layout: exercise
topic: Tidy Data
title: Label Variables
language: Stata
---

Download the World Bank's Living Standards Measurement Survey (LSMS) [household data set](https://jdavidm.github.io/learn-stata/materials/datasets/). The data includes the following variables (among others):

- **Identifiers & structure**
  - `country` – country code  
  - `wave` – survey wave (e.g., 1, 2)  
  - `hhid` – household ID  
  - `eaid` – enumeration area ID (cluster)  
  - `season` – season of interview (e.g., lean, harvest)  

- **Location**
  - `urban` – urban (=1) or rural (=0)  
  - `admin_1`, `admin_2`, `admin_3` – administrative units  
  - `lat_modified`, `lon_modified` – household GPS coordinates  
  - `geocoords_id` – identifier for GPS cluster  

- **Household characteristics**
  - `hh_size` – household size (number of members)  
  - `hh_shock` – indicator that hh experienced a shock  
  - `hh_primary_education` – indicator: head has at least primary schooling  
  - `hh_electricity_access` – indicator: hh has electricity  
  - `hh_dependency_ratio` – dependents / working-age members  
  - `hh_formal_education` – years of formal education of the head  
  - `nonfarm_enterprise` – indicator: household runs a nonfarm enterprise  
  - `nb_fallow_plots` – number of fallow plots  
  - `nb_plots` – total number of plots  
  - `share_kg_sold` – share of agricultural production sold  

- **Welfare**
  - `totcons_LCU` – total consumption (local currency)  
  - `totcons_USD` – total consumption (USD)  
  - `cons_quint` – consumption quintile (1 = poorest, 5 = richest)  
  - `hh_asset_index` – asset index  
  - `hdds` – household dietary diversity score  

Apply the following labels to the corresponding variable

1. Country -> `country`
2. Wave number -> `wave`
3. Agricultural season -> `season`
4. Administrative level 1 -> `admin_1`
5. Administrative level 2 -> `admin_2`
6. Administrative level 3 -> `admin_3`
7. Household size -> `hh_size`
8. Was the household negatively impacted by a shock over the past 12 months? -> `hh_shock`
9. Did anyone in the household complete primary school? -> `hh_primary_education`
10. Does the household have access to electricity? -> `hh_electricity_access`
11. Household dependency ratio -> `hh_dependency_ratio`
12. Does anyone in the household posses any formal education? -> `hh_formal_education`
13. Does anyone in household own a non-farm enterprise? -> `nonfarm_enterprise`
14. Number of fallow plots under household management -> `nb_fallow_plots`
15. Number of plots under household management -> `nb_plots`
16. Share of harvest output (in kg) sold -> `share_kg_sold`
17. Consumption aggregate per capita, in LCU -> `totcons_LCU`
18. Consumption aggregate per capita, in USD -> `totcons_USD` 
19. Household consumption quintile -> `cons_quint`
20. Household asset index -> `hh_asset_index`
21. Household dietary diversity index -> `hdds`