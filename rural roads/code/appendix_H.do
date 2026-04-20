*** .do file to replicate:
*** Appendix H


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
**** Table H.1. *****
************************************

gl PYTHONPATH "$dodir/stata-tex"
gl table_templates "$dodir/stata-tex/balance_table_tpl"

do "$dodir/stata-tex/stata-tex.do"

cap rm "$tmp/balancedata_2.csv"

use "${dtadir}/gjp_main_working.dta", clear 
keep if year == 2012 | year == .
rename pm25_bl2001 pm25_2001

global outcomes  primary_school med_center elect tdist irr_share ln_land pc01_lit_share pc01_sc_share bpl_landed_share bpl_inc_source_sub_share bpl_inc_250plus  fires2001_10km   

foreach i in $outcomes {

  /* mean full sample */
  sum `i' 
  local btmean `r(mean)'
  store_val_tpl using "$tmp/balancedata_2.csv", name("`i'_mean") value(`r(mean)') format("%5.3f")
  store_val_tpl using "$tmp/balancedata_2.csv", name("N_mean") value(`r(N)') format("%10.0f")
  
  /* mean NFHS matched sample */
  sum `i' if matchedNFHS_50km == 1
  local btmean `r(mean)'
  store_val_tpl using "$tmp/balancedata_2.csv", name("`i'_bt") value(`r(mean)') format("%5.3f")
  store_val_tpl using "$tmp/balancedata_2.csv", name("N_bt") value(`r(N)') format("%10.0f")

  /* mean unmatched sample */
  sum `i' if matchedNFHS_50km == 0
  local otmean `r(mean)'
  store_val_tpl using "$tmp/balancedata_2.csv", name("`i'_ot") value(`r(mean)') format("%5.3f")
  store_val_tpl using "$tmp/balancedata_2.csv", name("N_ot") value(`r(N)') format("%10.0f")

  /* difference */
  local diff = `otmean' - `btmean'
  store_val_tpl using "$tmp/balancedata_2.csv", name("`i'_dm") value(`diff') format("%5.3f")


  areg `i' matchedNFHS_50km , a(dist_thresh_id)
  store_est_tpl using "$tmp/balancedata_2.csv", name("`i'") coef(matchedNFHS_50km) format("%5.3f") beta p

  /* rd estimate - matched sample */

  ivregress 2sls `i' (r2012=t) left right i.dist_thresh_id [aw= kernel_tri_ik] if matchedNFHS_50km == 1, r
  
  store_est_tpl using "$tmp/balancedata_2.csv", name("`i'_rd") coef(r2012) format("%5.3f") beta p
    
}

gl outcomes  pm25_2001 

foreach i in $outcomes {
  
  /* mean full sample */
  sum `i' 
  local btmean `r(mean)'
  store_val_tpl using "$tmp/balancedata_2.csv", name("`i'_mean") value(`r(mean)') format("%5.3f")
  store_val_tpl using "$tmp/balancedata_2.csv", name("N_mean") value(`r(N)') format("%10.0f")
  
  /* mean matched sample */
  sum `i' if matchedNFHS_50km == 1
  local btmean `r(mean)'
  store_val_tpl using "$tmp/balancedata_2.csv", name("`i'_bt") value(`r(mean)') format("%5.3f")
  store_val_tpl using "$tmp/balancedata_2.csv", name("N_bt") value(`r(N)') format("%10.0f")

  /* mean unmatched sample */
  sum `i' if matchedNFHS_50km == 0
  local otmean `r(mean)'
  store_val_tpl using "$tmp/balancedata_2.csv", name("`i'_ot") value(`r(mean)') format("%5.3f")
  store_val_tpl using "$tmp/balancedata_2.csv", name("N_ot") value(`r(N)') format("%10.0f")

  /* difference */
  local diff = `otmean' - `btmean'
  store_val_tpl using "$tmp/balancedata_2.csv", name("`i'_dm") value(`diff') format("%5.3f")

  /* test equality of means */
  local exclude `i'
  local controls $controls
  local controls_here : list controls - exclude
  reg `i' matchedNFHS_50km `controls_here', vce(robust)
  store_est_tpl using "$tmp/balancedata_2.csv", name("`i'") coef(matchedNFHS_50km) format("%5.3f") beta p 

  /* rd estimate - matched sample */
  local exclude `i'
  local controls_here : list controls - exclude
  ivregress 2sls `i' (r2012=t) left right `controls_here'   i.dist_thresh_id [aw= kernel_tri_ik] if matchedNFHS_50km == 1, r
  
  store_est_tpl using "$tmp/balancedata_2.csv", name("`i'_rd") coef(r2012) format("%5.3f") beta p
    
}

use if pmgsy_nfhs_km <= 50 & year == 2001 using "${dtadir}/gjp_main_data_birthsdown.dta", clear 
rename child_die_age1 imr2001

foreach i in imr2001 {
  
  /* mean matched  sample */
  sum `i'
  local btmean `r(mean)'
  store_val_tpl using "$tmp/balancedata_2.csv", name("`i'_bt") value(`r(mean)') format("%5.3f")
  store_val_tpl using "$tmp/balancedata_2.csv", name("N_bt") value(`r(N)') format("%10.0f")
  
  
  /* rd estimate */
  ivreghdfe `i'  (r2012 = t) left right  ,  a( dist_thresh_id) cluster(village_id)  
  store_est_tpl using "$tmp/balancedata_2.csv", name("`i'_rd") coef(r2012) format("%5.3f") beta p
  
}

use if pmgsy_nfhs_km <= 50 & year == 2001 using "${dtadir}/gjp_main_data_birthsother.dta", clear 
rename child_die_age1 oimr2001


foreach i in oimr2001 {
  
  /* mean matched  sample */
  sum `i' 
  local btmean `r(mean)'
  store_val_tpl using "$tmp/balancedata_2.csv", name("`i'_bt") value(`r(mean)') format("%5.3f")
  store_val_tpl using "$tmp/balancedata_2.csv", name("N_bt") value(`r(N)') format("%10.0f")
  
  
  /* rd estimate */
 ivreghdfe `i'  (r2012 = t) left right   ,  a( dist_thresh_id) cluster(village_id)  
  store_est_tpl using "$tmp/balancedata_2.csv", name("`i'_rd") coef(r2012) format("%5.3f") beta p
  
}

use "${dtadir}/gjp_main_data_dhspm50km.dta", clear 

rename downwind_dhs_pm25_bl2001 dhs_pm25_2001
rename nondown_dhs_pm25_bl2001 odhs_pm25_2001
keep if year == 2001

foreach i in dhs_pm25_2001 odhs_pm25_2001 {
  
  /* mean matched  sample */
  sum `i' 
  local btmean `r(mean)'
  store_val_tpl using "$tmp/balancedata_2.csv", name("`i'_bt") value(`r(mean)') format("%5.3f")
  store_val_tpl using "$tmp/balancedata_2.csv", name("N_bt") value(`r(N)') format("%10.0f")
  
  
  /* rd estimate */
 ivreghdfe `i'  (r2012 = t) left right ${blcontrols}   ,  a( dist_thresh_id) cluster(village_id)  
  store_est_tpl using "$tmp/balancedata_2.csv", name("`i'_rd") coef(r2012) format("%5.3f") beta p
  
}


table_from_tpl, t("$table_templates/balance_tpl_2.tex") r("$tmp/balancedata_2.csv") o("$outdir/tableH1.tex") dropstars


************************************
**** Table H.2. *****
************************************

*** run using "code/appendix_H_tabH2.R"



************************************
**** Table H.3. *****
************************************

est clear 

use if pmgsy_nfhs_km <= 50 using "${dtadir}/gjp_main_data_birthsdown.dta", clear 
ivreghdfe child_die_age1  (receivedroad = t) left right  $blcontrols, a(year dist_thresh_id) cluster(dist_thresh_id) 

eststo imrdown50km
su child_die_age1 if e(sample) & t == 0
estadd scalar depvarmean = r(mean)


use if pmgsy_nfhs_km <= 50 using "${dtadir}/gjp_main_data_birthsother.dta", clear 
ivreghdfe child_die_age1  (receivedroad = t) left right  $blcontrols, a(year dist_thresh_id) cluster(dist_thresh_id) 
eststo imrup50km
su child_die_age1 if e(sample) & t == 0
estadd scalar depvarmean = r(mean)


use "${dtadir}/gjp_main_data_dhspm50km.dta", clear 
ivreghdfe downwind_dhs_pm25  (receivedroad = t) left right downwind_dhs_pm25_bl2001 if year > 2001, a(year dist_thresh_id) cluster(dist_thresh_id) 
eststo pmdown50km
su downwind_dhs_pm25 if e(sample) & t == 0
estadd scalar depvarmean = r(mean)

ivreghdfe nondown_dhs_pm25 (receivedroad = t) left right nondown_dhs_pm25_bl2001 if year > 2001, a(year dist_thresh_id) cluster(dist_thresh_id) 
eststo pmup50km
su nondown_dhs_pm25 if e(sample) & t == 0
estadd scalar depvarmean = r(mean)


#delimit ;
esttab pmdown50km imrdown50km  pmup50km imrup50km using 
  "${outdir}/tableH3.tex" , replace keep(receivedroad  ) 
  coeflabels(receivedroad "Road built") mgroups("Downwind" "Other directions" ,  pattern(1 0 1 0 ) $estmgroupopts  )   
   mtitles("PM 2.5"  "Infant mortality" "PM 2.5"  "Infant mortality") $estopts  
   stat(N , label("N"   ) fmt(%12.0fc ))  ;
#delimit cr 


************************************
**** Table H.4. *****
************************************
est clear

use "${dtadir}/appH_pmgsy_wind.dta", clear
xtset village_id year, yearly
reg wdir_med l.wdir_med, vce(cluster village_id) 
eststo pmgsywdir

use "${dtadir}/appH_nfhs_wind.dta", clear
xtset cluster_code year, yearly
reg down_1yes l.dw_lag, vce(cluster cluster_code)
eststo nfhswdir

esttab pmgsywdir nfhswdir using "${outdir}/tableH4.tex" ,  replace keep(L.wdir_med L.dw_lag) coeflabels(L.wdir_med "Wind direction in $ year_{t-1} $" L.dw_lag "Downwind in $ year_{t-1} $") mgroups("PMGSY villages" "NFHS-IV clusters" ,  pattern(1 1 ) $estmgroupopts  )    mtitles("Wind direction in $ year_{t} $" "Downwind in $ year_{t} $") $estopts  stat(N r2 , label("N" "$ R^{2} $" ) fmt(%12.0fc %9.3f))


************************************
**** Table H.5. *****
************************************
est clear 
use if pmgsy_nfhs_km <= 50 & downwind2001 ==1 using "${dtadir}/appH_2001wdir_births.dta", clear 
ivreghdfe child_die_age1  (receivedroad = t) left right    , a( year dist_thresh_id#birthmonth   ) cluster(village_id )
eststo imrdown50km
su child_die_age1 if e(sample) & t == 0
estadd scalar depvarmean = r(mean)

use if pmgsy_nfhs_km <= 50 & downwind2001 == 0 using "${dtadir}/appH_2001wdir_births.dta", clear 
ivreghdfe child_die_age1  (receivedroad = t) left right    , a( year dist_thresh_id#birthmonth   ) cluster(village_id )
eststo imrup50km
su child_die_age1 if e(sample) & t == 0
estadd scalar depvarmean = r(mean)


use "${dtadir}/appH_2001wdir_dhspm50km.dta", clear 

ivreghdfe downwind_dhs_pm25  (receivedroad = t) left right downwind_dhs_pm25_bl2001 , a(year dist_thresh_id) cluster(village_id) 
eststo pmdown50km
su downwind_dhs_pm25 if e(sample) & t == 0
estadd scalar depvarmean = r(mean)

ivreghdfe nondown_dhs_pm25 (receivedroad = t) left right nondown_dhs_pm25_bl2001 , a(year dist_thresh_id) cluster(village_id) 
eststo pmup50km
su nondown_dhs_pm25 if e(sample) & t == 0
estadd scalar depvarmean = r(mean)


esttab pmdown50km imrdown50km  pmup50km imrup50km using "${outdir}/tableH5.tex" , replace keep(receivedroad  ) coeflabels(receivedroad "Road built") mgroups("Downwind" "Other directions" ,  pattern(1 0 1 0 ) $estmgroupopts  )    mtitles("PM 2.5"  "Infant mortality" "PM 2.5"  "Infant mortality") b(4) se(4) varwidth(25) label se starlevels(* 0.1 ** 0.05 *** 0.01) nonotes nodepvars  stat(N depvarmean , label("N"  "Control group mean"  ) fmt(%12.0fc %13.4fc)) 

************************************
**** Table H.6. *****
************************************

est clear 
use if pmgsy_nfhs_km <= 50 & nomove ==1 using "${dtadir}/gjp_main_data_birthsdown.dta", clear 
ivreghdfe child_die_age1  (receivedroad = t) left right    , a( year dist_thresh_id#birthmonth   ) cluster(village_id )
eststo imrdown50km
su child_die_age1 if e(sample) & t == 0
estadd scalar depvarmean = r(mean)

use if pmgsy_nfhs_km <= 50 & nomove ==1 using "${dtadir}/gjp_main_data_birthsother.dta", clear 
ivreghdfe child_die_age1  (receivedroad = t) left right    , a( year dist_thresh_id#birthmonth   ) cluster(village_id )
eststo imrup50km
su child_die_age1 if e(sample) & t == 0
estadd scalar depvarmean = r(mean)


use "${dtadir}/appH_nomovers_dhspm50km.dta", clear 

ivreghdfe downwind_dhs_pm25  (receivedroad = t) left right downwind_dhs_pm25_bl2001 , a(year dist_thresh_id) cluster(village_id) 
eststo pmdown50km
su downwind_dhs_pm25 if e(sample) & t == 0
estadd scalar depvarmean = r(mean)

ivreghdfe nondown_dhs_pm25 (receivedroad = t) left right nondown_dhs_pm25_bl2001 , a(year dist_thresh_id) cluster(village_id) 
eststo pmup50km
su nondown_dhs_pm25 if e(sample) & t == 0
estadd scalar depvarmean = r(mean)


esttab pmdown50km imrdown50km  pmup50km imrup50km using "${outdir}/tableH6.tex" , replace keep(receivedroad  ) coeflabels(receivedroad "Road built") mgroups("Downwind" "Other directions" ,  pattern(1 0 1 0 ) $estmgroupopts  )    mtitles("PM 2.5"  "Infant mortality" "PM 2.5"  "Infant mortality") b(4) se(4) varwidth(25) label se starlevels(* 0.1 ** 0.05 *** 0.01) nonotes nodepvars  stat(N depvarmean , label("N"  "Control group mean"  ) fmt(%12.0fc %13.4fc)) 


************************************
**** Table H.7. *****
************************************

use "${dtadir}/gjp_main_working.dta", clear 
keep if year == 2012 | year == .



ivreghdfe nbor_pc11_pca_tot_p   (r2012 = t) left right $blcontrols  nbor_pc01_pca_tot_p    , a(dist_thresh_id  ) vce(cluster village_id)
eststo poplvl
sum nbor_pc11_pca_tot_p if e(sample) & t == 0
estadd scalar outcome_mean = r(mean)

gen nbor_pc01_pop_ln = log(nbor_pc01_pca_tot_p)

ivreghdfe nbor_pc11_pop_ln    (r2012 = t) left right $blcontrols  nbor_pc01_pop_ln   , a(dist_thresh_id  ) vce(cluster village_id)
eststo poplog
sum nbor_pc11_pop_ln if e(sample) & t == 0
estadd scalar outcome_mean = r(mean)


foreach agegroup in 11_20 21_30 31_40 41_50 51_60 {
  ivreghdfe  nbor_secc_age_share_`agegroup'  (r2012 = t) left right $blcontrols    , a(dist_thresh_id  ) robust
  eststo iv`agegroup'
  sum nbor_secc_age_share_`agegroup' if e(sample) & t == 0
  estadd scalar outcome_mean = r(mean)

}


foreach agegroup in 11_20 21_30 31_40 41_50 51_60 {
    ivreghdfe nbor_secc_male_share_`agegroup'  (r2012 = t) left right ${blcontrols}  , a(dist_thresh_id  ) vce(cluster village_id)
  eststo ivmale`agegroup'
  sum nbor_secc_male_share_`agegroup' if e(sample) & t == 0
  estadd scalar outcome_mean = r(mean)

}


* Top panel
#delimit ;
esttab poplog poplvl using "${outdir}/tableH7.tex", 
prehead("\begin{tabular}{l*{2}{c}} \hline") 
posthead("\hline \\ \multicolumn{3}{c}{\textit{Panel A: Population growth (2001 - 2011)}} \\\\ [-1ex] \hline 
       &\multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} \\
       &\multicolumn{1}{c}{Log} &\multicolumn{1}{c}{Level} \\ \hline")       
nonumbers  nonotes nomtitles nodepvars fragment replace 
keep(r2012 ) coeflabels(r2012 "Road built") b(4) se(4) varwidth(25) label  
stat(N outcome_mean , label("N"   "Control group mean") fmt(%12.0fc %13.2fc)) 
se starlevels(* 0.1 ** 0.05 *** 0.01)  
prefoot("\hline") 
postfoot("\hline \end{tabular}")  ;

#delimit cr 

* Panel B
#delimit ;
esttab iv11_20 iv21_30 iv31_40 iv41_50 iv51_60 using "${outdir}/tableH7.tex", 
prehead("\begin{tabular}{l*{6}{c}}") 
posthead("\\ \multicolumn{6}{c}{\textit{Panel B: Age group share}} \\\\ [-1ex] \hline 
          &\multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} &\multicolumn{1}{c}{(3)}
         &\multicolumn{1}{c}{(4)} &\multicolumn{1}{c}{(5)}  \\
         &\multicolumn{1}{c}{11 - 20} &\multicolumn{1}{c}{21 - 30}
         &\multicolumn{1}{c}{31 - 40} &\multicolumn{1}{c}{41 - 50}  &\multicolumn{1}{c}{51 - 60}  \\ \hline")
fragment append nonotes nonumbers nomtitles nodepvars 
keep(r2012 )  b(4) se(4) varwidth(25) label 
stat(N outcome_mean, label("N"   "Control group mean" ) fmt(%12.0fc %13.2fc)) 
se starlevels(* 0.1 ** 0.05 *** 0.01) coeflabels( r2012 "Road built")  ;
#delimit cr 

* Panel C
#delimit ;
esttab ivmale11_20 ivmale21_30 ivmale31_40 ivmale41_50 ivmale51_60 using "${outdir}/tableH7.tex", 
posthead("\hline \\ \multicolumn{6}{c}{\textit{Panel C: Male share by age group}} \\\\ [-1ex] \hline 
          &\multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} &\multicolumn{1}{c}{(3)}
         &\multicolumn{1}{c}{(4)} &\multicolumn{1}{c}{(5)}  \\
         &\multicolumn{1}{c}{11 - 20} &\multicolumn{1}{c}{21 - 30}
         &\multicolumn{1}{c}{31 - 40} &\multicolumn{1}{c}{41 - 50}  &\multicolumn{1}{c}{51 - 60}  \\ \hline")
fragment append nonotes nonumbers nomtitles nodepvars 
keep(r2012 )  b(4) se(4) varwidth(25) label 
stat(N outcome_mean, label("N"   "Control group mean" ) fmt(%12.0fc %13.2fc)) 
se starlevels(* 0.1 ** 0.05 *** 0.01) coeflabels( r2012 "Road built") 
prefoot("\hline") 
postfoot("\hline\hline \end{tabular}")  ;
#delimit cr 


************************************
**** Table H.8. *****
************************************

est clear 
use if pmgsy_nfhs_km <= 50 using "${dtadir}/appH_nomigrant_birthsdown.dta", clear 
ivreghdfe child_die_age1  (receivedroad = t) left right    , a( year dist_thresh_id#birthmonth   ) cluster(village_id )
eststo imrdown50km
su child_die_age1 if e(sample) & t == 0
estadd scalar depvarmean = r(mean)

use if pmgsy_nfhs_km <= 50 using "${dtadir}/appH_nomigrant_birthsother.dta", clear 
ivreghdfe child_die_age1  (receivedroad = t) left right    , a( year dist_thresh_id#birthmonth   ) cluster(village_id )
eststo imrup50km
su child_die_age1 if e(sample) & t == 0
estadd scalar depvarmean = r(mean)


use "${dtadir}/appH_nomigrant_dhspm50km.dta", clear 

ivreghdfe downwind_dhs_pm25  (receivedroad = t) left right downwind_dhs_pm25_bl2001 , a(year dist_thresh_id) cluster(village_id) 
eststo pmdown50km
su downwind_dhs_pm25 if e(sample) & t == 0
estadd scalar depvarmean = r(mean)

ivreghdfe nondown_dhs_pm25 (receivedroad = t) left right nondown_dhs_pm25_bl2001 , a(year dist_thresh_id) cluster(village_id) 
eststo pmup50km
su nondown_dhs_pm25 if e(sample) & t == 0
estadd scalar depvarmean = r(mean)


esttab pmdown50km imrdown50km  pmup50km imrup50km using "${outdir}/tableH8.tex" , replace keep(receivedroad  ) coeflabels(receivedroad "Road built") mgroups("Downwind" "Other directions" ,  pattern(1 0 1 0 ) $estmgroupopts  )    mtitles("PM 2.5"  "Infant mortality" "PM 2.5"  "Infant mortality") b(4) se(4) varwidth(25) label se starlevels(* 0.1 ** 0.05 *** 0.01) nonotes nodepvars  stat(N depvarmean , label("N"  "Control group mean"  ) fmt(%12.0fc %13.4fc)) 


************************************
/* NOTE:  Code for the the two panels in Figure H.1. is computationally intensive. 
Regressions for each panel take more than 2.5 hours to execute on 16 GB, Apple M1 machine. 
Skip if computational resources/time is a constraint */
************************************

************************************
**** Figure H.1.a *****
************************************

use "${dtadir}/gjp_main_data_birthsdown.dta", clear 
est clear 

gl coeflabelstr

forval r = 10(5)75 {
  
  preserve 

  keep if  pmgsy_nfhs_km <`r'
  ivreghdfe child_die_age1  (receivedroad = t) left right    , a( year dist_thresh_id#birthmonth   ) cluster(village_id )  //other controls omitted to speed up computation; estimates remain similar when including baseline controls
  eststo imrdown`r'km 

  restore 

}  

gl coeflabelstr

forval r = 10(5)75 {
  gl coeflabelstr ${coeflabelstr} imrdown`r'km  = "`r'"
}


#delimit ;
coefplot imrdown*km , keep(receivedroad) 
  asequation swapnames vert 
  coeflabels(${coeflabelstr}) 
  legend(off) 
  nooffsets
  yline(0, lcolor(red) lpattern(dash))
  ciopts(recast(rcap) lpattern(dash)  lwidth(medium) lcolor(black))
  xlabel(,nogrid)
  ylabel(-0.02(0.01)0.04, nogrid)
  mcolor(black) msize(medlarge)
  ytitle("{bf: IV estimate & 95% CI}")
  xtitle("{bf: Infant mortality within X km downwind of PMGSY villages}")
  scheme(white_tableau) 
  scale(1.5) ;
#delimit cr  


graph export "${outdir}/figH1_a.pdf", replace 


************************************
**** Figure H.1.b *****
************************************

use "${dtadir}/gjp_main_data_birthsother.dta", clear 
est clear 

forval r = 10(5)75 {
  
  preserve 

  keep if  pmgsy_nfhs_km <`r'
  ivreghdfe child_die_age1  (receivedroad = t) left right    , a( year dist_thresh_id#birthmonth   ) cluster(village_id )  //other controls omitted to speed up computation; estimates remain similar when including baseline controls
  eststo imrup`r'km 

  restore 

}  

gl coeflabelstr

forval r = 10(5)75 {
  gl coeflabelstr ${coeflabelstr} imrup`r'km = "`r'"
}

#delimit ;
coefplot  imrup*km, keep(receivedroad) 
  asequation swapnames vert 
  coeflabels(${coeflabelstr}) 
  legend(off) 
  nooffsets
  yline(0, lcolor(red) lpattern(dash))
  ciopts(recast(rcap) lpattern(dash)  lwidth(medium) lcolor(black))
  xlabel(,nogrid)
  ylabel(-0.02(0.01)0.04, nogrid)
  mcolor(black) msize(medlarge)
  ytitle("{bf: IV estimate & 95% CI}")
  xtitle("{bf: Infant mortality within X km of PMGSY villages}" "{bf:in non-downwind directions}")
  scheme(white_tableau) 
  scale(1.5) ;
#delimit cr  


graph export "${outdir}/figH1_b.pdf", replace 

