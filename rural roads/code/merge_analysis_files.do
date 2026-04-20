*** .do file to create analysis files ****

*set baseline control variables
#delimit ;
gl blcontrols primary_school med_center elect tdist irr_share 
	ln_land pc01_lit_share pc01_sc_share bpl_landed_share bpl_inc_source_sub_share
	bpl_inc_250plus  ;
#delimit cr 


*** merge data for main analysis file ***

* Dataset from Asher & Novosad replication data *
use "${rawdta}/an_pmgsy.dta", clear 

* reshape and setup for merging yearly data *
reshape long r  , i(village_id) j(year)
la var year "Year"
keep if inrange(year, 2002, 2013)
bys village_id: egen receivedroad = max(r)
merge m:1 village_id using "${rawdta}/an_pmgsy.dta", keepusing(r2012 r2011)
drop _merge

* merge fire variables *
merge 1:1 village_id year using "${rawdta}/pmgsy_fires.dta"
rename _merge _m_fires

* merge pollution variables *
merge 1:1 village_id year using "${rawdta}/pmgsy_pollution.dta"
rename _merge _m_pollution

* merge district wage rates (2000) *
merge m:1 village_id using "${rawdta}/pmgsy_wage.dta"
rename _merge _m_nsso_wage

* merge crop area shares (2001) *
merge m:1 village_id using "${rawdta}/pmgsy_dld.dta"
rename _merge _m_dld

foreach var in rice  sugar {
  sum `var', d
  local cut `r(p50)'
  gen `var'_hi = `var' >= `cut' if !mi(`var') 
}  

sum agwage_rel_nonag , d 
gen agwage_rel_nonag_hi = agwage_rel_nonag > r(p50) & !mi(agwage_rel_nonag) 

la var nco2d_cultiv_share "Agriculture labor share"
la var nco2d_manlab_share "Manual labor share"
la var rice_hi "above median rice share"
la var sugar_hi "above median sugar share"
la var agwage_rel_nonag_hi "above median rel. ag/non-ag wage" 

gen wt = kernel_tri_ik

* merge returns to education variables*
merge m:1 village_id using "${rawdta}/pmgsy_educ.dta"
rename _merge _m_educ


* merge ag. mechanization district level (2001) *
merge m:1 village_id using "${rawdta}/pmgsy_ag_mech.dta"
rename _merge _m_mech

egen tot_combines = rowtotal(power_combine_trailer power_combine_self_propell) if _m_mech == 3

foreach v of varlist power_* {
	egen z_`v' = std(`v') if _m_mech == 3
}   

egen z_mech = rowtotal(z_*) if _m_mech == 3
su z_mech if _m_mech == 3 , d
gen mech_hi = _m_mech == 3 & z_mech > r(p50) 

la var z_mech "mech. index"
la var mech_hi "above median mech. index" 

* merge downwind neighbouring village demographics *
merge m:1 village_id using "${rawdta}/pmgsy_nbors.dta"
drop _merge

*merge indicator for having matched NFHS/DHS cluster within 50 km *
merge m:1 village_id using "${rawdta}/pmgsy_matchYN.dta"
drop _merge

save "${dtadir}/gjp_main_working.dta", replace 

**** NFHS (DHS) PM2.5 and IMR ****


**** dhs pm *******
use "${rawdta}/an_pmgsy.dta", clear 
reshape long r  , i(village_id) j(year)
la var year "Year"
keep if inrange(year, 2002, 2013)
bys village_id: egen receivedroad = max(r)
merge m:1 village_id using "${rawdta}/an_pmgsy.dta", keepusing(r2012 r2011)
drop _merge
keep if year == 2013
drop year 
merge 1:m village_id using "${rawdta}/pmgsy_dhs_pm.dta"
keep if _merge == 3
drop _merge 

save "${dtadir}/gjp_main_data_dhspm50km.dta", replace

**** births IMR - downwind *******
use "${rawdta}/an_pmgsy.dta", clear 
reshape long r  , i(village_id) j(year)
la var year "Year"
keep if inrange(year, 2002, 2013)
bys village_id: egen receivedroad = max(r)
merge m:1 village_id using "${rawdta}/an_pmgsy.dta", keepusing(r2012 r2011)
drop _merge
keep if year == 2013
drop year 
*keep required variables*
keep village_id receivedroad t left right $blcontrols  dist_thresh_id v_pop r2012
merge 1:m village_id using "${rawdta}/pmgsy_birthsdown.dta"
drop _merge

save "${dtadir}/gjp_main_data_birthsdown.dta", replace 


**** births IMR - other-directions *******
use "${rawdta}/an_pmgsy.dta", clear 
reshape long r  , i(village_id) j(year)
la var year "Year"
keep if inrange(year, 2002, 2013)
bys village_id: egen receivedroad = max(r)
merge m:1 village_id using "${rawdta}/an_pmgsy.dta", keepusing(r2012 r2011)
drop _merge
keep if year == 2013
drop year 
*keep required variables*
keep village_id receivedroad t left right $blcontrols  dist_thresh_id v_pop r2012
merge 1:m village_id using "${rawdta}/pmgsy_birthsother.dta"
drop _merge

save "${dtadir}/gjp_main_data_birthsother.dta", replace 






