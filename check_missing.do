use "c:/Users/jdmichler/git/learn-stata/data/mm-1.dta", clear
count if missing(yield)
count if missing(icp)

gen first_icp = tindex if icp == 1
bysort qnno: egen min_icp = min(first_icp)
replace first_icp = min_icp
drop min_icp
replace first_icp = 0 if missing(first_icp)

count if missing(first_icp)
xtset qnno tindex
csdid yield, ivar(qnno) time(tindex) gvar(first_icp)

* Maybe the syntax should just use long data: csdid yield icp, ivar(qnno) time(tindex) gvar(first_icp)
