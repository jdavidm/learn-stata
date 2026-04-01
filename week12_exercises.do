* Week 12 Exercises 1-3
* Set environment and load data
clear all
set more off
use "panel_gis.dta", clear

xtset district_id year

********************************************************************************
* Exercise 1: Continuous Treatment DiD
********************************************************************************
* 1. Regress evi_med on continuous treatment seed using TWFE
eststo did1: xtreg evi_med c.seed i.year, fe vce(cluster district_id)

* 2. Repeat using didregress
eststo did2: didregress (evi_med) (seed), group(district_id) time(year) vce(cluster district_id)

********************************************************************************
* Exercise 2: Parallel Trends in Interventions
********************************************************************************
* 1. Define early/high adoption districts vs never/low
bysort district_id: egen max_seed = max(seed)

* Get median of max_seed
sum max_seed, detail
local med = r(p50)

* Create dummy for high adopters
gen high_adopt = (max_seed > `med') & !missing(max_seed)

* 2. Collapse and plot
preserve
collapse (mean) evi_med, by(high_adopt year)

* Adjust the xline explicitly to the hypothesized intervention point if there is one, 
* or just visualize the pre-period
twoway  (connected evi_med year if high_adopt == 1, lcolor(maroon)) ///
        (connected evi_med year if high_adopt == 0, lcolor(navy)), ///
        legend(order(1 "High Adopters" 2 "Low/Never Adopters")) ///
        xtitle("Year") ytitle("Mean EVI") ///
        title("Parallel Trends Check")
graph export "parallel_trends.png", replace
restore

* Observation on parallel trends:
* (Add findings in comments based on visual inspection of pre-adoption period)


********************************************************************************
* Exercise 3: Continuous Interacted DiD
********************************************************************************
* 1. Regress evi_med against the interaction of seed and flood index
eststo did3: xtreg evi_med c.seed##c.bin_max_60_611 i.year, fe vce(cluster district_id)

* 2. Output table of results combining all three models
esttab did1 did2 did3 using "12-continuous-did.tex", replace ///
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
