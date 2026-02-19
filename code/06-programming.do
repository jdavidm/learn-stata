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

**## 4.1
	reg				yield_kg nitrogen_kg plot_area_GPS irrigated
	scalar 			rsq_yield = e(r2)
	scalar 			N_yield   = e(N)
	
	display 		"R-squared from yield regression: " rsq_yield
	display 		"N from yield regression: " N_yield
	
**## 4.2
	reg				harvest_value_USD nitrogen_kg plot_area_GPS irrigated
	local 			rsq_harv = e(r2)
	
	display 		"R-squared from harvest regression (local): `rsq_harv'"

	
********************************************************************************
**# exercise 5
********************************************************************************

**## 5.1
	tab				wave
	

**## 5.2
	forvalues 		w = 1/5 {
		display 		"------------------------"
		display 		"Summary for wave `w'"
		sum				yield_kg if wave == `w'
}

**## 5.3
	forvalues 		w = 1/5 {
		display 		"------------------------"
		display 		"Summary for wave `w'"
		sum				yield_kg if wave == `w'
		sum				nitrogen_kg if wave == `w'
}

	
********************************************************************************
**# exercise 6
********************************************************************************

**## 6.1
	foreach shock in crop_shock pests_shock rain_shock drought_shock flood_shock {
		display			"------------------------"
		display			"Shock variable: `shock'"
		tab 			`shock'
}

**## 6.2
	foreach shock in crop_shock pests_shock rain_shock drought_shock flood_shock {
		display			"------------------------"
		display			"Shock variable: `shock'"
		tab 			`shock'

    * Mean of 0/1 variable = share with value 1 (assuming coded 0/1)
		qui sum			`shock' if !missing(`shock')
		local 			share_`shock' = r(mean)

    * Print as percent with one decimal place
		display			"About " %4.1f (100*`share_`shock'') "% of plots experienced a `shock'."
}

	
********************************************************************************
**# exercise 7
********************************************************************************

**## 7.1
	local				logvars yield_kg harvest_value_USD totcons_USD
	
	foreach v of varlist `logvars' {
		gen					ln_`v' = ln(`v')
		lab var				ln_`v' "log of `v'"
		sum					ln_`v'
	}
	
**## 7.2
	local 				yvars ln_*
	local 				controls plot_area_GPS irrigated nitrogen_kg female_manager

	foreach y of varlist `yvars' {
		reg					`y' `controls'
	}
	
	
********************************************************************************
**# exercise 8
********************************************************************************

**## 8.1
	local				vars yield_kg harvest_value_USD nitrogen_kg totcons_USD
	
	foreach v of varlist `vars' {
		qui sum 			`v', detail
		local				N = r(N)
		display				`N'
	}

		
********************************************************************************
**# challenge 6
********************************************************************************

	local				vars yield_kg harvest_value_USD nitrogen_kg totcons_USD
	
	foreach v of varlist `vars' {
		qui sum 			`v', detail
		local				N = r(N)
		display				`N'
   
	if 					`N' < 63450 {
		display as txt 		"Skipping `v' (only `N' obs)"
	continue
       }
	   
       histogram 			`v', ///
								title("Distribution of `v'") ///
								xtitle("`v'")

       graph export 		"$answ/hist_`v'.png", replace
   }
   
   
   