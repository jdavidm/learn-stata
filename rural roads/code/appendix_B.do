****.do file to replicate results in Appendix B *****

/************************************/
/* Set-up  */
/************************************/



gl estopts 	b(3) se(3) varwidth(25) label se starlevels(* 0.1 ** 0.05 *** 0.01) nonotes nodepvars
gl estopts2 	b(3) se(3) varwidth(25) label se starlevels(* 0.1 ** 0.05 *** 0.01) nonotes depvars 
gl eststatopts stat(N depvarmean , label("N"  "Control group mean"  ) fmt(%12.0fc %13.2fc)) 
gl eststatopts2  stat(N depvarmean r2 , label("N"   "Control group mean" "$ R^{2} $" ) fmt(%12.0fc %13.2fc))
gl estmgroupopts prefix(\multicolumn{@span}{c}{) suffix(})  span erepeat(\cmidrule(lr){@span})

#delimit ;
gl blcontrols primary_school med_center elect tdist irr_share 
	ln_land pc01_lit_share pc01_sc_share bpl_landed_share bpl_inc_source_sub_share
	bpl_inc_250plus  ;
#delimit cr 


*run programs used in generating plots and tables
do "${dodir}/00_setup.do"


************************************
**** Figure B.1 *****
************************************
*running variable plot data from Asher & Novosad (2020)
use "${dtadir}/pmgsy_runningvar.dta", clear 

global states (rj_l | mp_l | mp_h | cg_l | cg_h | or_l | mh_l | gj_l)
global nobad inrange(secc_pop_ratio, .8, 1.2)
global noroad (app_pr == 0 | con00 == 0)


histogram pc01_pca_tot_p if pc01_pca_tot_p < 1500, start(0) width(25) xline(500 1000, lcolor(gs5)) freq title("Histogram of Village Population") subtitle("2001 Population Census Data") xtitle("Population") ylabel(2000 "2000" 4000 "4000" 6000 "6000" 8000 "8000") lpattern(solid color(white)) graphregion(color(white)) gap(5) color(gs12) lcolor(white)

graph export "$outdir/figB1_a.pdf", replace

/* mccrary test */

/* pooled 500 1000 */

dc_density v_pop if $states & (inrange(pc01_pca_tot_p, 400, 599) | inrange(pc01_pca_tot_p, 900, 1099)) & $noroad & $nobad, breakpoint(0) b(1) generate(Xj Yj r0 fhat se_fhat)  xtitle("Normalized Population") ytitle("Density") graphregion(color(white)) 

graph export "$outdir/figB1_b.pdf", replace


************************************
**** Table B.1 *****
************************************
use "${dtadir}/gjp_main_working.dta", clear 
keep if year==2002 | year == .

la var transport_index_andrsn "Transportation"
la var occupation_index_andrsn "Ag. occupation index"
la var firms_index_andrsn "Firms"
la var agriculture_index_andrsn "Agriculture"
la var consumption_index_andrsn "Consumption"

eststo clear 

foreach family in transport occupation firms agriculture consumption {
  ivregress 2sls `family'_index_andrsn  (r2012  = t) left right  ${blcontrols} i.dist_thresh_id [aw = kernel_tri_ik]  ,  robust
  eststo iv_`family'
  sum `family'_index_andrsn if e(sample) & t == 0
  estadd scalar depvarmean = r(mean)

}



esttab iv_*  using "${outdir}/tableB1.tex" ,  replace ///
		keep(r2012 )  coeflabels( r2012 "Road built") $estopts2  $eststatopts

************************************
**** Table B.2 *****
************************************
use "${dtadir}/gjp_main_working.dta", clear 
keep if year==2002 | year == .

la var transport_index_andrsn "Transportation index"
local pref pc11_vd_
la var `pref'bus_gov "Govt. bus"
la var `pref'bus_priv "Pvt. bus"
la var `pref'taxi "Taxi"
la var `pref'vans "Van"
la var `pref'auto "Autorickshaw"


eststo clear
foreach y in bus_gov bus_priv taxi vans auto {
  qui ivregress 2sls pc11_vd_`y'  (r2012 = t) left right  $blcontrols i.dist_thresh_id [aw = kernel_tri_ik] , robust
  sum pc11_vd_`y' if e(sample) & t == 0
  estadd scalar depvarmean = r(mean)
  eststo iv_trans_`y'
}


esttab iv_trans_*   using "${outdir}/tableB2.tex" , replace ///
		keep(r2012 )  coeflabels( r2012 "Road built") $estopts2  $eststatopts2

************************************
**** Table B.3 *****
************************************
use "${dtadir}/gjp_main_working.dta", clear 
keep if year==2002 | year == .

la var nco2d_cultiv_share "Agriculture"
la var nco2d_manlab_share "Manual labor"
la var secc_inc_cultiv_share "Agriculture"
la var secc_inc_manlab_share "Manual labor"
la var secc_nco04_1d_Y_share "Unemployed" 
la var secc_nco04_1d_Z_share "Unclassifiable"

eststo clear 

foreach var in cultiv manlab {

  ivregress 2sls secc_inc_`var'_share (r2012 = t) left right ${blcontrols} i.dist_thresh_id [aw = kernel_tri_ik]  ,  robust
  eststo `var'rd_inc
  sum secc_inc_`var'_share if e(sample) & t == 0
  estadd scalar depvarmean = r(mean)
  
  ivregress 2sls nco2d_`var'_share (r2012 = t) left right  ${blcontrols} i.dist_thresh_id [aw = kernel_tri_ik]   , robust
  eststo `var'rd_occ
  sum nco2d_`var'_share if e(sample) & t == 0
  estadd scalar depvarmean = r(mean)
}

ivregress 2sls secc_nco04_1d_Y_share  (r2012 = t) left right  ${blcontrols} i.dist_thresh_id [aw = kernel_tri_ik]   , robust
eststo unemp
sum secc_nco04_1d_Y_share  if e(sample) & t == 0
estadd scalar depvarmean = r(mean)

ivregress 2sls secc_nco04_1d_Z_share  (r2012 = t) left right  ${blcontrols} i.dist_thresh_id [aw = kernel_tri_ik]   , robust
eststo unclass
sum secc_nco04_1d_Z_share if e(sample) & t == 0
estadd scalar depvarmean = r(mean)


esttab  *rd_occ  unemp unclass *rd_inc using "${outdir}/tableB3.tex" ,  replace ///
		keep(r2012 )  coeflabels( r2012 "Road built") ///
		mgroups("Occupation" "Income source",  pattern(1 0 0 0 1 0) $estmgroupopts) ///
		$estopts2  $eststatopts2


************************************
**** Table B.4 *****
************************************
use "${dtadir}/gjp_main_working.dta", clear 
keep if year==2002 | year == .

eststo clear 

global nobad_firms inrange(ec13_emp_share, 0, 1)

foreach y in all act2 act6 act20 act12 act3    {

  ivregress 2sls ec13_emp_`y'_ln  (r2012 = t) left right  ${blcontrols} i.dist_thresh_id [aw = kernel_tri_ik] if $nobad_firms, robust
  eststo `y'_ln
  sum ec13_emp_`y'_ln if e(sample) & t == 0
  estadd scalar outcome_mean = r(mean)

  ivregress 2sls ec13_emp_`y'  (r2012 = t) left right  ${blcontrols} i.dist_thresh_id [aw = kernel_tri_ik] if  $nobad_firms, robust
  eststo `y'_lvl
  sum ec13_emp_`y' if e(sample) & t == 0
  estadd scalar outcome_mean = r(mean)


}
* Top panel
#delimit ;
esttab all_ln  act2_ln  act6_ln act20_ln act12_ln  act3_ln using "${outdir}/tableB4.tex", 
prehead("\begin{tabular}{l*{6}{c}} \hline") 
posthead("\hline \\ \multicolumn{7}{c}{\textit{Panel A: Log employment growth}} \\\\ [-1ex] \hline 
	 &\multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} &\multicolumn{1}{c}{(3)}
         &\multicolumn{1}{c}{(4)} &\multicolumn{1}{c}{(5)} &\multicolumn{1}{c}{(6)} \\
         &\multicolumn{1}{c}{Total} & \multicolumn{1}{c}{Livestock} &\multicolumn{1}{c}{Manufacturing}
         &\multicolumn{1}{c}{Education} &\multicolumn{1}{c}{Retail} &\multicolumn{1}{c}{Forestry} \\ \hline")       
nonumbers  nonotes nomtitles nodepvars fragment replace 
keep(r2012 ) 	b(3) se(3) varwidth(25) label  
stat(N outcome_mean r2 , label("N"   "Control group mean" "$ R^{2} $" ) fmt(%12.0fc %13.2fc)) 
se starlevels(* 0.1 ** 0.05 *** 0.01) coeflabels( r2012 "Road built")  ;

#delimit cr 
* Bottom panel
#delimit ;
esttab all_lvl act2_lvl act6_lvl  act20_lvl act12_lvl  act3_lvl using  "${outdir}/tableB4.tex", 
posthead("\hline \\ \multicolumn{7}{c}{\textit{Panel B: Level employment growth}} \\\\ [-1ex] \hline 
		 &\multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} &\multicolumn{1}{c}{(3)}
         &\multicolumn{1}{c}{(4)} &\multicolumn{1}{c}{(5)} &\multicolumn{1}{c}{(6)} \\
         &\multicolumn{1}{c}{Total} & \multicolumn{1}{c}{Livestock} &\multicolumn{1}{c}{Manufacturing}
         &\multicolumn{1}{c}{Education} &\multicolumn{1}{c}{Retail} &\multicolumn{1}{c}{Forestry} \\ \hline")
fragment append nonotes nonumbers nomtitles nodepvars 
keep(r2012 ) 	b(3) se(3) varwidth(25) label 
stat(N outcome_mean r2 , label("N"   "Control group mean" "$ R^{2} $" ) fmt(%12.0fc %13.2fc)) 
se starlevels(* 0.1 ** 0.05 *** 0.01) coeflabels( r2012 "Road built") 
prefoot("\hline") 
postfoot("\hline\hline \end{tabular}")  ;
#delimit cr 

************************************
**** Table B.5 *****
************************************
use "${dtadir}/gjp_main_working.dta", clear 
keep if year==2002 | year == .

est clear 

foreach y in delta cumul max {
  foreach j in ndvi evi {
    ivregress 2sls `j'_`y'_2011_2013_ln (r2012 = t) `j'_`y'_2000_2002_ln left right $controls i.dist_thresh_id [aw = kernel_tri_ik]  , robust
 	eststo iv_`j'_`y'
 	sum `j'_`y'_2011_2013_ln if e(sample) & t == 0
    estadd scalar depvarmean = r(mean)
	estadd scalar depvarsd = r(sd)
  }
}



esttab iv_ndvi_delta iv_ndvi_cumul iv_ndvi_max iv_evi_delta iv_evi_cumul iv_evi_max ///
	    using "${outdir}/tableB5.tex" , replace ///
		keep(r2012 )  coeflabels( r2012 "Road built") $estopts2  $eststatopts2  ///
		mgroups("NDVI" "EVI",  pattern(1 0 0 1 0 0)  $estmgroupopts)         ///
		mtitles("Max - June" "Cumulative" "Max" "Max - June" "Cumulative" "Max")  

************************************
**** Table B.6 *****
************************************
use "${dtadir}/gjp_main_working.dta", clear 
keep if year==2002 | year == .

est clear 


la var secc_mech_farm "Mech."
la var secc_irr_equip "Irri."
la var secc_land_own "Own ag. land"
la var pc11_ag_acre_ln "Cult. land (log)"
la var any_noncerpul "Non-cereal/pulse"

foreach y in mech_farm irr_equip land_own  {
  
  ivregress 2sls secc_`y'_share (r2012 = t) left right $controls i.dist_thresh_id [aw = kernel_tri_ik] , robust
  eststo `y'
  sum secc_`y'_share if e(sample) & t == 0
  estadd scalar depvarmean = r(mean)

}

ivregress 2sls pc11_ag_acre_ln (r2012 = t) left right $controls i.dist_thresh_id [aw = kernel_tri_ik] if  pc11_ag_acre_ln > 0, robust
eststo landcult 
sum pc11_ag_acre_ln if e(sample) & t == 0
estadd scalar depvarmean = r(mean)

ivregress 2sls any_noncerpul (r2012 = t) left right $controls i.dist_thresh_id [aw = kernel_tri_ik] if  pc11_ag_acre_ln > 0, robust
eststo any_noncerpul 
sum any_noncerpul if e(sample) & t == 0
estadd scalar depvarmean = r(mean)



esttab mech_farm irr_equip land_own any_noncerpul landcult ///
	    using "${outdir}/tableB6.tex" , replace ///
		keep(r2012 )  coeflabels( r2012 "Road built") $estopts2  $eststatopts2 

************************************
**** Table B.7 *****
************************************
use "${dtadir}/gjp_main_working.dta", clear 
keep if year==2002 | year == .

est clear 

ivregress 2sls cons_pc_win_ln   (r2012 = t) left right  ${blcontrols} i.dist_thresh_id [aw = kernel_tri_ik] , robust

sum cons_pc_win_ln  if e(sample) & t == 0
estadd scalar outcome_mean = r(mean)
eststo ivAcons_pc_win_ln 

ivregress 2sls ln_light2011_2013   (r2012 = t) left right ln_light2001 ${blcontrols} i.dist_thresh_id [aw = kernel_tri_ik] , robust

sum ln_light2011_2013  if e(sample) & t == 0
estadd scalar outcome_mean = r(mean)
eststo ivAln_light2011_2013 


foreach y in  secc_inc_5k_plus_share  secc_asset_index_norm  {

  ivregress 2sls `y'  (r2012 = t) left right  ${blcontrols} i.dist_thresh_id [aw = kernel_tri_ik] , robust

  sum `y' if e(sample) & t == 0
  estadd scalar outcome_mean = r(mean)
  eststo ivA`y'

}

foreach y in  solid_house refrig veh_any phone  {
	ivregress 2sls secc_`y'_share  (r2012 = t) left right  ${blcontrols} i.dist_thresh_id [aw = kernel_tri_ik] , robust

  sum secc_`y'_share if e(sample) & t == 0
  estadd scalar outcome_mean = r(mean)
  eststo ivB`y'
}



* Top panel
#delimit ;
esttab ivA* using "${outdir}/tableB7.tex", 
prehead("\begin{tabular}{l*{4}{c}} \hline") 
posthead("\hline \\ \multicolumn{5}{c}{\textit{Panel A: Consumption indicators and asset index}} \\\\ [-1ex] \hline 
			 &\multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} &\multicolumn{1}{c}{(3)}
         &\multicolumn{1}{c}{(4)}  \\
 &\multicolumn{1}{c}{Consumption per} & \multicolumn{1}{c}{Night lights (log)} &\multicolumn{1}{c}{Share of HH} &\multicolumn{1}{c}{Asset index} \\
 &\multicolumn{1}{c}{capita (log)} &\multicolumn{1}{c}{} &\multicolumn{1}{c}{earning $\geq5k$} &\multicolumn{1}{c}{} \\ \hline")       
nonumbers  nonotes nomtitles nodepvars fragment replace 
keep(r2012 ) 	b(3) se(3) varwidth(25) label  
stat(N outcome_mean r2 , label("N"   "Control group mean" "$ R^{2} $" ) fmt(%12.0fc %13.2fc)) 
se starlevels(* 0.1 ** 0.05 *** 0.01) coeflabels( r2012 "Road built")  ;

#delimit cr 
* Bottom panel
#delimit ;
esttab ivB* using "${outdir}/tableB7.tex", 
posthead("\hline \\ \multicolumn{5}{c}{\textit{Panel B: Individual asset ownership}} \\\\ [-1ex] \hline 
         			 &\multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} &\multicolumn{1}{c}{(3)}
         &\multicolumn{1}{c}{(4)}  \\
         &\multicolumn{1}{c}{Solid house} &\multicolumn{1}{c}{Refrigrator}
         &\multicolumn{1}{c}{Any vehicle} &\multicolumn{1}{c}{Phone} \\ \hline")
fragment append nonotes nonumbers nomtitles nodepvars 
keep(r2012 ) 	b(3) se(3) varwidth(25) label 
stat(N outcome_mean r2 , label("N"   "Control group mean" "$ R^{2} $" ) fmt(%12.0fc %13.2fc)) 
se starlevels(* 0.1 ** 0.05 *** 0.01) coeflabels( r2012 "Road built") 
prefoot("\hline") 
postfoot("\hline\hline \end{tabular}")  ;
#delimit cr 

************************************
**** Table B.8 *****
************************************
use "${dtadir}/gjp_main_working.dta", clear 
keep if year==2002 | year == .

est clear 

ivregress 2sls pc11_pca_tot_p (r2011 = t) left right  ${blcontrols} i.dist_thresh_id [aw = kernel_tri_ik] , robust
eststo poplvl
sum pc11_pca_tot_p if e(sample) & t == 0
estadd scalar outcome_mean = r(mean)

ivregress 2sls pc11_pop_ln   (r2011 = t) left right ${blcontrols} i.dist_thresh_id [aw = kernel_tri_ik] , robust
eststo poplog
sum pc11_pop_ln if e(sample) & t == 0
estadd scalar outcome_mean = r(mean)

/* age group shares and male shares */
foreach agegroup in 11_20 21_30 31_40 41_50 51_60 {
  ivregress 2sls secc_age_share_`agegroup'  (r2012 = t) left right ${blcontrols} i.dist_thresh_id [aw = kernel_tri_ik] , robust

eststo iv`agegroup'
sum secc_age_share_`agegroup' if e(sample) & t == 0
estadd scalar outcome_mean = r(mean)

}


foreach agegroup in 11_20 21_30 31_40 41_50 51_60 {
  ivregress 2sls secc_male_share_`agegroup'  (r2012 = t) left right ${blcontrols} i.dist_thresh_id [aw = kernel_tri_ik] , robust

eststo ivmale`agegroup'
sum secc_male_share_`agegroup' if e(sample) & t == 0
estadd scalar outcome_mean = r(mean)

}


* Top panel
#delimit ;
esttab poplog poplvl using "${outdir}/tableB8.tex", 
prehead("\begin{tabular}{l*{2}{c}} \hline") 
posthead("\hline \\ \multicolumn{3}{c}{\textit{Panel A: Population growth (2001 - 2011)}} \\\\ [-1ex] \hline 
			 &\multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} \\
			 &\multicolumn{1}{c}{Log} &\multicolumn{1}{c}{Level} \\ \hline")       
nonumbers  nonotes nomtitles nodepvars fragment replace 
keep(r2011 ) coeflabels(r2011 "Road built")	b(3) se(3) varwidth(25) label  
stat(N outcome_mean r2 , label("N"   "Control group mean" "$ R^{2} $" ) fmt(%12.0fc %13.2fc)) 
se starlevels(* 0.1 ** 0.05 *** 0.01)  
prefoot("\hline") 
postfoot("\end{tabular}")  ;

#delimit cr 

* Panel B
#delimit ;
esttab iv11_20 iv21_30 iv31_40 iv41_50 iv51_60 using "${outdir}/tableB8.tex", 
prehead("\begin{tabular}{l*{6}{c}}") 
posthead("\\ \multicolumn{6}{c}{\textit{Panel B: Age group share}} \\\\ [-1ex] \hline 
          &\multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} &\multicolumn{1}{c}{(3)}
         &\multicolumn{1}{c}{(4)} &\multicolumn{1}{c}{(5)}  \\
         &\multicolumn{1}{c}{11 - 20} &\multicolumn{1}{c}{21 - 30}
         &\multicolumn{1}{c}{31 - 40} &\multicolumn{1}{c}{41 - 50}  &\multicolumn{1}{c}{51 - 60}  \\ \hline")
fragment append nonotes nonumbers nomtitles nodepvars 
keep(r2012 ) 	b(3) se(3) varwidth(25) label 
stat(N outcome_mean r2 , label("N"   "Control group mean" "$ R^{2} $" ) fmt(%12.0fc %13.2fc)) 
se starlevels(* 0.1 ** 0.05 *** 0.01) coeflabels( r2012 "Road built")  ;
#delimit cr 

* Panel C
#delimit ;
esttab ivmale11_20 ivmale21_30 ivmale31_40 ivmale41_50 ivmale51_60 using "${outdir}/tableB8.tex", 
posthead("\hline \\ \multicolumn{6}{c}{\textit{Panel C: Male share by age group}} \\\\ [-1ex] \hline 
          &\multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)} &\multicolumn{1}{c}{(3)}
         &\multicolumn{1}{c}{(4)} &\multicolumn{1}{c}{(5)}  \\
         &\multicolumn{1}{c}{11 - 20} &\multicolumn{1}{c}{21 - 30}
         &\multicolumn{1}{c}{31 - 40} &\multicolumn{1}{c}{41 - 50}  &\multicolumn{1}{c}{51 - 60}  \\ \hline")
fragment append nonotes nonumbers nomtitles nodepvars 
keep(r2012 ) 	b(3) se(3) varwidth(25) label 
stat(N outcome_mean r2 , label("N"   "Control group mean" "$ R^{2} $" ) fmt(%12.0fc %13.2fc)) 
se starlevels(* 0.1 ** 0.05 *** 0.01) coeflabels( r2012 "Road built") 
prefoot("\hline") 
postfoot("\hline\hline \end{tabular}")  ;
#delimit cr 

