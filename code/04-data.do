* course: AAE 497A/597A
* assignment: 4
* created on: jan 25
* created by: jdm
* edited on: 26 jan 26
* edited by: jdm
* Stata v.19.5
	
* open log
	cap log 		close
	log using		"$logout/04-data", append
	
	
********************************************************************************
**# exercise 1
********************************************************************************

* load national longitudinal survey of young women
    sysuse			nlsw88, clear
	
**## 1.1.1 & 1.1.2 & 1.1.3
	tab				race
	
**## 1.2.1 & 1.2.2
	tab				union, missing
	
	
********************************************************************************
**# exercise 2
********************************************************************************

* clean up the data - see solutions

						
********************************************************************************
**# exercise 3
********************************************************************************

* load world bank lsms data
	use				"https://jdavidm.github.io/learn-stata/data/lsms_household.dta", clear
		
* label unlabelled variables

**## 3.1 
	lab var 		country "Country"
	
**## 3.2
	lab var 		wave "Wave number"
	
**## 3.3
	lab var 		season "Agricultural season"
	
**## 3.4
	lab var 		admin_1 "Administrative level 1"
	
**## 3.5
	lab var 		admin_2 "Administrative level 2"
	
**## 3.6
	lab var 		admin_3 "Administrative level 3"
	
**## 3.7
	lab var 		hh_size "Household size"
	
**## 3.8
	lab var 		hh_shock "Was the household negatively impacted by a shock over the past 12 months?"
	
**## 3.9
	lab var 		hh_primary_education "Did anyone in the household complete primary school?"
	
**## 3.10
	lab var 		hh_electricity_access "Does the household have access to electricity?"
	
**## 3.11
	lab var 		hh_dependency_ratio "Household dependency ratio"
	
**## 3.12
	lab var 		hh_formal_education "Does anyone in the household posses any formal education?"
	
**## 3.13
	lab var 		nonfarm_enterprise "Does anyone in household own a non-farm enterprise?"
	
**## 3.14
	lab var 		nb_fallow_plots "Number of fallow plots under household management"
	
**## 3.15
	lab var 		nb_plots "Number of plots under household management"
	
**## 3.16
	lab var 		share_kg_sold "Share of harvest output (in kg) sold"
	
**## 3.17
	lab var 		totcons_LCU "Consumption aggregate per capita, in LCU"
	
**## 3.18
	lab var 		totcons_USD "Consumption aggregate per capita, in USD" 
	
**## 3.19
	lab var 		cons_quint "Household consumption quintile"
	
**## 3.20
	lab var 		hh_asset_index "Household asset index"
	
**## 3.21
	lab var 		hdds "Household dietary diversity index"
	
		
********************************************************************************
**# exercise 4
********************************************************************************

**## 4.1
	lab def			yesno 0 "No" 1 "Yes"
	
**## 4.2
	lab val			hh_shock hh_primary_education hh_electricity_access ///
						hh_formal_education nonfarm_enterprise yesno
				
**## 4.3
	gen				sector = 0 if urban == "Rural"
	replace			sector = 1 if sector == .
	lab var			sector "EA is rural or urban"
	lab def			sec_lbl 0 "Rural" 1 "Urban"
	lab val			sector sec_lbl
	drop			urban
	order			sector, after(eaid)

**## 4.4
	encode			country, gen(Country)
	drop			country
	rename			Country country
	order			country
	
**## 4.4
	encode			admin_1, gen(Admin_1)
	drop			admin_1
	rename			Admin_1 admin_1
	order			admin_1, before(admin_2)


********************************************************************************
**# exercise 5
********************************************************************************

**## 5.1
	egen			tot_plots = rowtotal(nb_plots nb_fallow_plots)
	lab var			tot_plots "Total number of plots under household management"
	sum				tot_plots

**## 5.2
	egen			meancons_USD = mean(totcons_USD), by(cons_quint)
	lab var			meancons_USD "Mean consumption per quntile (USD)"
	tab				meancons_USD

**## 5.3
	egen			max_hdds = max(hdds), by(hh_electricity_access)
	lab var			max_hdds "Max HDDS by electricity access"
	bys hh_electricity_access: ///
						sum				max_hdds
	

********************************************************************************
**# exercise 6
********************************************************************************

* save household data
	save			"$data/household_all.dta", replace

* collapse data to EA level
	collapse		(mean) hh_size totcons_USD ///
						(percent) hh_electricity_access nonfarm_enterprise, ///
						by(eaid sector)
		
* rename variables
	rename			hh_size ea_hh_size
	rename			totcons_USD ea_totcons_USD
	rename			hh_electricity_access ea_electricity_access 
	rename			nonfarm_enterprise ea_nonfarm_enterprise
		
**## 6.1
	bys sector:		sum ea_hh_size
					
**## 6.2
	bys sector:		sum ea_electricity_access
					
**## 6.3
	bys sector:		sum ea_nonfarm_enterprise
					
**## 6.4
	bys sector:		sum ea_totcons_USD

* save file
	save			"$data/ea_summary.dta", replace


********************************************************************************
**# exercise 7
********************************************************************************

**## 7.1
	
* load data
	use				"$data/household_all.dta", clear

* keep only wave 1
	keep if			wave == 1
	
* save new file
	save			"$data/hh_wave1.dta", replace

**## 7.2

* load data
	use				"$data/household_all.dta", clear

* keep only wave 2
	keep if			wave == 2
	
* save new file
	save			"$data/hh_wave2.dta", replace
	
**## 7.3
	append			using "$data/hh_wave1.dta"

	
********************************************************************************
**# exercise 8
********************************************************************************

* load data
	use				"$data/ea_summary.dta", clear

**## 8.1
	isid			eaid sector
	
**## 8.2
	merge 1:m		eaid sector using "$data/household_all.dta"
	
	
**## 8.3
	gen				cons_gap = totcons_USD - ea_totcons_USD
	
	sum				cons_gap
	
	
********************************************************************************
**# challenge 3
********************************************************************************

* create indicator for sign of poverty gap	
	gen				gap = 1 if cons_gap < 0
	replace			gap = 0 if cons_gap >= 0 & cons_gap != .
	
* label variable and values
	lab var			gap "Indicator for sign of consumption gap"
	lab def			gap_lbl 0 "Positive Gap" 1 "Negative Gap"
	lab val			gap gap_lbl
	
* count number of households above and below and label
	egen			below = total(gap), by(eaid sector)
	lab var			below "Number of households below mean consumption"
	
	egen			above = total(gap == 0), by(eaid sector)
	lab var			below "Number of households above mean consumption"
	
* count number of households in an EA
	egen 			tot_hh = count(gap), by(eaid sector)
	lab var			tot_hh "Total number of households in EA"
	
* create variable for share of households above/below
	gen				share_below = below / tot_hh
	lab var			share_below "Percentage of households in EA below mean consumption"
	
* summerize share below by sector and country
	bys sector: 	sum share_below
	bys country: 	sum share_below
	

* close the log
	log	close

/* END */

	