*** .do file to replicate:
***  Table 1
** note: python 2.7 or higher needed for using state-tex.do for table generation in the required format

/************************************/
/* Set-up   */
/************************************/

gl PYTHONPATH "$dodir/stata-tex"
gl table_templates "$dodir/stata-tex/balance_table_tpl"

do "$dodir/stata-tex/stata-tex.do"

#delimit ;
gl blcontrols primary_school med_center elect tdist irr_share 
  ln_land pc01_lit_share pc01_sc_share bpl_landed_share bpl_inc_source_sub_share
  bpl_inc_250plus  ;
#delimit cr 


/* wipe out existing results file and create new one */
cap rm "$tmp/balancedata.csv"

global controls   primary_school med_center elect tdist irr_share ln_land pc01_lit_share pc01_sc_share bpl_landed_share bpl_inc_source_sub_share bpl_inc_250plus fires2001_10km pm25_2001 


/************************************/
/* Table 1   */
/************************************/


use "${dtadir}/gjp_main_working.dta", clear 
keep if year == 2012 | year == .
rename pm25_bl2001 pm25_2001



/* loop over balance variables */
foreach i in $controls {

  /* mean full sample */
  sum `i'  
  local btmean `r(mean)'
  store_val_tpl using "$tmp/balancedata.csv", name("`i'_mean") value(`r(mean)') format("%5.3f")
  store_val_tpl using "$tmp/balancedata.csv", name("N_mean") value(`r(N)') format("%10.0f")
  
  /* mean below threshold */
  sum `i' if  t == 0
  local btmean `r(mean)'
  store_val_tpl using "$tmp/balancedata.csv", name("`i'_bt") value(`r(mean)') format("%5.3f")
  store_val_tpl using "$tmp/balancedata.csv", name("N_bt") value(`r(N)') format("%10.0f")
  
  /* mean over threshold */
  sum `i' if  t == 1
  local otmean `r(mean)'
  store_val_tpl using "$tmp/balancedata.csv", name("`i'_ot") value(`r(mean)') format("%5.3f")
  store_val_tpl using "$tmp/balancedata.csv", name("N_ot") value(`r(N)') format("%10.0f")

  /* difference */
  local diff = `otmean' - `btmean'
  store_val_tpl using "$tmp/balancedata.csv", name("`i'_dm") value(`diff') format("%5.2f")

  /* test equality of means */
  ttest `i', by(t)
  store_val_tpl using "$tmp/balancedata.csv", name("`i'_pv") value(`r(p)') format("%5.2f")
  
  /* rd estimate */
  ivregress 2sls `i' (r2012=t) left right  i.dist_thresh_id [aw= kernel_tri_ik] , r
  
  store_est_tpl using "$tmp/balancedata.csv", name("`i'") coef(r2012) format("%5.3f") beta p
  
}
  

use if pmgsy_nfhs_km <= 50 & year == 2001 using "${dtadir}/gjp_main_data_birthsdown.dta", clear 
rename child_die_age1 imr2001

foreach i in imr2001 {
  
  /* mean full sample */
  sum `i'
  local btmean `r(mean)'
  store_val_tpl using "$tmp/balancedata.csv", name("`i'_mean") value(`r(mean)') format("%5.3f")
  store_val_tpl using "$tmp/balancedata.csv", name("N_mean") value(`r(N)') format("%10.0f")
  
  /* mean below threshold */
  sum `i' if  t == 0
  local btmean `r(mean)'
  store_val_tpl using "$tmp/balancedata.csv", name("`i'_bt") value(`r(mean)') format("%5.3f")
  store_val_tpl using "$tmp/balancedata.csv", name("N_bt") value(`r(N)') format("%10.0f")
  
  /* mean over threshold */
  sum `i' if  t == 1
  local otmean `r(mean)'
  store_val_tpl using "$tmp/balancedata.csv", name("`i'_ot") value(`r(mean)') format("%5.3f")
  store_val_tpl using "$tmp/balancedata.csv", name("N_ot") value(`r(N)') format("%10.0f")

  /* difference */
  local diff = `otmean' - `btmean'
  store_val_tpl using "$tmp/balancedata.csv", name("`i'_dm") value(`diff') format("%5.2f")

  /* test equality of means */
  ttest `i' , by(t)
  store_val_tpl using "$tmp/balancedata.csv", name("`i'_pv") value(`r(p)') format("%5.2f")
  
  /* rd estimate */
 ivreghdfe `i'  (r2012 = t) left right  ,  a( dist_thresh_id) cluster(village_id)  
  store_est_tpl using "$tmp/balancedata.csv", name("`i'") coef(r2012) format("%5.3f") beta p
  
}

use if pmgsy_nfhs_km <= 50 & year == 2001 using "${dtadir}/gjp_main_data_birthsother.dta", clear 
rename child_die_age1 oimr2001


foreach i in oimr2001 {
  
  /* mean full sample */
  sum `i' 
  local btmean `r(mean)'
  store_val_tpl using "$tmp/balancedata.csv", name("`i'_mean") value(`r(mean)') format("%5.3f")
  store_val_tpl using "$tmp/balancedata.csv", name("N_mean") value(`r(N)') format("%10.0f")
  
  /* mean below threshold */
  sum `i' if  t == 0
  local btmean `r(mean)'
  store_val_tpl using "$tmp/balancedata.csv", name("`i'_bt") value(`r(mean)') format("%5.3f")
  store_val_tpl using "$tmp/balancedata.csv", name("N_bt") value(`r(N)') format("%10.0f")
  
  /* mean over threshold */
  sum `i' if  t == 1
  local otmean `r(mean)'
  store_val_tpl using "$tmp/balancedata.csv", name("`i'_ot") value(`r(mean)') format("%5.3f")
  store_val_tpl using "$tmp/balancedata.csv", name("N_ot") value(`r(N)') format("%10.0f")

  /* difference */
  local diff = `otmean' - `btmean'
  store_val_tpl using "$tmp/balancedata.csv", name("`i'_dm") value(`diff') format("%5.2f")

  /* test equality of means */
  ttest `i' , by(t)
  store_val_tpl using "$tmp/balancedata.csv", name("`i'_pv") value(`r(p)') format("%5.2f")
  
  /* rd estimate */
 ivreghdfe `i'  (r2012 = t) left right   ,  a( dist_thresh_id) cluster(village_id)  
  store_est_tpl using "$tmp/balancedata.csv", name("`i'") coef(r2012) format("%5.3f") beta p
  
}

use "${dtadir}/gjp_main_data_dhspm50km.dta", clear 

rename downwind_dhs_pm25_bl2001 dhs_pm25_2001
rename nondown_dhs_pm25_bl2001 odhs_pm25_2001
keep if year == 2001

foreach i in dhs_pm25_2001 odhs_pm25_2001 {
  
  /* mean full sample */
  sum `i' 
  local btmean `r(mean)'
  store_val_tpl using "$tmp/balancedata.csv", name("`i'_mean") value(`r(mean)') format("%5.3f")
  store_val_tpl using "$tmp/balancedata.csv", name("N_mean") value(`r(N)') format("%10.0f")
  
  /* mean below threshold */
  sum `i' if  t == 0
  local btmean `r(mean)'
  store_val_tpl using "$tmp/balancedata.csv", name("`i'_bt") value(`r(mean)') format("%5.3f")
  store_val_tpl using "$tmp/balancedata.csv", name("N_bt") value(`r(N)') format("%10.0f")
  
  /* mean over threshold */
  sum `i' if  t == 1
  local otmean `r(mean)'
  store_val_tpl using "$tmp/balancedata.csv", name("`i'_ot") value(`r(mean)') format("%5.3f")
  store_val_tpl using "$tmp/balancedata.csv", name("N_ot") value(`r(N)') format("%10.0f")

  /* difference */
  local diff = `otmean' - `btmean'
  store_val_tpl using "$tmp/balancedata.csv", name("`i'_dm") value(`diff') format("%5.2f")

  /* test equality of means */
  ttest `i' , by(t)
  store_val_tpl using "$tmp/balancedata.csv", name("`i'_pv") value(`r(p)') format("%5.2f")
  
  /* rd estimate */
 ivreghdfe `i'  (r2012 = t) left right ${blcontrols}   ,  a( dist_thresh_id) cluster(village_id)  
  store_est_tpl using "$tmp/balancedata.csv", name("`i'") coef(r2012) format("%5.3f") beta p
  
}

/* make tables */
table_from_tpl, t("$table_templates/balance_tpl.tex") r("$tmp/balancedata.csv") o("$outdir/table1.tex") dropstars


******** END *********

