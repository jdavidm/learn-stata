*** .do file to replicate:
*** Figure 4 and Table 5


/************************************/
/* Set-up   */
/************************************/


*run programs used in generating plots and tables
do "${dodir}/00_setup.do"

* est table settings*
gl estopts 	b(4) se(4) varwidth(25) label se starlevels(* 0.1 ** 0.05 *** 0.01) nonotes nodepvars
gl eststatopts stat(depvarmean N  , label("Control group mean"  "Observations"  ) fmt(%13.4fc %12.0fc)) 
gl estmgroupopts prefix(\multicolumn{@span}{c}{) suffix(})  span erepeat(\cmidrule(lr){@span})


*set baseline control variables
#delimit ;
gl blcontrols primary_school med_center elect tdist irr_share 
	ln_land pc01_lit_share pc01_sc_share bpl_landed_share bpl_inc_source_sub_share
	bpl_inc_250plus  ;
#delimit cr 

/************************************/
/*  Table 5 */
/************************************/

est clear 

/*  IMR downind  */

use if pmgsy_nfhs_km <= 50 using "${dtadir}/gjp_main_data_birthsdown.dta", clear 

ivreghdfe child_die_age1  (receivedroad = t) left right  $blcontrols, a(year dist_thresh_id) cluster(village_id) 

eststo imrdown50km
su child_die_age1 if e(sample) & t == 0
estadd scalar depvarmean = r(mean)


/*  IMR non-downwind  */

use if pmgsy_nfhs_km <= 50 using "${dtadir}/gjp_main_data_birthsother.dta", clear 

ivreghdfe child_die_age1  (receivedroad = t) left right  $blcontrols, a(year dist_thresh_id) cluster(village_id) 

eststo imrup50km
su child_die_age1 if e(sample) & t == 0
estadd scalar depvarmean = r(mean)

/* PM2.5 down and non-downwind */

use "${dtadir}/gjp_main_data_dhspm50km.dta", clear 

ivreghdfe downwind_dhs_pm25  (receivedroad = t) left right downwind_dhs_pm25_bl2001 if year > 2001, a(year dist_thresh_id) cluster(village_id) 

eststo pmdown50km
su downwind_dhs_pm25 if e(sample) & t == 0
estadd scalar depvarmean = r(mean)



ivreghdfe nondown_dhs_pm25 (receivedroad = t) left right nondown_dhs_pm25_bl2001 if year > 2001, a(year dist_thresh_id) cluster(village_id) 

eststo pmup50km
su nondown_dhs_pm25 if e(sample) & t == 0
estadd scalar depvarmean = r(mean)


* table *

#delimit ;
esttab pmdown50km imrdown50km  pmup50km imrup50km using 
	"${outdir}/table5.tex" , replace keep(receivedroad  ) 
	coeflabels(receivedroad "Road built") mgroups("Downwind" "Other directions" ,  pattern(1 0 1 0 ) $estmgroupopts  )   
	 mtitles("PM 2.5"  "Infant mortality" "PM 2.5"  "Infant mortality") $estopts  $eststatopts ;
#delimit cr 


/************************************/
/*  Figure 5 */
/************************************/


/* [> Fig 5a.] */ 

use "${dtadir}/gjp_main_data_dhspm50km.dta", clear 

cap drop y_resid
reghdfe downwind_dhs_pm25 ${blcontrols} downwind_dhs_pm25_bl2001  if year > 2001 & downwind_dhs_pm25 != . ,  a(year dist_thresh_id) cluster(village_id) res(y_resid)

rd y_resid v_pop  if year > 2001 & downwind_dhs_pm25 != .,  xtitle(Population minus threshold) ytitle("Annual average PM2.5")  msize(small)  bin(20) degree(1) start(-84) end(84) ylabel(-0.2(.1)0.2,format(%3.2f) nogrid  ) xlabel(, nogrid  ) cluster(village_id) bw scheme(white_tableau)

graph export "${outdir}/fig5a.pdf",  replace

/* [> Fig 5c.] */ 

cap drop y_resid
reghdfe nondown_dhs_pm25 ${blcontrols} nondown_dhs_pm25_bl2001 if year > 2001 & nondown_dhs_pm25 != . ,  a(year dist_thresh_id) cluster(village_id) res(y_resid)

rd y_resid v_pop if year > 2001 & nondown_dhs_pm25 != . ,  xtitle(Population minus threshold) ytitle("Annual average PM2.5")  msize(small)  bin(20) degree(1) start(-84) end(84) ylabel(-0.2(.1)0.2,format(%3.2f) nogrid  ) xlabel(, nogrid  ) cluster(village_id) bw scheme(white_tableau)

graph export "${outdir}/fig5c.pdf",  replace


/* [> Fig 5b.] */ 
use if pmgsy_nfhs_km <= 50 using "${dtadir}/gjp_main_data_birthsdown.dta", clear 

reghdfe child_die_age1 ${blcontrols}  ,  a(year dist_thresh_id) cluster(village_id) res(y_resid)

keep y_resid v_pop
rd y_resid v_pop ,  xtitle("Population minus threshold") ytitle("Likelihood of infant mortality") msize(small)  bin(20) degree(1) start(-84) end(84) ylabel(-0.0020(0.0010)0.0020,format(%5.4f) nogrid) xlabel(,nogrid)  bw scheme(white_tableau)

graph export "${outdir}/fig5b.pdf",  replace



/* [> Fig 5d.] */ 
use if pmgsy_nfhs_km <= 50 using "${dtadir}/gjp_main_data_birthsother.dta", clear 

reghdfe child_die_age1 ${blcontrols},  a(year dist_thresh_id) cluster(village_id) res(y_resid)

keep y_resid v_pop

rd y_resid v_pop ,  xtitle("Population minus threshold") ytitle("Likelihood of infant mortality") msize(small)  bin(20) degree(1) start(-84) end(84) ylabel(-0.0020(0.0010)0.0020,format(%5.4f) nogrid) xlabel(,nogrid)  bw scheme(white_tableau)
 

graph export "${outdir}/fig5d.pdf",  replace




