* course: 597a
* assignment: 12
* created on: 31 mar 26
* created by: jdm
* edited on: 31 mar 26
* edited by: jdm
* stata v.18.0

**********************************************************************
**# 0 - setup
**********************************************************************

* open log
	cap             log close
	log             using "12-did.log", append

**********************************************************************
**# exercise 1
**********************************************************************

**## 1.1

* load data
	use             "panel_gis.dta", clear
    
* set panel   
	xtset           district_id year

* continuous treatment did
	eststo          did1: xtreg evi_med c.seed i.year, fe ///
						vce(cluster district_id)

* did using didregress
	eststo          did2: didregress (evi_med) (seed), group(district_id) ///
						time(year) vce(cluster district_id)

**********************************************************************
**# exercise 2
**********************************************************************

**## 2.1

* find maximum seed adoption per district
	bysort          district_id: egen max_seed = max(seed)

* get median of maximum seed
	sum             max_seed, detail
	local           med = r(p50)

* define early/high adoption districts vs never/low
	gen             high_adopt = (max_seed > `med') & !missing(max_seed)

* collapse to mean by group and year
	preserve
	collapse        (mean) evi_med, by(high_adopt year)

* map parallel trends
	twoway          (connected evi_med year if high_adopt == 1, ///
						lcolor(maroon)) ///
					(connected evi_med year if high_adopt == 0, ///
						lcolor(navy)), ///
						legend(order(1 "High Adopters" ///
						2 "Low/Never Adopters")) xtitle("Year") ///
						ytitle("Mean EVI") ///
						title("Parallel Trends Check")
	graph export    "parallel_trends.png", replace
	restore
	*** generally, the parallel trends appear consistent pre-adoption

**********************************************************************
**# exercise 3
**********************************************************************

**## 3.1

* interacted model
	eststo          did3: xtreg evi_med c.seed##c.bin_max_60_611 i.year, ///
						fe vce(cluster district_id)

* build esttab table
	esttab          did1 did2 did3 using "12-continuous-did.tex", replace ///
						b(3) se(3) ///
						star(* 0.10 ** 0.05 *** 0.01) ///
						stats(N r2, labels("Observations" "R-squared") ///
						noobs booktabs nonum nomtitle collabels(none) ///
						nobaselevels nogaps fragment label fmt(0 3)) ///
						prehead("\begin{tabular}{l*{3}{c}} " ///
						  "\\[-1.8ex]\hline \hline \\[-1.8ex] " ///
						  "& \multicolumn{3}{c}{DiD} \\ \midrule") ///
						postfoot("\hline \hline \\[-1.8ex] " ///
						  "\multicolumn{4}{p{\linewidth}}{\small " ///
						  "\noindent \textit{Note}: Dependent variable " ///
						  "is crop yield in kg/ha. All models use " ///
						  "standard errors clustered at the " ///
						  "district level (in parentheses). " ///
						  "* p$<0.10, ** p$<0.05, *** p$<0.01.}" ///
						  "\end{tabular}")

**********************************************************************
**# 4 - end matter
**********************************************************************

* close log
	cap             log close

/* end */
