* course: 597A
* assignment: 2
* created on: dec 25
* created by: jdm
* edited on: 23 dec 25
* edited by: jdm
* Stata v.19.5


********************************************************************************
**# set pathways
********************************************************************************

   if `"`c(username)'"' == "jdmichler" {
    global 		code  	"C:/Users/jdmichler/git/learn-stata/code"
	global 		data	"C:/Users/jdmichler/git/semester26/data"
    }

	
********************************************************************************
**# exercise 1
********************************************************************************

**## 1.1
	use				"https://haghish.github.io/github/langlist.dta", clear
	
	describe
	
**## 1.2
	use				"$data/tenuredata.dta", clear
	
	describe
	
**## 1.3
	sysuse			"auto.dta", clear
	
	describe
	
**## 1.4
	import		delimited "$data/district_size.csv", clear
	
	describe
	
	
********************************************************************************
**# exercise 2
********************************************************************************

* load data
	use				"$data/dietary_cleaned.dta", clear
	
* reshape data from long to wide
	reshape wide	cuml ss cuml_trt cuml_cnt, i(day_count) j(hh)

* create new variables for cumulative entries
	gen				cuml_cnt = cuml_cnt5 
	gen				cuml_trt = cuml_trt18 
	order			cuml_trt cuml_cnt, after(day_count)

* loop through all households (156) and drop cumulative treatment and control
	forvalues 		i = 1/156 {
		drop 		cuml_cnt`i' cuml_trt`i'
}

* fill in  missing values
	forvalues 		i = 1/156 {
		replace 		ss`i' = ss`i'[1]
}
	
* everything following needs to be run as a single code block due to locals
* create CDF for treatement
	local 			grt ""
	forvalues 		i = 1/156 {
		local 			grt `grt' line cuml`i' day_count ///
							if ss`i' == 1, lpattern(solid) lcolor(teal%20) lwidth(thin) ||
}

* create CDF for control		
	local 			grc ""
	forvalues 		i = 1/156 {
		local 			grc `grc' line cuml`i' day_count ///
							if ss`i' == 0, lpattern(dash) lcolor(sienna%20) lwidth(thin) ||
}
		
* final graph
	sort 			day_count
	twoway 			`grc' `grt' ///
	line 			cuml_cnt day_count, lc(sienna*1.5) lpattern(dash) || ///
	line			cuml_trt day_count, lc(teal*1.5) lpattern(solid)  ///
						xlabel(1 7 14 21 28 35 42) xtitle("Day in Study") ///
						graphregion(fcolor(white)) ytitle("Cumulative Distribution") ///
						title("B: Accumulation of Diary Entries Over Time") ///
						legend(pos(6) cols(2) order(314 313) ///
						label(313 "Control") label(314 "Treatment"))

						
********************************************************************************
**# exercise 3
********************************************************************************

* load auto data
	sysuse			"auto.dta", clear
	
**## 3.1
	gen				y = 1 if price <= 4195
	tab				y
	
**## 3.2
	replace			y = 3 if price >= 6342
	tab				y
	
**## 3.3
	replace			y = 2 if price > 4195 & price < 6342
	tab				y
	
**## 3.4
	global pack 	1 

	if $pack == 1 {
		display "Setup mode: running installation/setup steps..."
	}
	else {
		display "Run mode: skipping setup and continuing with the analysis."
	}

**## 3.5
	if $pack == 1 {
		display "Setup mode: running installation/setup steps..."
	}
	else if $pack == 2 {
		display "Update mode: updating ado files..."
	}
	else {
		display "Run mode: skipping setup and continuing with the analysis."
	}
	
					
********************************************************************************
**# exercise 4
********************************************************************************

* load the data from the internet
	import		delimited "https://datacarpentry.org/semester-biology/data/gainesville-precip.csv", clear
	
* create year variable
	gen			year = _n
	
* generate variable that is the mean rainfall in each each
	egen		mean_rain = rowmean(v*)
	
* create line graph of mean rainfall across years
	twoway		(line mean_rain year)