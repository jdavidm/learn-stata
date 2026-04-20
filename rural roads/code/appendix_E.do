*** .do file to replicate:
*** Appendix E


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
**** Figure E.1. *****
************************************
use "${dtadir}/gjp_main_working.dta", clear 
keep if year == 2012 | year == .
drop agwage_rel_nonag_hi 

sum agwage_rel_nonag , d 
gen agwage_rel_nonag_hi = agwage_rel_nonag >= r(p50) & !mi(agwage_rel_nonag) 



rd nco2d_cultiv_share v_pop if agwage_rel_nonag_hi == 1, ///
 xtitle(Population minus threshold, size(*1.5))  ///
msize(small)   absorb(dist_thresh_id) control( ${blcontrols}    )  ///
bin(16) degree(1) start(-84) end(84) title("{bf:(i)} High relative ag. labor wage", size(small)) ///
ylabel(-.04(.02).04,labsize(*1.5) nogrid)  xlabel(, labsize(*1.5) nogrid)  bw name(aglabhi) scheme(white_tableau)

rd nco2d_cultiv_share v_pop if agwage_rel_nonag_hi == 0, ///
 xtitle(Population minus threshold, size(*1.5)) ///
msize(small)   absorb(dist_thresh_id) control( ${blcontrols}    )  ///
bin(16) degree(1) start(-84) end(84) title("{bf:(ii)} Low relative ag. labor wage", size(small)) ///
ylabel(-.04(.02).04,labsize(*1.5) nogrid)  xlabel(, labsize(*1.5) nogrid)  bw name(aglablo) scheme(white_tableau)



graph combine aglabhi aglablo, ycommon scheme(plotplain) title("Panel A: Agricultural labor share", size(medlarge)) name(aglab, replace)

rd nco2d_manlab_share v_pop if agwage_rel_nonag_hi == 1, ///
 xtitle(Population minus threshold, size(*1.5))  ///
msize(small)   absorb(dist_thresh_id) control( ${blcontrols}    )  ///
bin(16) degree(1) start(-84) end(84) title("{bf:(i)} High relative ag. labor wage", size(small)) ///
ylabel(,labsize(*1.5) nogrid)  xlabel(, labsize(*1.5) nogrid)  bw name(manlabhi) scheme(white_tableau)


rd nco2d_manlab_share v_pop if agwage_rel_nonag_hi == 0,  ///
xtitle(Population minus threshold, size(*1.5))  ///
msize(small)   absorb(dist_thresh_id) control( ${blcontrols}    )  ///
bin(16) degree(1) start(-84) end(84) title("{bf:(ii)} Low relative ag. labor wage", size(small)) ///
ylabel(,labsize(*1.5) nogrid)  xlabel(, labsize(*1.5) nogrid)  bw name(manlablo) scheme(white_tableau)

graph combine manlabhi manlablo,  title("Panel B: Manual labor share", size(medlarge)) ycommon scheme(plotplain) name(manlab, replace)

graph combine aglab manlab , rows(2) xcommon scheme(plotplain)

graph export "${outdir}/figE1.pdf",  replace 


************************************
**** Figure E.2. *****
************************************
use "${dtadir}/gjp_main_working.dta", clear 

** Fig E.2.a **
cap drop y_resid 

reghdfe fires10km ${blcontrols} fires2001_10km if agwage_rel_nonag_hi == 1, a(year dist_thresh_id) vce(cluster village_id) res(y_resid)

rd y_resid v_pop [aweight = wt]  if agwage_rel_nonag_hi == 1,  ///
xtitle(Population minus threshold, size(*1.5)) ytitle("Annual fire count", size(*1.5))    ///
bin(20) degree(1) start(-80) end(80) ///
ylabel(-1(.5)1,format(%2.1f) labsize(*1.5) nogrid) xlabel(, labsize(*1.5) nogrid) cluster(village_id) bw scheme(white_tableau)

graph export "${outdir}/figE2_a.pdf",  replace

** Fig E.2.b **
cap drop y_resid 

reghdfe fires10km ${blcontrols} fires2001_10km if agwage_rel_nonag_hi == 0, a(year dist_thresh_id) vce(cluster village_id) res(y_resid)

rd y_resid v_pop [aweight = wt]  if agwage_rel_nonag_hi == 0,  ///
xtitle(Population minus threshold, size(*1.5)) ytitle("Annual fire count", size(*1.5))    ///
bin(20) degree(1) start(-80) end(80) ///
ylabel(-1(.5)1,format(%2.1f) labsize(*1.5) nogrid) xlabel(, labsize(*1.5) nogrid) cluster(village_id) bw scheme(white_tableau)

graph export "${outdir}/figE2_b.pdf",  replace 

** Fig E.2.c **
cap drop y_resid 

reghdfe pm25 ${blcontrols}  pm25_bl2001  if agwage_rel_nonag_hi == 1, a(year dist_thresh_id) vce(cluster village_id) res(y_resid)

rd y_resid v_pop [aweight = wt]  if agwage_rel_nonag_hi == 1,  ///
xtitle(Population minus threshold, size(*1.5)) ytitle("Annual PM 2.5", size(*1.5)) ///
bin(20) degree(1) start(-80) end(80)   ///
ylabel(-.2(.1).2,format(%2.1f) labsize(*1.5) nogrid) xlabel(, labsize(*1.5) nogrid) cluster(village_id)  bw scheme(white_tableau)

graph export "${outdir}/figE2_c.pdf",  replace

** Fig E.2.d **
cap drop y_resid 

reghdfe pm25 ${blcontrols}  pm25_bl2001  if agwage_rel_nonag_hi == 0, a(year dist_thresh_id) vce(cluster village_id) res(y_resid)

rd y_resid v_pop [aweight = wt]  if agwage_rel_nonag_hi == 0,  ///
xtitle(Population minus threshold, size(*1.5)) ytitle("Annual PM 2.5", size(*1.5)) ///
bin(20) degree(1) start(-80) end(80)  ///
ylabel(-.2(.1).2,format(%2.1f) labsize(*1.5) nogrid) xlabel(, labsize(*1.5) nogrid) cluster(village_id)  bw scheme(white_tableau)

graph export "${outdir}/figE2_d.pdf",  replace

************************************
**** Table E.1. *****
************************************
use "${dtadir}/gjp_main_working.dta", clear 
keep if year == 2012 | year == .
drop agwage_rel_nonag_hi 

sum agwage_rel_nonag , d 
gen agwage_rel_nonag_hi = agwage_rel_nonag >= r(p50) & !mi(agwage_rel_nonag) 

eststo clear 

foreach var in cultiv manlab {

  ivregress 2sls nco2d_`var'_share (r2012 = t) left right ${blcontrols} i.dist_thresh_id [aw = kernel_tri_ik] if  agwage_rel_nonag_hi == 1 & _m_dld ==3  ,  vce(robust)
  sum nco2d_`var'_share if e(sample) & t == 0
  estadd scalar outcome_mean = r(mean)
  eststo ivagwage_hi_`var'

  ivregress 2sls nco2d_`var'_share (r2012 = t) left right ${blcontrols} i.dist_thresh_id [aw = kernel_tri_ik] if  agwage_rel_nonag_hi == 0 & _m_dld ==3 ,  vce(robust)
  sum nco2d_`var'_share if e(sample) & t == 0
  estadd scalar outcome_mean = r(mean)
  eststo ivagwage_lo_`var'
  

}

esttab iv*hi_cultiv iv*lo_cultiv iv*hi_manlab iv*_lo_manlab ///
     using "${outdir}/tableE1.tex" , replace ///
    keep(r2012  ) coeflabels(r2012 "Road built") ///
    mgroups("\shortstack{Share of labor\\in agriculture}" ///
          "\shortstack{Share of non-agricultural\\manual labor}", ///
           pattern(1 0 1 0 ) $estmgroupopts )         ///
    mtitles("\shortstack{High rel.\\ag. wage}" "\shortstack{Low rel.\\ag. wage}" ///
            "\shortstack{High rel.\\ag. wage}" "\shortstack{Low rel.\\ag. wage}"  ) ///
       $estopts  stat(N outcome_mean , label("N"  "Control group mean"  ) fmt(%12.0fc %13.2fc))  


************************************
**** Table E.2. *****
************************************

use "${dtadir}/gjp_main_working.dta", clear 

eststo clear 

ivregress 2sls fires10km  (receivedroad = t) left right ${blcontrols}  fires2001_10km  i.year i.dist_thresh_id [aw = kernel_tri_ik] if agwage_rel_nonag_hi == 1 & _m_dld ==3, vce(cluster village_id)

eststo fires10kmivagwagehi
sum fires10km if e(sample) &  t == 0
estadd scalar depvarmean = r(mean)

ivregress 2sls fires10km  (receivedroad = t) left right ${blcontrols}  fires2001_10km  i.year i.dist_thresh_id [aw = kernel_tri_ik] if agwage_rel_nonag_hi == 0 & _m_dld ==3, vce(cluster village_id)
eststo fires10kmivagwagelo
sum fires10km if e(sample) &  t == 0
estadd scalar depvarmean = r(mean)



ivregress 2sls pm25  (receivedroad = t) left right ${blcontrols}  pm25_bl2001  i.year i.dist_thresh_id [aw = kernel_tri_ik] if agwage_rel_nonag_hi == 1 & _m_dld ==3, vce(cluster village_id)
eststo pm25ivagwagehi
sum pm25 if e(sample) &  t == 0
estadd scalar depvarmean = r(mean)

ivregress 2sls pm25  (receivedroad = t) left right ${blcontrols}  pm25_bl2001  i.year i.dist_thresh_id [aw = kernel_tri_ik] if agwage_rel_nonag_hi == 0 & _m_dld ==3, vce(cluster village_id)
eststo pm25ivagwagelo
sum pm25 if e(sample) &  t == 0
estadd scalar depvarmean = r(mean)





esttab fire*ivagwagehi pm25*ivagwagehi  fire*ivagwagelo  pm25*ivagwagelo ///
     using "${outdir}/tableE2.tex" , ///
    $estopts $eststatopts  replace ///
    keep(receivedroad) coeflabels( receivedroad "Road built") ///
    mgroups("High rel. ag. wage" "Low rel. ag. wage" , ///
      pattern(1  0 1 0) $estmgroupopts) ///
    mtitles("Fires" "PM 2.5" "Fires" "PM 2.5")


 ******** END *********