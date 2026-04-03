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
	log             using "$logout/12-did.log", append

**********************************************************************
**# exercise 1 - Continuous Treatment DiD
**********************************************************************

**## 1.1

* load data
	use             "$data/panel_gis.dta", clear
    
* set panel   
	xtset           district_id year

* continuous treatment did
	eststo          did1: xtreg evi_med c.seed i.year, fe ///
						vce(cluster district_id)

* did using didregress
	eststo          did2: didregress (evi_med) (seed, continuous), group(district_id) ///
						time(year) vce(cluster district_id)
						
   esttab      did1 did2 using "$answ/12-did.tex", replace ///
                    b(4) se(4) ///
                    rename(seed "STRV Seed") ///
                    keep("STRV Seed") ///
                    star(* 0.10 ** 0.05 *** 0.01) ///
                    stats(N r2, labels("Observations" "R-squared") fmt(0 3)) ///
                    noobs booktabs nonum nomtitle eqlabels(none) collabels(none) ///
                    nobaselevels nogaps fragment label ///
                    prehead("\begin{tabular}{l*{2}{c}} " ///
                      "\\[-1.8ex]\hline \hline \\[-1.8ex] " ///
                      "& \multicolumn{1}{c}{xtreg} & " ///
                      "\multicolumn{1}{c}{didreg} \\ \midrule") ///
                    postfoot("\hline \hline \\[-1.8ex] " ///
                      "\multicolumn{3}{p{\linewidth}}{\small " ///
                      "\noindent \textit{Note}: Dependent variable " ///
                      "is median EVI. All models use " ///
                      "standard errors clustered at the " ///
                      "household level (in parentheses). " ///
                      "* p$<$0.10, ** p$<$0.05, *** p$<$0.01.} " ///
                      "\end{tabular}")
					  
					  
**********************************************************************
**# exercise 2 - Parallel Trends
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
						lcolor(navy)), xline(2011) ///
						legend(order(1 "High Adopters" ///
						2 "Low/Never Adopters")) xtitle("Year") ///
						ytitle("Mean EVI") ///
						title("Parallel Trends Check")
	graph export    "$answ/12-parallel_trends.png", replace
	restore


**********************************************************************
**# exercise 3 - Continuous Interacted DiD
**********************************************************************

**## 3.1

* interacted model
	eststo          did3: xtreg evi_med c.seed##c.bin_max_60_611 i.year, ///
						fe vce(cluster district_id)

* build esttab table

   esttab      did1 did2 did3 using "$answ/12-interact-did.tex", replace ///
                    b(4) se(4) ///
                    rename(seed "STRV Seed") ///
                    keep("STRV Seed") ///
                    star(* 0.10 ** 0.05 *** 0.01) ///
                    stats(N r2, labels("Observations" "R-squared") fmt(0 3)) ///
                    noobs booktabs nonum nomtitle eqlabels(none) collabels(none) ///
                    nobaselevels nogaps fragment label ///
                    prehead("\begin{tabular}{l*{3}{c}} " ///
                      "\\[-1.8ex]\hline \hline \\[-1.8ex] " ///
                      "& \multicolumn{1}{c}{xtreg} & " ///
                      "\multicolumn{1}{c}{didreg} & " ///
					  "\multicolumn{1}{c}{inter} \\ \midrule") ///
                    postfoot("\hline \hline \\[-1.8ex] " ///
                      "\multicolumn{4}{p{\linewidth}}{\small " ///
                      "\noindent \textit{Note}: Dependent variable " ///
                      "is median EVI. All models use " ///
                      "standard errors clustered at the " ///
                      "household level (in parentheses). " ///
                      "* p$<$0.10, ** p$<$0.05, *** p$<$0.01.} " ///
                      "\end{tabular}")

**********************************************************************
**# 4 - end matter
**********************************************************************

* close log
	cap             log close

/* end */
