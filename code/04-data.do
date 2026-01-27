* course: AAE 497A/597A
* assignment: 4
* created on: jan 25
* created by: jdm
* edited on: 27 jan 26
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

**## 1.1.1 & 1.1.2 & 1.1.3
	sum				wage
	
**## 1.2.1 & 1.2.2
	sum				wage, detail
	
**## 1.3.1 & 1.3.2
	sum				wage if collgrad == 1
						
						
********************************************************************************
**# exercise 3
********************************************************************************

**## 3.1
	sum				hours
	display			r(max) - r(min)

**##3.2
	sum				hours, detail
	display			r(p75) - r(p25)
	
		
********************************************************************************
**# exercise 4
********************************************************************************

**## 4.1
	hist			hours, percent
	graph export	"$answ/04-hist-1.png", replace
	
**## 4.2
	hist			hours, bin(10) percent
	graph export	"$answ/04-hist-2.png", replace
				
**## 4.3
	hist			hours, start(0) width(5) percent
	graph export	"$answ/04-hist-3.png", replace
	
**## 4.4
	hist			grade, frequency
	
	hist			grade, discrete frequency
	graph export	"$answ/04-hist-4.png", replace


********************************************************************************
**# exercise 5
********************************************************************************

**## 5.1
    kdensity 		ttl_exp
	graph export	"$answ/04-dens-1.png", replace
	
**## 5.2
    kdensity 		ttl_exp, bwidth(1)
	graph export	"$answ/04-dens-2.png", replace

**## 5.3
    kdensity 		ttl_exp, bwidth(3)
	graph export	"$answ/04-dens-3.png", replace

**## 5.4
    kdensity 		ttl_exp, normal
	graph export	"$answ/04-dens-4.png", replace

**## 5.5	
	twoway 			(histogram ttl_exp, bin(20) percent color(%60)) || ///
						(kdensity ttl_exp), ///
						title("Distribution of total work experience") ///
						xtitle("Total work experience (years)") ///
						ytitle("Percent of workers")  ///
						legend(order(1 "Histogram" 2 "Kernel density") pos(6) col(2))
	graph export	"$answ/04-dens-5.png", replace
	
		
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
**# challenge 4
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

	