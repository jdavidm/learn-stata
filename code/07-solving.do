* course: AAE 497A/597A
* assignment: 7
* created on: feb 26
* created by: jdm
* edited on: 23 feb 26
* edited by: jdm
* Stata v.19.5
	
* open log
	cap log 		close
	log using		"$logout/07-solving", append
	
	
********************************************************************************
**# exercise 1
********************************************************************************

**## 1.1

* in my own words:
* starting from plot-level data with one row per plot,
* i need to build a household-season dataset with mean yield, total nitrogen,
* number of plots, and an indicator for any irrigated plot.

**## 1.2
	use             "$data/plot_dataset.dta", clear
    describe

* inputs i need:
* - dataset: plot_dataset.dta
* - ids: hh_id_merge, season, plot_id_merge
* - outcome variables: harvest_kg, nitrogen_kg, plot_area_GPS, irrigated

**## 1.3

* outputs:
* - one row per hh_id_merge-season
* - variables: hh_id_merge, season, mean_yield_kg, total_nitrogen_kg,
*              n_plots, any_irrigated
* - save as $export/hh_season_yield.dta

**## 1.4

* clarification questions:
* 1. should we include all seasons or only main season?
* 2. what should we do with plots that have missing harvest_kg or plot_area_GPS?
* 3. should we drop households with only one plot?

	
********************************************************************************
**# exercise 2
********************************************************************************

**## 2.1

**********************************************************************
**# 1 - prepare plot-level data
**********************************************************************

**## 1.1 - load and inspect data

**## 1.2 - check keys and ids

**********************************************************************
**# 2 - construct household-season variables
**********************************************************************

**## 2.1 - create household-season id

**## 2.2 - create per-plot variables (e.g., yield per hectare)

**********************************************************************
**# 3 - collapse to household-season level
**********************************************************************

**## 3.1 - aggregate yield and nitrogen

**## 3.2 - count plots and irrigated indicator

**********************************************************************
**# 4 - label and save output
**********************************************************************

**## 2.2

**## 3.1 - aggregate yield and nitrogen

* steps:
* 1. check that hh_id_merge and season uniquely identify households within a season
* 2. collapse mean yield_kg and sum nitrogen_kg to hh_id_merge-season level
* 3. create a count of plots per household-season
* 4. label the new variables
	
********************************************************************************
**# exercise 3
********************************************************************************

**## 3.1

* load plot-level data
    use             "$data/plot_dataset.dta", clear

* basic structure check
    describe
    sum             harvest_kg nitrogen_kg plot_area_GPS hh_id_merge season
	
**## 3.2

* create yield per hectare
    gen             yield = harvest_kg / plot_area_GPS

* quick check
    sum             yield
    *** mean 22375, min -0, max 7.51e+08

* check for missing or zero `plot_area_GPS`
    count           if plot_area_GPS == 0 | plot_area_GPS == .
    *** 3,345 missing area
	
**## 3.3


**## 3.3 - create household-season id

* create combined id
    egen            hh_season_id = group(hh_id_merge season)
    lab var         hh_season_id "household-season identifier"

* spot check
    list            hh_id_merge season hh_season_id in 1/10
    *** confirm that hh_season_id is constant within each hh_id_merge-season combination
	
	
	