use "c:\Users\jdmichler\git\learn-stata\data\tenuredata.dta", clear
xtset strp tindex
bysort strp: egen c = count(tindex)
qui sum c
keep if c == r(max)
drop c
export delimited "c:\Users\jdmichler\git\learn-stata\data\tenuredata.csv", replace
