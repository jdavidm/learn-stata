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

* load data
	use             "$data/plot_dataset.dta", clear

* keep maize only (main_crop is string)
	keep            if main_crop == "MAIZE"

* base restrictions
	keep            if plot_area_GPS > 0
	keep            if harvest_kg < .
	drop            if harvest_kg <= 0

* get list of countries
	levelsof        country, local(countries)

* make sure grc1leg2 is available
	cap which       grc1leg2
	if              _rc != 0 {
		net         install grc1leg2, from("https://fmwww.bc.edu/RePEc/bocode/g") replace
	}

* locals to store graph names (separate lists)
	local           glist_rf ""
	local           glist_ir ""

	local           leg_rf   ""
	local           leg_ir   ""

* loop over countries and irrigation status (0/1)
	foreach c of local countries {

		foreach irr in 0 1 {

			preserve

			* restrict to this country + irrigation group
				keep            if country == "`c'" & irrigated == `irr'

			* skip empty groups
				count
				if              r(N) == 0 {
					restore
					continue
				}

			* winsorize harvest for graphing only (p1-p90 within group)
				_pctile         harvest_kg, p(1 90)
				local           p1  = r(r1)
				local           p90 = r(r2)

				gen             harvest_kg_g = harvest_kg
				replace         harvest_kg_g = `p1'  if harvest_kg_g < `p1'
				replace         harvest_kg_g = `p90' if harvest_kg_g > `p90'
				lab var         harvest_kg_g "harvest (kg), winsorized (p1-p90) for graph"

			* labels + short graph name
				local           irr_lbl "rainfed"
				if              `irr' == 1 local irr_lbl "irrigated"

				local           gname "g_ma_`c'_`irr'"

			* color schemes by irrigation status
				local           mcol ""
				local           lcol1 ""
				local           lcol2 ""

				if              `irr' == 0 {
					local       mcol  "navy%25"
					local       lcol1 "midblue"
					local       lcol2 "eltblue"
				}
				if              `irr' == 1 {
					local       mcol  "dkgreen%25"
					local       lcol1 "forest_green"
					local       lcol2 "lime"
				}

			* create graph (do not export individual files)
				twoway          ///
					(scatter        harvest_kg_g plot_area_GPS, ///
						msize(tiny) mcolor(`mcol') ///
						) ///
					(lfit           harvest_kg_g plot_area_GPS, ///
						lcolor(`lcol1') lwidth(medthick) ///
						) ///
					(lowess         harvest_kg_g plot_area_GPS, ///
						lcolor(`lcol2') lwidth(medthick) bwidth(.8) ///
						), ///
					title("MAIZE: harvest vs. plot area: `c' (`irr_lbl')", size(small)) ///
					xtitle("plot area (gps)", size(small)) ///
					ytitle("harvest (kg)", size(small) margin(small)) ///
					xlabel(, labsize(small)) ///
					ylabel(, labsize(small)) ///
					legend(order(1 "plots" 2 "linear fit" 3 "lowess") ///
						rows(1) position(3) ring(0) ///
						region(lstyle(none)) ///
						) ///
					name(`gname', replace)

			* add graph to the appropriate combine list
				if              `irr' == 0 {
					if          "`glist_rf'" == "" local leg_rf "`gname'"
					local       glist_rf `"`glist_rf' `gname'"'
				}
				if              `irr' == 1 {
					if          "`glist_ir'" == "" local leg_ir "`gname'"
					local       glist_ir `"`glist_ir' `gname'"'
				}

			restore
		}
	}

* combine rainfed graphs
	grc1leg2        `glist_rf', ///
		col(2) row(`rows_rf') ///
		xcommon ycommon ///
		imargin(tiny) ///
		graphregion(margin(zero)) ///
		legendfrom(`leg_rf') ///
		name(g_maize_rainfed, replace)

	graph           export "$answ/07-llm-help-2.pdf", replace

* combine irrigated graphs
	grc1leg2        `glist_ir', ///
		col(2) row(`rows_ir') ///
		xcommon ycommon ///
		imargin(tiny) ///
		graphregion(margin(zero)) ///
		legendfrom(`leg_ir') ///
		name(g_maize_irrigated, replace)

	graph           export "$answ/07-llm-help-3.pdf", replace
	

********************************************************************************
**# challenge 7
********************************************************************************

**## 9.1

* restate problem (comments only)
	* goal: create a household-level dataset (one row per hh_id_merge) from plot_dataset
	* input: $data/plot_dataset.dta (plot-level data)
	* output: household dataset + regression + three graphs (scatter, density, bar)

* steps (comments only)
	* 1) load plot data and keep maize plots only
	* 2) compute hh-level stats with egen (no collapse)
	* 3) tag one obs per hh and keep tagged rows
	* 4) check uniqueness + summarize + tabulate
	* 5) run regression and record results
	* 6) create graphs and export pdfs


**## 9.2

* load data and keep maize plots only
	use             "$data/plot_dataset.dta", clear

* keep maize only (main_crop is string)
	keep            if main_crop == "MAIZE"

* mean yield (plot-level yield_USD averaged within household)
	egen            mean_yield = mean(yield_kg), by(hh_id_merge)
	lab var         mean_yield "mean plot yield (kg) within household"

* total labor days within household
	egen            tot_labor = total(total_labor_days), by(hh_id_merge)
	lab var         tot_labor "total labor days within household"

* total nitrogen fertilizer (kg) within household
	egen            tot_fert = total(nitrogen_kg), by(hh_id_merge)
	lab var         tot_fert "total nitrogen (kg) within household"

* number of plots within household
	egen            n_plots = count(plot_id_merge), by(hh_id_merge)
	lab var         n_plots "number of plots within household (maize sample)"

* any irrigated plot within household (max of 0/1)
	egen            any_irrig = max(irrigated), by(hh_id_merge)
	replace         any_irrig = 0 if any_irrig == .
	lab var         any_irrig "any irrigated maize plot in household (0/1)"

* value labels for graphs/tables
	lab def         irrig_lbl 0 "rainfed" 1 "irrigated", replace
	lab val         any_irrig irrig_lbl

* tag and keep one row per household
	egen            tag_hh = tag(hh_id_merge)
	lab var         tag_hh "tag: 1 obs per household"

	keep            if tag_hh == 1
	keep            hh_id_merge mean_yield tot_labor tot_fert n_plots any_irrig

* count the number of observations
	count
	
**## 9.3

* confirm one row per household
	isid            hh_id_merge
	*** if this fails, you do not have one row per household

* summarize key variables
	sum             mean_yield tot_labor tot_fert n_plots
	*** yield: mean 3227
	*** labor: mean 197.2
	*** fert: mean 103.1
	*** plots: mean 1.792

* tabulate irrigation status
	tab             any_irrig
	*** 292 irrigated, 13,885 rainfed

**## 9.4

* regress mean yield on labor, fertilizer, irrigation
	reg             mean_yield tot_labor tot_fert any_irrig

* optional: display coefficient signs in the log (for your write-up)
	matrix          b = e(b)

	local           s_labor = cond(b[1,"tot_labor"] > 0, "+", cond(b[1,"tot_labor"] < 0, "-", "0"))
	local           s_fert  = cond(b[1,"tot_fert"]  > 0, "+", cond(b[1,"tot_fert"]  < 0, "-", "0"))
	local           s_irr   = cond(b[1,"any_irrig"] > 0, "+", cond(b[1,"any_irrig"] < 0, "-", "0"))

	di              "sign(tot_labor) = `s_labor'"
	di              "sign(tot_fert)  = `s_fert'"
	di              "sign(any_irrig) = `s_irr'"

**## 9.5

* scatter: mean_yield vs tot_fert with lfit
	twoway          (scatter mean_yield tot_fert, ///
						msize(small) ) ///
					(lfit mean_yield tot_fert, ///
						lwidth(medthick) ), ///
						title("maize households: mean yield vs fertilizer") ///
						xtitle("total nitrogen (kg), household") ///
						ytitle("mean plot yield (usd), household") ///
						legend(order(1 "households" 2 "linear fit") rows(1) pos(6)) 

	graph           export "$answ/07-challenge-2.png", replace

* bar chart: mean(mean_yield) by irrigation status
	graph           bar (mean) mean_yield, ///
						over(any_irrig) ///
						title("maize households: mean yield by irrigation") ///
						ytitle("mean plot yield (usd), household") 

	graph           export "$answ/07-challenge-3.png", replace


* close the log
	log	close

/* END */