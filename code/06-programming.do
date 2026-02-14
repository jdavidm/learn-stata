* course: AAE 497A/597A
* assignment: 6
* created on: feb 26
* created by: jdm
* edited on: 14 feb 26
* edited by: jdm
* Stata v.19.5
	
* open log
	cap log 		close
	log using		"$logout/06-programming", append
	
	
********************************************************************************
**# exercise 1
********************************************************************************

* load national longitudinal survey of young women
    use				"$data/eth_allrounds_final.dta", clear
	
**## 1.1	

* set local for controls
	local			controls crop_shock irrigated hh_asset_index
	
* regress yield
	reg				yield_kg nitrogen_kg `controls' if crop_name == "MAIZE"

**## 1.2	

* set local for controls
	local			controls crop_shock irrigated hh_asset_index female_manager
	
* regress yield
	reg				yield_kg nitrogen_kg `controls' if crop_name == "MAIZE"
	
	
********************************************************************************
**# exercise 2
********************************************************************************

**## 2.1
	sum				yield_kg
	local			mean_yield = r(mean)
	local			sd_yield - r(sd)