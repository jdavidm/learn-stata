* course: AAE 497A/597A
* assignment: 6
* created on: feb 26
* created by: jdm
* edited on: 18 feb 26
* edited by: jdm
* Stata v.19.5
	
* open log
	cap log 		close
	log using		"$logout/06-programming", append
	
	
********************************************************************************
**# exercise 1
********************************************************************************

* load ethiopia plot data
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
	local			sd_yield = r(sd)
	
	gen				yield_std = (yield_kg - `mean_yield')/`sd_yield'
	
	sum				yield_std
	
**## 2.2
	di				"Mean yield on Ethiopian plots is `mean_yield' kg with standard deviation of `sd_yield' kg."
	
	
********************************************************************************
**# exercise 3
********************************************************************************

**## 3.1
	global 			lg_cut = 1
	
	gen 			lg_plot = plot_area_GPS > $lg_cut
	lab var 		lg_plot "= 1 if plot area > 1 ha"
	
	tab				lg_plot
	
**## 3.2
	sum				yield_kg if lg_plot == 1
	sum				yield_kg if lg_plot == 0
	
**## 3.3
	do				"$code/00_main.do"

********************************************************************************
**# exercise 4
********************************************************************************
	/*
	sysuse			auto, clear
	
* run a regression
    reg             price mpg weight

* store the R-squared in a scalar
    scalar          rsq_price = e(r2)

* use it later
    display         "R-squared from price model: " rsq_price
	
* store in a local instead
    local           rsq_local = e(r2)
    display         "R-squared (local macro): `rsq_local'"

