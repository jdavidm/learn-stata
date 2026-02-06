* course: AAE 497A/597A
* assignment: 5
* created on: feb 26
* created by: jdm
* edited on: 6 feb 26
* edited by: jdm
* Stata v.19.5
	
* open log
	cap log 		close
	log using		"$logout/05-datarlt", append
	
	
********************************************************************************
**# exercise 1
********************************************************************************

* load national longitudinal survey of young women
    use				"$data/eth_allrounds_final.dta", clear
	
**## 1.1
    scatter 		harvest_value_USD farm_size, ///
						title("Harvest value vs farm size") ///
						xtitle("Farm size") ///
						ytitle("Harvest value (USD)")
	graph export	"$answ/05-bscatter-1.png", replace
	
**## 1.2
    scatter 		harvest_value_USD farm_size, ///
						title("Harvest value vs farm size") ///
						xtitle("Farm size") ///
						ytitle("Harvest value (USD)") ///
						msymbol(diamond) mcolor(blue) ///
						msize(tiny)
	graph export	"$answ/05-bscatter-2.png", replace
	
	
********************************************************************************
**# exercise 2
********************************************************************************

**## 2.1
     twoway			(scatter harvest_value_USD farm_size if irr == 1, ///
						mcolor(navy)) || ///
					(scatter harvest_value_USD farm_size if irr == 0, ///
						mcolor(maroon)), ///
						title("Harvest value vs farm size") ///
						xtitle("Farm size") ///
						ytitle("Harvest value (USD)")
	graph export	"$answ/05-gscatter-1.png", replace
	
**## 2.2
     twoway			(scatter harvest_value_USD farm_size), by(irr) ///
						title("Harvest value vs farm size") ///
						xtitle("Farm size") ///
						ytitle("Harvest value (USD)")
	graph export	"$answ/05-gscatter-2.png", replace
	 
**## 2.3
	* see solutions
			
			
********************************************************************************
**# exercise 3
********************************************************************************

**## 3.1
	sum				total_hired_labor_days if improved == 1, detail

	sum				total_hired_labor_days if improved == 0, detail

**##3.2
	twoway			(kdensity total_hired_labor_days if improved == 1) || ///
					(kdensity total_hired_labor_days if improved == 0)
	
		
********************************************************************************
**# exercise 4
********************************************************************************

**## 4.1
	tabstat				harvest_kg, by(plot_owned)

**## 4.2
	graph bar			harvest_value_USD, by(main_crop)
	tabstat				harvest_value_USD, by(main_crop)
	
	
********************************************************************************
**# exercise 5
********************************************************************************

**## 5.1
	xtile				asset_q = hh_asset_index, nq(4)
	lab var				asset_q "Asset Quartiles"
	bys asset_q: ///
		sum					harvest_value_USD
	
**## 5.2
	graph hbar 			(mean) harvest_value_USD, over(asset_q) over(crop_shock) ///
							ytitle("Mean Harvest Value (USD)") asyvars ///
							title("Harvest Value by Asset Group") ///
							bar(1, color(navy*3) ) bar(2, color(forest_green) ) ///
							bar(3, color(sienna) ) bar(4, color(maroon) ) ///
							legend(pos(6) col(4) order(1 "Lowest" 2 "Lower Middle" ///
							3 "Upper Middle" 4 "Highest"))			
	graph export	"$answ/05-ConMcs-2.png", replace
		
********************************************************************************
**# exercise 6
********************************************************************************

**## 6.1
	twoway			(scatter yield_kg inorganic_fertilizer_value_USD if crop == 3, ///
						msymbol(Oh) msize(vsmall) ) || ///
					(lfitci yield_kg inorganic_fertilizer_value_USD if crop == 3, ///
						lcolor(maroon) lpattern(solid) fcolor(gray%50) ///
						xtitle("Inorganic Fertilizer (USD)") ytitle("Maize YIeld (kg)")), ///
						legend( pos(6) col(3))		
	graph export	"$answ/05-lfit-1.png", replace

	

********************************************************************************
**# exercise 7
********************************************************************************

**## 7.1


						
********************************************************************************
**# exercise 8
********************************************************************************
	
	
********************************************************************************
**# challenge 5
********************************************************************************


* close the log
	log	close

/* END */

	