*** .do file to replicate:
*** Figure 3 and Table 4


/************************************/
/* Set-up  */
/************************************/


*run programs used in generating plots and tables
do "${dodir}/00_setup.do"

*read data
use "${dtadir}/gjp_main_working.dta", clear 


* est table settings*
gl estopts  b(3) se(3) varwidth(25) label se starlevels(* 0.1 ** 0.05 *** 0.01) nonotes nodepvars
gl eststatopts stat(N depvarmean , label("N"  "Control group mean"  ) fmt(%12.0fc %13.2fc)) 
gl estmgroupopts prefix(\multicolumn{@span}{c}{) suffix(})  span erepeat(\cmidrule(lr){@span})


*set baseline control variables
#delimit ;
gl blcontrols primary_school med_center elect tdist irr_share 
  ln_land pc01_lit_share pc01_sc_share bpl_landed_share bpl_inc_source_sub_share
  bpl_inc_250plus  ;
#delimit cr 


/* [>  low rel. ag wage + hi sugar or hi rice <] */ 

ivreghdfe fires10km (receivedroad = t) left right ${blcontrols}  fires2001_10km   ///
 if agwage_rel_nonag_hi == 0 & (sugar_hi == 1 | rice_hi == 1) ///
 [aw = kernel_tri_ik],  a(year dist_thresh_id) cluster(village_id)  

eststo ivaglo_rsug_hi
sum fires10km if e(sample) &  t == 0
estadd scalar depvarmean = r(mean)

ivreghdfe pm25 (receivedroad = t) left right ${blcontrols} pm25_bl2001 ///
  if agwage_rel_nonag_hi == 0 &  (sugar_hi == 1 | rice_hi == 1) ///
  [aw = kernel_tri_ik],a(year dist_thresh_id) cluster(village_id)

 eststo pm25_rhishi_iv
 sum pm25 if e(sample) &  t == 0
 estadd scalar depvarmean = r(mean)


/* [> hi rel. ag wage OR low rel. ag + low sugar & low rice <] */ 

ivreghdfe fires10km (receivedroad = t) left right ${blcontrols}  fires2001_10km   ///
 if agwage_rel_nonag_hi == 1 | ( agwage_rel_nonag_hi == 0 & sugar_hi == 0 & rice_hi == 0)  ///
 [aw = kernel_tri_ik],  a(year dist_thresh_id) cluster(village_id) 

eststo ivaghi_orrsug_lo
sum fires10km if e(sample) &  t == 0
estadd scalar depvarmean = r(mean)


ivreghdfe pm25 (receivedroad = t) left right ${blcontrols}   pm25_bl2001 ///
  if agwage_rel_nonag_hi == 1 | ( agwage_rel_nonag_hi == 0 & sugar_hi == 0 & rice_hi == 0) ///
   [aw = kernel_tri_ik],  a(year dist_thresh_id) cluster(village_id)
  
 eststo pm25_rloslo_iv
  sum pm25 if e(sample) &  t == 0
  estadd scalar depvarmean = r(mean)



*** table 4***

esttab  ivaglo* pm25*hi*iv ivaghi* pm25*lo*iv  using "${outdir}/table4.tex" , ///
    $estopts $eststatopts  replace ///
    keep(receivedroad) coeflabels( receivedroad "Road built") ///
    mgroups("\shortstack{Low rel. ag. wage\\with high rice or high sugar}" ///
             "\shortstack{High rel ag. wage\\or low rel. ag wage with\\low rice \& low sugar}" , ///
            pattern(1 0 1 0) $estmgroupopts )  ///
    mtitles("Fires" "PM 2.5" "Fires" "PM 2.5")

/************************************/
/*  Fig. 3 */
/************************************/

/* [> Fig 3a.] */ 

cap drop y_resid 

reghdfe fires10km ${blcontrols} fires2001_10km if agwage_rel_nonag_hi == 0 & (sugar_hi == 1 | rice_hi == 1), a(year dist_thresh_id) vce(cluster village_id) res(y_resid)

rd y_resid v_pop [aweight = wt] if agwage_rel_nonag_hi == 0 & (sugar_hi == 1 | rice_hi == 1) , ///
 xtitle(Population minus threshold, size(*1.5)) ytitle("Annual fire count", size(*1.5))  cluster(village_id) ///
 bin(20) degree(1) start(-80) end(80) ylabel(-1(.5)1, format(%2.1f) labsize(*1.5)  nogrid) xlabel( , labsize(*1.5) nogrid) bw scheme(white_tableau)

graph export "${outdir}/fig3a.pdf" ,  replace 


/* [> Fig 3b.] */ 

cap drop y_resid 

reghdfe fires10km ${blcontrols} fires2001_10km if agwage_rel_nonag_hi == 1 | ( agwage_rel_nonag_hi == 0 & sugar_hi == 0 & rice_hi == 0), a(year dist_thresh_id) vce(cluster village_id) res(y_resid)

rd y_resid v_pop  [aweight = wt]  if agwage_rel_nonag_hi == 1 | ( agwage_rel_nonag_hi == 0 & sugar_hi == 0 & rice_hi == 0) , ///
 xtitle(Population minus threshold, size(*1.5)) ytitle("Annual fire count", size(*1.5))  cluster(village_id) ///
 bin(20) degree(1) start(-80) end(80) ylabel(-1(.5)1, format(%2.1f) labsize(*1.5)  nogrid) xlabel(, labsize(*1.5) nogrid) bw scheme(white_tableau)

graph export "${outdir}/fig3b.pdf" ,  replace 

/* [> Fig 3c.] */ 

cap drop y_resid 

reghdfe pm25 ${blcontrols} pm25_bl2001 if agwage_rel_nonag_hi == 0 & (sugar_hi == 1 | rice_hi == 1), a(year dist_thresh_id) vce(cluster village_id) res(y_resid)

rd y_resid v_pop [aweight = wt] if agwage_rel_nonag_hi == 0 &  (sugar_hi == 1 | rice_hi == 1) , ///
 xtitle(Population minus threshold, size(*1.5)) ytitle("Annual PM2.5", size(*1.5))  cluster(village_id) ///
bin(20) degree(1) start(-80) end(80) ylabel(-0.4(0.2)0.6, format(%2.1f) labsize(*1.5)  nogrid) xlabel(, labsize(*1.5) nogrid)  bw scheme(white_tableau)

graph export "${outdir}/fig3c.pdf",  replace 

/* [> Fig 3d.] */ 

cap drop y_resid 

reghdfe pm25 ${blcontrols} pm25_bl2001 if agwage_rel_nonag_hi == 1 | ( agwage_rel_nonag_hi == 0 & sugar_hi == 0 & rice_hi == 0) , a(year dist_thresh_id) vce(cluster village_id) res(y_resid)

rd y_resid v_pop [aweight = wt]  if agwage_rel_nonag_hi == 1 |  ( agwage_rel_nonag_hi == 0 & sugar_hi == 0 & rice_hi == 0) , ///
 xtitle(Population minus threshold, size(*1.5)) ytitle("Annual PM2.5", size(*1.5))  cluster(village_id) ///
bin(20) degree(1) start(-80) end(80) ylabel(-0.4(0.2)0.6, format(%2.1f) labsize(*1.5)  nogrid) xlabel(, labsize(*1.5) nogrid) bw scheme(white_tableau)

graph export "${outdir}/fig3d.pdf",  replace 

******** END *********
