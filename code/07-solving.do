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
* - ids: hh_id_merge, plot_id_merge
* - outcome variables: harvest_kg, nitrogen_kg, total_labor_days, plot_area_GPS, irrigated

**## 1.3

* outputs:
* - one row per hh_id_merge-season
* - variables: hh_id_merge, season, mean_yield_kg, total_fert, total_labor
*              n_plots, any_irrigated
* - save as $export/hh_yield.dta

**## 1.4

* clarification questions:
* 1. should we include all seasons or only main season?
* 2. what should we do with plots that have missing inputs or plot_area_GPS?
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

**## 2.1 - identify household id

**## 2.2 - create per-plot variables (e.g., yield per hectare)

**********************************************************************
**# 3 - collapse to household-season level
**********************************************************************

**## 3.1 - aggregate yield, nitrogen, and labor

**## 3.2 - count plots and irrigated indicator

**********************************************************************
**# 4 - label and save output
**********************************************************************

**## 2.2

**## 3.1 - aggregate yield and nitrogen

* steps:
* 1. check that hh_id_merge and season uniquely identify households within a season
* 2. collapse mean yield_kg and sum nitrogen_kg to hh_id_merge-level
* 3. create a count of plots per household-season
* 4. label the new variables
	
	
********************************************************************************
**# exercise 3
********************************************************************************

**## 3.1

* basic structure check
    sum             harvest_kg nitrogen_kg total_labor_days plot_area_GPS hh_id_merge
	
**## 3.2

* create yield per hectare
    gen             yield = harvest_kg / plot_area_GPS

* quick check
    sum             yield
    *** mean 22375, min -0, max 7.51e+08

* check for missing or zero `plot_area_GPS`
    count           if plot_area_GPS == 0 | plot_area_GPS == .
    *** 3,345 missing area
	
	
********************************************************************************
**# exercise 4
********************************************************************************
	
	clear 			all
	do				"$code/projectdo.do"
	
******************************************************************
**## 4.1 - plot-level yield summaries
******************************************************************

******************************************************************
**# 1 - plot-level yield summaries
******************************************************************

* load data
*   use             "$root/plot_dataset", clear
	use				"$data/plot_dataset", clear

* create yield per hectare
 *  gen             yield_ha = harvestkg / plot_area_GPS
    gen             yield_ha = harvest_kg / plot_area_GPS

* summarize average yield for irrigated plots only, by main crop
*   bys             main_crop: sum yield_ha if irrigated = 1, details
	bys             main_crop: sum yield_ha if irrigated == 1, detail

	
******************************************************************
**# 2 - save irrigated-only data by agro-ecological zone (aez)
******************************************************************
/*

* get list of aezs
    levelsof        aez, local(agro_ecological_zone)

* loop over aezs and save a file for each
    foreach s of local agro_ecological_zone {

    * keep only irrigated plots for this aez
        keep        if agro_ecological_zone == s & irrigated == 1

    * save aez-specific file
        save        "$export/plot_yield_irr_s.dta"

    * reload data for next loop iteration
        use         "$root/plot_dataset.dta", clear
    }
*/
* get list of aezs
    levelsof        agro_ecological_zone, local(aez)

* loop over aezs and save a file for each
    foreach s of local aez {

    * keep only irrigated plots for this aez
        keep        if agro_ecological_zone == `s' & irrigated == 1

    * save aez-specific file
        save        "$data/plot_yield_irr_`s'.dta", replace

    * reload data for next loop iteration
        use         "$data/plot_dataset.dta", clear
    }


********************************************************************************
**# exercise 5
********************************************************************************
	
**## 5.1
	gen				yield_USD = harvest_value_USD / plot_area_GPS
	lab var			yield_USD "Plot yield (USD/ha)"
	
**## 5.2
	help			graph bar
	
    graph bar      (mean) yield_USD, ///
                        over(main_crop, sort(1) label(angle(45))) ///
                        ytitle("Mean yield (USD)") ///
						b1title("Main crop") ///
                        title("Mean yield (USD) by main crop") ///
                        blabel(bar, format(%9.0f) position(outside)) ///
						bar(1, color(navy%60) lcolor(navy%100))
	
	graph export	"$answ/07-s-help.png", replace
	
	
********************************************************************************
**# exercise 6
********************************************************************************
		
**## 6.1
	egen            mean_yield = mean(yield_USD), by(hh_id_merge)
	egen            tot_labor = total(total_labor_days), by(hh_id_merge)
	egen            tot_fert = total(nitrogen_kg), by(hh_id_merge)

	lab var         mean_yield "mean yield (kg/ha) by household"
	lab var         tot_labor "total labor (days) by household"
	lab var         tot_fert "total fertilizer (kg) by household"

* tag exactly one observation per zone (statalist trick)
	egen            tag_hh = tag(hh_id_merge)
	
	tab				tag_hh
	
**## 6.2
	reg				mean_yield tot_labor tot_fert if tag_hh == 1
	
	
********************************************************************************
**# exercise 7
********************************************************************************
	
	
********************************************************************************
**# challenge 7
********************************************************************************


* close the log
	log	close

/* END */