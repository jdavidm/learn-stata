*** .do file to replicate:
*** Appendix G


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
**** Table G.1. *****
************************************

use "${dtadir}/gjp_main_working.dta", clear 

ivreghdfe fires_ag (receivedroad = t) left right fires_ag_2001 ${blcontrols}  [aw = kernel_tri_ik] ,  a(year dist_thresh_id) cluster(village_id)

eststo ivfiresag
su fires_ag if e(sample) & t == 0
estadd scalar depvarmean = r(mean)

ivreghdfe fires_nonag (receivedroad = t) left right fires_nonag_2001 ${blcontrols}  [aw = kernel_tri_ik] ,  a(year dist_thresh_id) cluster(village_id)
eststo ivfiresnonag
su fires_nonag if e(sample) & t == 0
estadd scalar depvarmean = r(mean)


esttab ivfiresag ivfiresnonag ///
     using "${outdir}/tableG1.tex" , ///
    $estopts $eststatopts  replace ///
    keep(receivedroad) coeflabels( receivedroad "Road built") ///
    mgroups("Annual fire count" , ///
      pattern(1  0 ) $estmgroupopts) ///
    mtitles("Cropland" "Non-cropland")


 ******** END *********