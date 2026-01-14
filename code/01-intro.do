* course: AAE 497A/597A
* assignment: 1
* created on: dec 25
* created by: jdm
* edited on: 9 dec 25
* edited by: jdm
* Stata v.19.5


********************************************************************************
**# exercise 1
********************************************************************************

**## 1.1
	display			2 - 10
	
**## 1.2
	display			3 * 5
	
**## 1.3
	display			9 / 2
	
**## 1.4
	display			5 - 3 * 2
	
**## 1.5
	display			(5 - 3) * 2
	
**## 1.6
	display			4^2
	
**## 1.7
	display			8 / 2^2
	
	
********************************************************************************	
**# exercise 2
********************************************************************************

	 set 			obs 1
	 gen			p_euro = 5.87
	 gen			p_gbp = 5.09
	 display		p_gbp / p_euro

	 
********************************************************************************
**# exercise 3
********************************************************************************

	clear			all
	sysuse			"lifeexp.dta"

**## 3.1
	describe
	
**## 3.2
	sum				lexp
	
**## 3.3
	sum				lexp, detail
	
**## 3.4
	sort			country
	
**## 3.5
	tab				region
	
**## 3.6
	tab				region, nolab
	
**## 3.7
	bys				region: ///
						sum lexp
	
**## 3.8
	sum				popgrowth if region == 2, detail
	
**## 3.9
	drop if			safewater == .
	
**## 3.10
	save			"$answ/lifeexp_no-sw.dta", replace
	
	
********************************************************************************
**# exercise 4
********************************************************************************

	clear			all
	set 			obs 1
	gen				gdp = 30490000000000
	gen				pop = 342900000
	gen				gdp_pc = gdp / pop
	gen				gdp_pc_euro = gdp_pc * 0.86

	
********************************************************************************
**# exercise 5
********************************************************************************

**## 5.1
	display			abs(-15.5)

**## 5.2
	display			round(4.483847,0.1)
	
**## 5.3
	display			round(3.8)

**## 5.4
	display			strupper("unemployment")

**## 5.5
	display			strlower("INFLATION")

**## 5.6
	display			round(sqrt(2.6),0.01)
	
	
********************************************************************************
**# exercise 6
********************************************************************************

	clear			all
	sysuse			nlsw88.dta, clear
    sum				wage hours
    tab				married race, row
    bys 			married race:  ///
						sum wage hours
						
**## 6.1

* 6.1.1 & 6.1.2
	bys				union: ///
						sum wage hours
* 6.1.3 & 6.1.4
	bys				collgrad: ///
						sum wage hours
**## 6.2

* 6.2.1 & 6.2.2
	tab				union race, row
	
* 6.2.3 & 6.2.4
	tab				collgrad race, row
	
* 6.3
	bys				union collgrad: ///
						sum wage hours
						
						
********************************************************************************
**# exercise 7
********************************************************************************

* return stata to default scheme
	set 			scheme s2color
	
**## 7.1
	twoway			(scatter wage tenure)
	save			"$answ/01-basic-graphs-1.png", replace
	
* set plotplain as default scheme
	ssc 			install blindschemes
	set 			scheme plotplain, perm
	
**## 7.2
	twoway			(scatter wage tenure)
	save			"$answ/01-basic-graphs-2.png", replace
	
**## 7.3
	twoway			(scatter wage tenure) (lfit wage tenure)
	save			"$answ/01-basic-graphs-3.png", replace
	

********************************************************************************
**# challenge 1
********************************************************************************

* create scatter plot with line of best fit
	twoway			(scatter wage tenure) (lfit wage tenure, lc(maroon) ), ///
						xtitle("Wages (hourly)") ytitle("Tenure (years)") ///
						legend( col(2) pos(6))
						
	save			"$answ/challenge-01.png", replace
	
	