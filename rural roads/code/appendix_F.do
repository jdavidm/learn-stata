*** .do file to replicate:
*** Appendix F


/************************************/
/* Set-up  */
/************************************/



*run programs used in generating plots and tables
do "${dodir}/00_setup.do"


* est table settings*
gl estopts  b(3) se(3) varwidth(25) label se starlevels(* 0.1 ** 0.05 *** 0.01) nonotes nodepvars
gl eststatopts stat(N depvarmean , label("N"  "Control group mean"  ) fmt(%12.0fc %13.2fc)) 
gl estmgroupopts prefix(\multicolumn{@span}{c}{) suffix(})  span erepeat(\cmidrule(lr){@span})


#delimit ;
gl blcontrols primary_school med_center elect tdist irr_share 
  ln_land pc01_lit_share pc01_sc_share bpl_landed_share bpl_inc_source_sub_share
  bpl_inc_250plus  ;
#delimit cr 



************************************
**** Figure F.2. *****
************************************

** Fig F.2.a **
use "${dtadir}/gjp_main_working.dta", clear 

rd fires10km v_pop  if (sugar_hi == 1 | rice_hi == 1) , ///
 xtitle(Population minus threshold, size(*1.5)) ytitle("Annual fire count", size(*1.5)) ///
absorb(dist_thresh_id) control( ${blcontrols} i.year fires2001_10km)  ///
 bin(20) degree(1) start(-80) end(80) ///
ylabel(-0.5(.5).5, format(%2.1f)  nogrid) xlabel(, nogrid) bw scheme(white_tableau)

graph export "${outdir}/figF2_a.pdf",  replace  

** Fig F.2.b **
use "${dtadir}/gjp_main_working.dta", clear 


rd fires10km v_pop if ( sugar_hi == 0 & rice_hi == 0) , ///
 xtitle(Population minus threshold, size(*1.5)) ytitle("Annual fire count", size(*1.5)) ///
absorb(dist_thresh_id) control( ${blcontrols} i.year fires2001_10km)  ///
 bin(20) degree(1) start(-80) end(80) ///
ylabel(-1(.5).5, format(%2.1f) nogrid) xlabel(, nogrid) bw scheme(white_tableau)


graph export "${outdir}/figF2_b.pdf",  replace 

** Fig F.2.c **
use "${dtadir}/gjp_main_working.dta", clear 


rd pm25 v_pop  if (sugar_hi == 1 | rice_hi == 1) , ///
 xtitle(Population minus threshold, size(*1.5)) ytitle("Annual PM 2.5", size(*1.5)) ///
absorb(dist_thresh_id) control( ${blcontrols} i.year pm25_bl2001)  ///
 bin(16) degree(1) start(-80) end(80) ///
ylabel(-0.2(.1).2, format(%3.2f) nogrid) xlabel(, nogrid) bw scheme(white_tableau)
 

graph export "${outdir}/figF2_c.pdf",  replace  

** Fig F.2.d **
use "${dtadir}/gjp_main_working.dta", clear 

rd pm25 v_pop  if (sugar_hi == 0 & rice_hi == 0) , ///
 xtitle(Population minus threshold, size(*1.5)) ytitle("Annual PM 2.5", size(*1.5)) ///
absorb(dist_thresh_id) control( ${blcontrols} i.year  pm25_bl2001)  ///
 bin(16) degree(1) start(-80) end(80) ///
ylabel(-0.2(.1).2, format(%3.2f) nogrid) xlabel(, nogrid) bw scheme(white_tableau)


graph export "${outdir}/figF2_d.pdf",  replace  


************************************
**** Table F.1. *****
************************************

use "${dtadir}/gjp_main_working.dta", clear 

est clear

foreach var of varlist fires10km {
  
  ivregress 2sls `var' (receivedroad = t) left right ${blcontrols}   fires2001_10km i.year i.dist_thresh_id [aw = kernel_tri_ik] if sugar_hi == 1 | rice_hi == 1, vce(cluster village_id)
  eststo `var'_rhishi_iv
  sum `var' if e(sample) &  t == 0
  estadd scalar depvarmean = r(mean)


  ivregress 2sls `var' (receivedroad = t) left right ${blcontrols}  fires2001_10km i.year i.dist_thresh_id [aw = kernel_tri_ik] if sugar_hi == 0 & rice_hi == 0 , vce(cluster village_id)
  eststo `var'_rloslo_iv
  sum `var' if e(sample) &  t == 0
  estadd scalar depvarmean = r(mean)

 
}



foreach var of varlist pm25 {
   
  ivregress 2sls `var' (receivedroad = t) left right ${blcontrols}   `var'_bl2001 i.year i.dist_thresh_id [aw = kernel_tri_ik] if sugar_hi == 1 | rice_hi == 1, vce(cluster village_id)
  eststo `var'_rhishi_iv
  sum `var' if e(sample) &  t == 0
  estadd scalar depvarmean = r(mean)

  ivregress 2sls `var' (receivedroad = t) left right ${blcontrols}   `var'_bl2001 i.year i.dist_thresh_id [aw = kernel_tri_ik] if sugar_hi == 0 & rice_hi == 0 , vce(cluster village_id)
  eststo `var'_rloslo_iv
  sum `var' if e(sample) &  t == 0
  estadd scalar depvarmean = r(mean)

 
}


esttab fires10km_*hi_iv pm25_*hi*_iv fires10km_*lo_iv pm25_*lo*_iv ///
     using "${outdir}/tableF1.tex" , ///
    $estopts $eststatopts  replace ///
    keep(receivedroad) coeflabels( receivedroad "Road built") ///
   mgroups("High rice or high sugar" "Low rice and low sugar" , ///
    pattern(1 0 1 0) $estmgroupopts ) ///
    mtitles("Fires" "PM 2.5" "Fires" "PM 2.5")



************************************
**** Table F.2. *****
************************************

use "${dtadir}/gjp_main_working.dta", clear 

est clear
 

*** high rice only ***
ivreghdfe fires10km  (receivedroad = t) left right ${blcontrols}  fires2001_10km  if  rice_hi == 1 [aw = kernel_tri_ik], a(year dist_thresh_id) cluster(village_id)

eststo fc_ricehi
sum fires10km if e(sample) &  t == 0
estadd scalar depvarmean = r(mean)


ivreghdfe pm25  (receivedroad = t) left right ${blcontrols}  pm25_bl2001  if rice_hi  == 1  [aw = kernel_tri_ik], a(year dist_thresh_id) cluster(village_id)

eststo pm_ricehi
sum pm25 if e(sample) &  t == 0
estadd scalar depvarmean = r(mean)

**** high sugar only ****

ivreghdfe fires10km  (receivedroad = t) left right ${blcontrols}  fires2001_10km  if  sugar_hi == 1 [aw = kernel_tri_ik], a(year dist_thresh_id) cluster(village_id)

eststo fc_sugarhi
sum fires10km if e(sample) &  t == 0
estadd scalar depvarmean = r(mean)

ivreghdfe pm25  (receivedroad = t) left right ${blcontrols}  pm25_bl2001  if sugar_hi  == 1  [aw = kernel_tri_ik], a(year dist_thresh_id) cluster(village_id)

eststo pm_sugarhi
sum pm25 if e(sample) &  t == 0
estadd scalar depvarmean = r(mean)

#delimit ;
esttab fc_ricehi pm_ricehi fc_sugarhi pm_sugarhi using "${outdir}/tableF2.tex"  ,
    $estopts $eststatopts  replace 
    keep(receivedroad) coeflabels( receivedroad "Road built") 
   mgroups("High rice" "High sugar" , pattern(1 0 1 0) $estmgroupopts ) 
    mtitles("Fires" "PM 2.5" "Fires" "PM 2.5") ;
#delimit cr 


************************************
**** Table F.3. *****
************************************

use "${dtadir}/gjp_main_working.dta", clear 

est clear

*** high rice - low sugar ****

ivreghdfe fires10km  (receivedroad = t) left right ${blcontrols}  fires2001_10km  if  rice_hi == 1 & sugar_hi == 0 [aw = kernel_tri_ik], a(year dist_thresh_id) cluster(village_id)

eststo fc_ricehi_sugarlo
sum fires10km if e(sample) &  t == 0
estadd scalar depvarmean = r(mean)



ivreghdfe pm25  (receivedroad = t) left right ${blcontrols}  pm25_bl2001  if rice_hi  == 1 & sugar_hi == 0 [aw = kernel_tri_ik], a(year dist_thresh_id) cluster(village_id)

eststo pm_ricehi_sugarlo
sum pm25 if e(sample) &  t == 0
estadd scalar depvarmean = r(mean)


*** high sugar - low rice ****

ivreghdfe fires10km  (receivedroad = t) left right ${blcontrols}  fires2001_10km  if  rice_hi == 0 & sugar_hi == 1 [aw = kernel_tri_ik], a(year dist_thresh_id) cluster(village_id)

eststo fc_ricelo_sugarhi
sum fires10km if e(sample) &  t == 0
estadd scalar depvarmean = r(mean)



ivreghdfe pm25  (receivedroad = t) left right ${blcontrols}  pm25_bl2001  if rice_hi  == 0 & sugar_hi == 1 [aw = kernel_tri_ik], a(year dist_thresh_id) cluster(village_id)

eststo pm_ricelo_sugarhi
sum pm25 if e(sample) &  t == 0
estadd scalar depvarmean = r(mean)



#delimit ;

esttab fc_ricehi_sugarlo pm_ricehi_sugarlo fc_ricelo_sugarhi pm_ricelo_sugarhi  using "${outdir}/tableF3.tex"  , 
  $estopts $eststatopts  replace 
    keep(receivedroad) coeflabels( receivedroad "Road built") 
   mgroups("High rice \& low sugar" "High sugar \& low rice" , pattern(1 0 1 0) $estmgroupopts ) 
    mtitles("Fires" "PM 2.5" "Fires" "PM 2.5") ;

#delimit cr 


 ******** END *********
 
