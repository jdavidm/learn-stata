* course: AAE 497A/597A
* assignment: 2
* created on: dec 25
* created by: jdm
* edited on: 23 dec 25
* edited by: jdm
* Stata v.19.5

	
********************************************************************************
**# exercise 1
********************************************************************************

* describe why data is messy - see solutions
	
	
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



********************************************************************************
**# challenge 1
********************************************************************************

* add package loop to project.do - see actual project.do file in code/ folder