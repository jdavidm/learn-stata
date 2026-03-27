use "c:/Users/jdmichler/git/learn-stata/data/mm-1.dta", clear
gen first_icp = tindex if icp == 1
bysort qnno: egen min_icp = min(first_icp)
replace first_icp = min_icp
drop min_icp
replace first_icp = 0 if missing(first_icp)

reghdfe yield icp, absorb(qnno tindex) vce(cluster qnno)
eststo bias_twfe

xtset qnno tindex
csdid yield, ivar(qnno) time(tindex) gvar(first_icp)

estat simple, estore(bacon_csdid)

esttab bias_twfe bacon_csdid
