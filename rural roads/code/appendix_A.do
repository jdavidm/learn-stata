****.do file to replicate results in Appendix A *****

/************************************/
/* Set-up  */
/************************************/

*run programs used in generating plots and tables
do "${dodir}/00_setup.do"

* est table settings*
gl estopts 	b(3) se(3) varwidth(25) label se starlevels(* 0.1 ** 0.05 *** 0.01) nonotes nodepvars
gl eststatopts stat(N depvarmean , label("N"  "Control group mean"  ) fmt(%12.0fc %13.2fc)) 
gl estmgroupopts prefix(\multicolumn{@span}{c}{) suffix(})  span erepeat(\cmidrule(lr){@span})


************************************
**** Figure A.1 *****
************************************
use "${dtadir}/state_fires.dta", clear 

#delimit ;
graph bar (mean) meanfiresplot0 meanfiresplot1 , nofill 
	over(state, sort(meanfires) label(angle(vertical) labsize(*0.9))) 
	  ytitle(Average annual fire count (2001-2013))  
	 graphregion(margin(2 2 10 2)) ylabel(, nogrid)
	 bar(1, bfcolor(gs13)) bar(2, bfcolor(gs4))
				scheme(plotplain) 
	legend(order(2 "Sample states") pos(10) ring(0) size(*1.3) symxsize(*1.3))	;
#delimit cr

graph export "${outdir}/figA1.pdf",  replace

************************************
*** Figure A.2. a ******
************************************

use "${dtadir}/allindia_fires_pm_yearly.dta", clear 

twoway (bar fire_counts_000 year, barwidth(0.5)) if year >= 2001 & year <= 2013, ///
	ytitle(Annual number of fires ('000s), size(*1.5)) ylabel(0(20)100, nogrid ) ///
	xtitle(Year, size(*1.5)) xlabel(2001(1)2013, nogrid ) ///
	scheme(plotplain)

graph export "$outdir/figA2_a.pdf",  replace


************************************
*** Figure A.2. b ******
************************************
twoway (bar pm25_mean year, barwidth(0.5)) (scatteri 25 2000.5 25 2013.5, c(l) m(i) lpattern(dash)) if year >= 2001 & year <= 2013, ///
	ytitle(Annual average PM 2.5 ({&mu}g/m{sup:3}), size(*1.5)) ylabel(20(5)45, nogrid )  xtitle(Year ,size(*1.5)) xlabel(2001(1)2013,  nogrid) ///
	scheme(plotplain) ///
	legend(order(2 "WHO 24-hour guideline") ring(0) pos(11)) 

graph export "$outdir/figA2_b.pdf",  replace

************************************
*** Figure A.4 ******
************************************

use "${dtadir}/gjp_main_working.dta", clear 

keep year village_id pm25 pm25_bl2001

drop if year == .
 
reshape  wide  pm25  , i(village_id) j(year)

egen pm25_2001_2013mean = rowmean(pm25_bl2001 pm252002 pm252003 pm252004 pm252005 pm252006 pm252007 pm252008 pm252009 pm252010 pm252011 pm252012 pm252013)


#delimit ;
graph twoway (hist  pm25_2001_2013mean, color(*.5)) (scatteri 0 25 .08 25, c(l) m(i)), scheme(plotplain) 
 graphregion(color(white)) legend(off) 
 xlabel(0(20)100, nogrid) ylabel(, nogrid)
 text(0.08 25 "WHO 24-hour guideline", placement(e)) 
 xtitle("Average PM 2.5 (2001 - 2013)");

#delimit cr


graph export "${outdir}/figA4.pdf",  replace


************************************
**** Figure A.6.a *******
************************************

use "${dtadir}/roads_yearly.dta", clear 


collapse (sum) roads_completed , by(year)

#delimit ;
graph bar (asis) roads_completed, over(year, label(angle(rvertical)))
	 ytitle(Number of roads) ylab(0(2000)12000,  nogrid)
	 scheme(plotplain)  ;
#delimit cr 

graph export "${outdir}/figA6_a.pdf",  replace

************************************
**** Figure A.6.b *******
************************************

use "${dtadir}/roads_yearly.dta", clear 

keep if samplestates == 1


#delimit ;
graph bar (asis) roads_completed, over(year, label(angle(rvertical) ))
	 ytitle(Number of roads) ylab(, nogrid)
	 scheme(plotplain)  ;
#delimit cr 

graph export "${outdir}/figA6_b.pdf",  replace

************************************
**** Figure A.7. *******
************************************

use "${dtadir}/gjp_main_working.dta", clear 

#delimit ;
gl blcontrols primary_school med_center elect tdist irr_share 
  ln_land pc01_lit_share pc01_sc_share bpl_landed_share bpl_inc_source_sub_share
  bpl_inc_250plus  ;
#delimit cr 


est clear 

forval r=5(5)30 {

	ivreghdfe fires`r'km (receivedroad = t) left right fires2001_`r'km ${blcontrols}  [aw = kernel_tri_ik] ,   a(year dist_thresh_id) cluster(village_id)

	eststo fc_`r'km
}


gl coeflabelstr

forval r=5(5)30 {
	gl coeflabelstr ${coeflabelstr} fc_`r'km = "`r' km"
}


#delimit ;
coefplot  fc_*km, keep(receivedroad) 
	asequation swapnames vert 
	coeflabels(${coeflabelstr}) 
	legend(off) 
	nooffsets
	yline(0, lcolor(red) lpattern(dash))
	ciopts(recast(rcap) lpattern(dash)  lwidth(medium) lcolor(black))
	xlabel(,nogrid)
	mcolor(black) msize(medlarge)
	ytitle("{bf: IV estimate & 95% CI}")
	xtitle("{bf: Fires within distance X km of village}")
	scheme(white_tableau) 
	scale(1.5) ;
#delimit cr  

graph export "${outdir}/figA7.pdf", replace 


************************************
**** Figure A.8 *******
************************************

use "${dtadir}/gjp_main_working.dta", clear 

#delimit ;
gl blcontrols primary_school med_center elect tdist irr_share 
  ln_land pc01_lit_share pc01_sc_share bpl_landed_share bpl_inc_source_sub_share
  bpl_inc_250plus  ;
#delimit cr 


est clear 

global f  "${tmp}/fcbcoc_monthly.csv"

cap erase $f

append_to_file using $f, s(beta,se,p,n,month,depvar)

*** monthly fire counts, total and average intensity ****
forval i=1/12 {

	ivreghdfe tot_fires10km`i'   (receivedroad = t) left right ${blcontrols}  tot_fires10km`i'_bl2001   [aw = kernel_tri_ik] ,  a(year dist_thresh_id) cluster(village_id)  

	append_est_to_file using $f, b(receivedroad) s(`i', fc)

	ivreghdfe tot_bright`i'   (receivedroad = t) left right ${blcontrols}  tot_bright`i'_bl2001   [aw = kernel_tri_ik] ,  a(year dist_thresh_id) cluster(village_id)  

	append_est_to_file using $f, b(receivedroad) s(`i', tot)

	ivreghdfe mean_bright`i'   (receivedroad = t) left right ${blcontrols}  mean_bright`i'_bl2001   [aw = kernel_tri_ik] , a(year dist_thresh_id) cluster(village_id)  

	append_est_to_file using $f, b(receivedroad) s(`i', avg)

}

*** monthly pollutant emissions ****

gl months Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec 
*baseline BC OC -- total (all) sources
foreach m in $months {

	gen BC_all_`m' = BCEMBB_`m' + BCEMAN_`m'
	gen BC_all_`m'_bl2001 = BCEMBB_`m'_bl2001 + BCEMAN_`m'_bl2001

	gen OC_all_`m' = OCEMBB_`m' + OCEMAN_`m'
	gen OC_all_`m'_bl2001 = OCEMBB_`m'_bl2001 + OCEMAN_`m'_bl2001
}


local i = 1

foreach m in $months {

	ivreghdfe BC_all_`m'	(receivedroad = t) left right ${blcontrols}   BC_all_`m'_bl2001   [aw = kernel_tri_ik] ,  a(year dist_thresh_id) cluster(village_id)  
	append_est_to_file using $f, b(receivedroad) s(`i', BC_all)

	ivreghdfe OC_all_`m'	(receivedroad = t) left right ${blcontrols}   OC_all_`m'_bl2001   [aw = kernel_tri_ik] ,  a(year dist_thresh_id) cluster(village_id)  
	append_est_to_file using $f, b(receivedroad) s(`i', OC_all)

	ivreghdfe BCEMBB_`m'	(receivedroad = t) left right ${blcontrols}   BCEMBB_`m'_bl2001   [aw = kernel_tri_ik] ,  a(year dist_thresh_id) cluster(village_id)  
	append_est_to_file using $f, b(receivedroad) s(`i', BCEMBB)

	ivreghdfe OCEMBB_`m'	(receivedroad = t) left right ${blcontrols}   OCEMBB_`m'_bl2001   [aw = kernel_tri_ik] ,  a(year dist_thresh_id) cluster(village_id)  
	append_est_to_file using $f, b(receivedroad) s(`i', OCEMBB)

	ivreghdfe BCEMAN_`m'	(receivedroad = t) left right ${blcontrols}   BCEMAN_`m'_bl2001   [aw = kernel_tri_ik] ,  a(year dist_thresh_id) cluster(village_id)  
	append_est_to_file using $f, b(receivedroad) s(`i', BCEMAN)

	ivreghdfe OCEMAN_`m'	(receivedroad = t) left right ${blcontrols}   OCEMAN_`m'_bl2001   [aw = kernel_tri_ik] , a(year dist_thresh_id) cluster(village_id)  
	append_est_to_file using $f, b(receivedroad) s(`i', OCEMAN)

	local i = `i' + 1
}

*** Fig 8 - plots ***

preserve

global f  "${tmp}/fcbcoc_monthly.csv"

import delimited using $f, clear

gen sig10 = p <= 0.1

replace depvar = trim(depvar)

la def months 1 Jan 2 Feb 3 Mar 4 Apr 5 May 6 Jun 7 Jul 8 Aug 9 Sep 10 Oct 11 Nov 12 Dec 
la val month months


**** Figure A.8.a *******

#delimit ;

twoway (scatter beta month if sig10 == 1, sort mcolor(black) msymbol(lgx)  mlwidth(medthick)) 
	  (scatter beta month , mcolor(black) msize(*1.2) msymbol(circle_hollow)  mlwidth(medthick)) if depvar == "fc", 
	  ytitle(IV estimate) yline(0, lpattern(dash) lcolor(gs8)) 
	  ylabel(-0.2(0.2)0.4, format(%9.2f) nogrid)  xlabel(1(1)12, valuelabel nogrid alternate) 
	  legend(off) scheme(white_tableau)  
	  xtitle(" ")
	  scale(1.5);

#delimit cr 

graph export "${outdir}/figA8_a.pdf", replace 



**** Figure A.8.b *******

#delimit ;

twoway (scatter beta month if sig10 == 1, sort mcolor(black) msymbol(lgx)  mlwidth(medthick)) 
	  (scatter beta month , mcolor(black) msize(*1.2) msymbol(circle_hollow)  mlwidth(medthick)) if depvar == "tot", 
	  ytitle(IV estimate) yline(0, lpattern(dash) lcolor(gs8)) 
	  ylabel(-25(25)100, format(%9.1f) nogrid)  xlabel(1(1)12, valuelabel nogrid alternate) 
	  legend(off) scheme(white_tableau)  
	  xtitle(" ")
	  scale(1.5);

#delimit cr 

graph export "${outdir}/figA8_b.pdf", replace 


**** Figure A.8.c *******


#delimit ;

twoway (scatter beta month if sig10 == 1, sort mcolor(black) msymbol(lgx)  mlwidth(medthick)) 
	  (scatter beta month , mcolor(black) msize(*1.2) msymbol(circle_hollow)  mlwidth(medthick)) if depvar == "avg", 
	  ytitle(IV estimate) yline(0, lpattern(dash) lcolor(gs8)) 
	  ylabel(-5(5)20, format(%9.1f) nogrid)  xlabel(1(1)12, valuelabel nogrid alternate) 
	  legend(off) scheme(white_tableau)  
	  xtitle(" ")
	  scale(1.5);

#delimit cr 

graph export "${outdir}/figA8_c.pdf", replace 


**** Figure A.8.d *******

#delimit ;

twoway (scatter beta month if sig10 == 1, sort mcolor(black) msymbol(lgx)  mlwidth(medthick)) 
	  (scatter beta month , mcolor(black) msize(*1.2) msymbol(circle_hollow)  mlwidth(medthick)) if depvar == "BC_all", 
	 yline(0, lpattern(dash) lcolor(gs8)) ytitle("IV esimtate")  xtitle(" ")
	  ylabel(-0.1(0.05)0.25, format(%9.2f) nogrid)  xlabel(1(1)12, valuelabel nogrid alternate) 
	  legend(off) scheme(white_tableau)  
	  scale(1.5);

#delimit cr 

graph export "${outdir}/figA8_d.pdf", replace 

**** Figure A.8.e *******

#delimit ;

twoway (scatter beta month if sig10 == 1, sort mcolor(black) msymbol(lgx)  mlwidth(medthick)) 
	  (scatter beta month , mcolor(black) msize(*1.2) msymbol(circle_hollow)  mlwidth(medthick)) if depvar == "BCEMBB", 
	 yline(0, lpattern(dash) lcolor(gs8)) ytitle("IV esimtate")  xtitle(" ")
	  ylabel(-0.1(0.05)0.25, format(%9.2f) nogrid)  xlabel(1(1)12, valuelabel nogrid alternate) 
	  legend(off) scheme(white_tableau)  
	  scale(1.5);

#delimit cr 

graph export "${outdir}/figA8_e.pdf", replace 



**** Figure A.8.f *******

#delimit ;

twoway (scatter beta month if sig10 == 1, sort mcolor(black) msymbol(lgx)  mlwidth(medthick)) 
	  (scatter beta month , mcolor(black) msize(*1.2) msymbol(circle_hollow)  mlwidth(medthick)) if depvar == "BCEMAN", 
	 yline(0, lpattern(dash) lcolor(gs8)) ytitle("IV esimtate")  xtitle(" ")
	  ylabel(-0.1(0.05)0.25, format(%9.2f) nogrid)  xlabel(1(1)12, valuelabel nogrid alternate) 
	  legend(off) scheme(white_tableau)  
	  scale(1.5);

#delimit cr 

graph export "${outdir}/figA8_f.pdf", replace 

**** Figure A.8.g *******

#delimit ;

twoway (scatter beta month if sig10 == 1, sort mcolor(black) msymbol(lgx)  mlwidth(medthick)) 
	  (scatter beta month , mcolor(black) msize(*1.2) msymbol(circle_hollow)  mlwidth(medthick)) if depvar == "OC_all", 
	 yline(0, lpattern(dash) lcolor(gs8)) ytitle("IV esimtate")  xtitle(" ")
	  ylabel(-0.5(0.5)2, format(%9.2f) nogrid)  xlabel(1(1)12, valuelabel nogrid alternate) 
	  legend(off) scheme(white_tableau)  
	  scale(1.5);

#delimit cr 

graph export "${outdir}/figA8_g.pdf", replace 

**** Figure A.8.h *******

#delimit ;

twoway (scatter beta month if sig10 == 1, sort mcolor(black) msymbol(lgx)  mlwidth(medthick)) 
	  (scatter beta month , mcolor(black) msize(*1.2) msymbol(circle_hollow)  mlwidth(medthick)) if depvar == "OCEMBB", 
	 yline(0, lpattern(dash) lcolor(gs8)) ytitle("IV esimtate")  xtitle(" ")
	  ylabel(-0.5(0.5)2, format(%9.2f) nogrid)  xlabel(1(1)12, valuelabel nogrid alternate) 
	  legend(off) scheme(white_tableau)  
	  scale(1.5);

#delimit cr 

graph export "${outdir}/figA8_h.pdf", replace 


**** Figure A.8.i *******

#delimit ;

twoway (scatter beta month if sig10 == 1, sort mcolor(black) msymbol(lgx)  mlwidth(medthick)) 
	  (scatter beta month , mcolor(black) msize(*1.2) msymbol(circle_hollow)  mlwidth(medthick)) if depvar == "OCEMAN", 
	 yline(0, lpattern(dash) lcolor(gs8)) ytitle("IV esimtate")  xtitle(" ")
	  ylabel(-0.5(0.5)2, format(%9.2f) nogrid)  xlabel(1(1)12, valuelabel nogrid alternate) 
	  legend(off) scheme(white_tableau)  
	  scale(1.5);

#delimit cr 

graph export "${outdir}/figA8_i.pdf", replace 

restore


************************************
**** Figure A.9 *******
************************************

use "${dtadir}/gjp_main_working.dta", clear 

gen rloshi = rice_hi == 0 & sugar_hi == 1
gen rhishi = rice_hi == 1 & sugar_hi == 1
gen rloslo = rice_hi == 0 & sugar_hi == 0
gen rhislo = rice_hi == 1 & sugar_hi == 0

gen rhi_or_shi = rhislo == 1 | rloshi == 1

reg fires2001_10km rloslo rhi_or_shi rhishi, nocons 

eststo blfcmeans

#delimit ;
coefplot blfcmeans , keep(rloslo rhi_or_shi) scheme(white_tableau) vert 
recast(bar) noci barwidt(0.3) color(%80)
ylabel(0(0.2)1)  
coeflabel(rloslo = `""{bf:Low Rice}" "AND" "{bf:Low Sugar}""' 
	rhi_or_shi = `""{bf:High Rice}" "OR" "{bf:High Sugar}""' )
ytitle("{bf: Baseline fire counts in 2001}", size(*1.5)) 
ylabel( ,nogrid)
mlabel format(%9.2f) mlabposition(1) mlabgap(*2) mlabcolor(black)
;

#delimit cr 

graph export "${outdir}/figA9.pdf", replace 


************************************
**** Figure A.10 *******
************************************

use "${dtadir}/labshare_wage_f2001.dta", clear 

**** Figure A.10.a *******

binsreg fires2001_10km  ag_lab_share    ,  absorb(pc01_state_id ) polyreg(1)  polyregplotopt(lpattern(dash) lcolor(red)) nbins(12) xtitle("{bf: Share of labor in agriculture}") ytitle("{bf: Annual fire activity}") scheme(white_tableau) scale(1.5) plotregion(fcolor(white)) xscale(line) yscale(line) xlabel(0(0.2)1,  nogrid) ylabel(0(0.5)1.5,  nogrid)

graph export "${outdir}/figA10_a.pdf", replace 

**** Figure A.10.b *******

binsreg fires2001_10km  agwage_rel_nonag   ,  absorb(pc01_state_id ) polyreg(1)  polyregplotopt(lpattern(dash) lcolor(red)) nbins(12) xtitle("{bf: Agricultural wage rate}" "{bf: (relative to non-agricultural sectors)}") ytitle("{bf: Annual fire activity}") scheme(white_tableau) scale(1.5) plotregion(fcolor(white)) xscale(line) yscale(line) xlabel(0(0.2)1.2, nogrid) ylabel(0(0.5)1.5, nogrid)

graph export "${outdir}/figA10_b.pdf", replace 

************************************
**** Table A.1 *******
************************************

use "${dtadir}/gjp_main_working.dta", clear 

#delimit ;
gl blcontrols primary_school med_center elect tdist irr_share 
  ln_land pc01_lit_share pc01_sc_share bpl_landed_share bpl_inc_source_sub_share
  bpl_inc_250plus  ;
#delimit cr 


est clear

ivreghdfe brightsum_ (receivedroad = t) left right ${blcontrols}  brightsum_bl2001 [aw = kernel_tri_ik] ,  a(year dist_thresh_id) cluster(village_id)  

eststo ivbrightsum
su brightsum_ if e(sample) & t == 0
estadd scalar depvarmean = r(mean)

ivreghdfe brightmean_ (receivedroad = t) left right ${blcontrols}  brightmean_bl2001 [aw = kernel_tri_ik] , a(year dist_thresh_id) cluster(village_id)  

eststo ivbrightmean
su brightmean_ if e(sample) & t == 0
estadd scalar depvarmean = r(mean)

esttab ivbrightsum ivbrightmean  using "${outdir}/tableA1.tex" , replace keep(receivedroad  ) coeflabels( receivedroad "Road built") mgroups("Annual fires intensity",  pattern(1 0) $estmgroupopts  )    mtitles("Total"  "Average") $estopts  $eststatopts


************************************
**** Table A.2 *******
************************************

use "${dtadir}/gjp_main_working.dta", clear 

#delimit ;
gl blcontrols primary_school med_center elect tdist irr_share 
  ln_land pc01_lit_share pc01_sc_share bpl_landed_share bpl_inc_source_sub_share
  bpl_inc_250plus  ;
#delimit cr 

est clear



ivreghdfe fires10km (receivedroad = t) left right ${blcontrols}  fires2001_10km if mech_hi == 1 & _m_mech == 3  ,  a(year dist_thresh_id) cluster(village_id)  
eststo fhi
sum fires10km  if e(sample) &  t == 0
estadd scalar depvarmean = r(mean)

ivreghdfe fires10km (receivedroad = t) left right ${blcontrols}  fires2001_10km if mech_hi == 0 & _m_mech == 3 ,  a(year dist_thresh_id) cluster(village_id)  
eststo flo
sum fires10km  if e(sample) &  t == 0
estadd scalar depvarmean = r(mean)

ivreghdfe pm25 (receivedroad = t) left right ${blcontrols}   pm25_bl2001 if mech_hi == 1 & _m_mech == 3 ,  a(year dist_thresh_id) cluster(village_id)  
eststo pmhi
sum pm25  if e(sample) &  t == 0
estadd scalar depvarmean = r(mean)

ivreghdfe pm25 (receivedroad = t) left right ${blcontrols}   pm25_bl2001 if mech_hi == 0 & _m_mech == 3,  a(year dist_thresh_id) cluster(village_id)  
eststo pmlo
sum pm25  if e(sample) &  t == 0
estadd scalar depvarmean = r(mean)



esttab fhi pmhi flo pmlo  ///
     using "${outdir}/tableA2.tex" , ///
    $estopts $eststatopts  replace ///
    keep(receivedroad) coeflabels( receivedroad "Road built") ///
    mgroups("High mechanization index" "Low mechanization index" , ///
      pattern(1  0 1 0) $estmgroupopts) ///
    mtitles("Fires" "PM 2.5" "Fires" "PM 2.5")



************************************
**** Table A.3 *******
************************************

use "${dtadir}/gjp_main_working.dta", clear 

#delimit ;
gl blcontrols primary_school med_center elect tdist irr_share 
  ln_land pc01_lit_share pc01_sc_share bpl_landed_share bpl_inc_source_sub_share
  bpl_inc_250plus  ;
#delimit cr 

est clear

** high rice districts **
keep if _m_mech == 3
cap drop rice_hi
foreach var in rice  {
  sum `var' , d 
  local cut `r(p50)'
  gen `var'_hi = `var' >= `cut' if !mi(`var') 
}  



keep if rice_hi == 1

*mechanization index for high rice districts*
cap drop z_*

foreach v of varlist power_* {
		egen z_`v' = std(`v')
}   

egen z_mech = rowtotal(z_*)
cap drop mech_hi
su z_mech , d
gen mech_hi = z_mech >= r(p50)


ivreghdfe fires10km (receivedroad = t) left right ${blcontrols}  fires2001_10km if mech_hi == 1 ,  a(year dist_thresh_id) cluster(village_id)  
eststo fhi
sum fires10km  if e(sample) &  t == 0
estadd scalar depvarmean = r(mean)

ivreghdfe fires10km (receivedroad = t) left right ${blcontrols}  fires2001_10km if mech_hi == 0 ,  a(year dist_thresh_id) cluster(village_id)  
eststo flo
sum fires10km  if e(sample) &  t == 0
estadd scalar depvarmean = r(mean)

ivreghdfe pm25 (receivedroad = t) left right ${blcontrols}   pm25_bl2001 if mech_hi == 1 ,  a(year dist_thresh_id) cluster(village_id)  
eststo pmhi
sum pm25  if e(sample) &  t == 0
estadd scalar depvarmean = r(mean)

ivreghdfe pm25 (receivedroad = t) left right ${blcontrols}   pm25_bl2001 if mech_hi == 0 ,  a(year dist_thresh_id) cluster(village_id)  
eststo pmlo
sum pm25  if e(sample) &  t == 0
estadd scalar depvarmean = r(mean)



esttab fhi pmhi flo pmlo  ///
     using "${outdir}/tableA3.tex" , ///
    $estopts $eststatopts  replace ///
    keep(receivedroad) coeflabels( receivedroad "Road built") ///
    mgroups("High mechanization index" "Low mechanization index" , ///
      pattern(1  0 1 0) $estmgroupopts) ///
    mtitles("Fires" "PM 2.5" "Fires" "PM 2.5")



************************************
**** Table A.4. *******
************************************

use "${dtadir}/gjp_main_working.dta", clear 

#delimit ;
gl blcontrols primary_school med_center elect tdist irr_share 
  ln_land pc01_lit_share pc01_sc_share bpl_landed_share bpl_inc_source_sub_share
  bpl_inc_250plus  ;
#delimit cr 

est clear

** high rice districts **
keep if _m_mech == 3
cap drop rice_hi
foreach var in rice  {
  sum `var' , d 
  local cut `r(p50)'
  gen `var'_hi = `var' >= `cut' if !mi(`var') 
}  


keep if rice_hi == 1

*rice-harvesting mechanization index for high rice districts*
cap drop z_mech
egen z_mech = rowtotal(z_power_combine_trailer z_power_combine_self_propell )
cap drop mech_hi
su z_mech, d
gen mech_hi = z_mech > r(p50)


ivreghdfe fires10km (receivedroad = t) left right ${blcontrols}  fires2001_10km if mech_hi == 1 ,  a(year dist_thresh_id) cluster(village_id)  
eststo fhi
sum fires10km  if e(sample) &  t == 0
estadd scalar depvarmean = r(mean)

ivreghdfe fires10km (receivedroad = t) left right ${blcontrols}  fires2001_10km if mech_hi == 0 ,  a(year dist_thresh_id) cluster(village_id)  
eststo flo
sum fires10km  if e(sample) &  t == 0
estadd scalar depvarmean = r(mean)

ivreghdfe pm25 (receivedroad = t) left right ${blcontrols}   pm25_bl2001 if mech_hi == 1 ,  a(year dist_thresh_id) cluster(village_id)  
eststo pmhi
sum pm25  if e(sample) &  t == 0
estadd scalar depvarmean = r(mean)

ivreghdfe pm25 (receivedroad = t) left right ${blcontrols}   pm25_bl2001 if mech_hi == 0 ,  a(year dist_thresh_id) cluster(village_id)  
eststo pmlo
sum pm25  if e(sample) &  t == 0
estadd scalar depvarmean = r(mean)


esttab fhi pmhi flo pmlo  ///
     using "${outdir}/tableA4.tex" , ///
    $estopts $eststatopts  replace ///
    keep(receivedroad) coeflabels( receivedroad "Road built") ///
    mgroups("High mechanization index" "Low mechanization index" , ///
      pattern(1  0 1 0) $estmgroupopts) ///
    mtitles("Fires" "PM 2.5" "Fires" "PM 2.5")


************************************
**** Table A.5. *******
************************************

use "${dtadir}/gjp_main_working.dta", clear 

#delimit ;
gl blcontrols primary_school med_center elect tdist irr_share 
  ln_land pc01_lit_share pc01_sc_share bpl_landed_share bpl_inc_source_sub_share
  bpl_inc_250plus  ;
#delimit cr 

est clear



   
ivreghdfe fires10km (receivedroad = t) left right ${blcontrols}  fires2001_10km if unskilled_wage_gap_high == 1 [aw = kernel_tri_ik],  a(year dist_thresh_id) cluster(village_id)  
eststo fires10kmivwagegaphi
sum fires10km if e(sample) &  t == 0
estadd scalar depvarmean = r(mean)

ivreghdfe fires10km (receivedroad = t) left right ${blcontrols}  fires2001_10km if unskilled_wage_gap_high == 0 [aw = kernel_tri_ik],  a(year dist_thresh_id) cluster(village_id)  
eststo fires10kmivwagegaplo
sum fires10km if e(sample) &  t == 0
estadd scalar depvarmean = r(mean)

ivreghdfe fires10km (receivedroad = t) left right ${blcontrols}  fires2001_10km if ret_gap_high == 1 [aw = kernel_tri_ik],  a(year dist_thresh_id) cluster(village_id)  
eststo fires10kmivretgaphi
sum fires10km if e(sample) &  t == 0
estadd scalar depvarmean = r(mean)

ivreghdfe fires10km (receivedroad = t) left right ${blcontrols}  fires2001_10km if ret_gap_high == 0 [aw = kernel_tri_ik],  a(year dist_thresh_id) cluster(village_id)  
eststo fires10kmivretgaplo
sum fires10km if e(sample) &  t == 0
estadd scalar depvarmean = r(mean)



esttab fires10kmivwagegaphi fires10kmivwagegaplo fires10kmivretgaphi fires10kmivretgaplo ///
     using "${outdir}/tableA5.tex" , ///
    $estopts $eststatopts  replace ///
    keep(receivedroad) coeflabels( receivedroad "Road built") ///
   mgroups("Opportunity cost effect" "Returns to education effect" , ///
    pattern(1 0 1 0) $estmgroupopts ) ///
    mtitles("High" "Low" "High" "Low")


 ******** END *********