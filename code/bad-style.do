* project: learn stata
* created on: dec 2025
* created by: jdm
* edited by: jdm
* edited on: 23 dec 25
* stata v.19.5

* does
	* exercise 2.2 - format the code
	* inputs cleaned dietary data
	* produces figure of diary entries per treatment

* assumes
	* access to cleaned dietary data

	
***********************************************************************
**# 0 - setup
***********************************************************************

* define
	global				data	=	"C:/Users/jdmichler/git/semester26/data"
	global				logout	=	"C:/Users/jdmichler/git/semester26/log"

* open log
	cap log 			close 
	log using			"$logout/exercise_2_2", append
	
	
***********************************************************************
**# 1 - create graph
***********************************************************************

use	"$data/dietary_cleaned.dta", clear	
reshape wide cuml ss cuml_trt cuml_cnt, i(day_count) j(hh)
gen	cuml_cnt = cuml_cnt5 
gen	cuml_trt = cuml_trt18 
order cuml_trt cuml_cnt, after(day_count)
forvalues i = 1/156 {
drop cuml_cnt`i' cuml_trt`i'
}
forvalues i = 1/156 {
replace ss`i' = ss`i'[1]
}	
local grt ""
forvalues i = 1/156 {
local grt `grt' line cuml`i' day_count ///
if ss`i' == 1, lpattern(solid) lcolor(teal%20) lwidth(thin) ||
}
local grc ""
forvalues i = 1/156 {
local grc `grc' line cuml`i' day_count ///
if ss`i' == 0, lpattern(dash) lcolor(sienna%20) lwidth(thin) ||
}
sort day_count
twoway 	`grc' `grt' line cuml_cnt day_count, lc(sienna*1.5) lpattern(dash) || line cuml_trt day_count, lc(teal*1.5) lpattern(solid) xlabel(1 7 14 21 28 35 42) xtitle("Day in Study") graphregion(fcolor(white)) ytitle("Cumulative Distribution") title("Accumulation of Diary Entries Over Time") legend(pos(6) cols(2) order(314 313) label(313 "Control") label(314 "Treatment"))
			
log	close
	
/* END */
