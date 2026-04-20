*** .do file to replicate:
*** Figure 2 and Tables 2,3


/************************************/
/* Set-up  */
/************************************/

*run programs used in generating plots and tables
do "${dodir}/00_setup.do"

* est table settings*
gl estopts 	b(2) se(2) varwidth(25) label se starlevels(* 0.1 ** 0.05 *** 0.01) nonotes nodepvars
gl eststatopts stat(N depvarmean , label("N"  "Control group mean"  ) fmt(%12.0fc %13.1fc)) 
gl estmgroupopts prefix(\multicolumn{@span}{c}{) suffix(})  span erepeat(\cmidrule(lr){@span})


*set baseline control variables
#delimit ;
gl blcontrols primary_school med_center elect tdist irr_share 
	ln_land pc01_lit_share pc01_sc_share bpl_landed_share bpl_inc_source_sub_share
	bpl_inc_250plus  ;
#delimit cr 


/************************************/
/*  Fig. 2  */
/************************************/

/* [> Fig 2a. Resiudalized RD Plot - first stage <] */ 
use "${dtadir}/gjp_main_working.dta", clear 
cap drop y_resid
reghdfe receivedroad ${blcontrols}  , a(dist_thresh_id year) resid(y_resid)

rd y_resid v_pop ,  xtitle("{bf: Population minus threshold}")  /// 
ytitle("{bf: Received road}" ) msize(small)    ///
ylabel(,format(%2.1f)  nogrid)  xlabel(, nogrid) ///
bin(20) degree(1) start(-80) end(80) bw scheme(white_tableau)

graph export "${outdir}/fig2a.pdf",  replace


/* [> Fig 2b. Resiudalized RD Plot - annual fire count <] */ 
use "${dtadir}/gjp_main_working.dta", clear 
cap drop y_resid 
reghdfe fires10km ${blcontrols} fires2001_10km , a(dist_thresh_id year) resid(y_resid) 

rd y_resid v_pop ,  xtitle("{bf: Population minus threshold}")  /// 
ytitle("{bf: Annual fire counts}") msize(small)    ///
ylabel(-0.4(.2).4,format(%2.1f) nogrid) xlabel(,nogrid)  ///
bin(20) degree(1) start(-80) end(80) bw scheme(white_tableau)

graph export "${outdir}/fig2b.pdf",  replace


/* [> Fig 2c. Resiudalized RD Plot - annual average PM2.5 <] */ 
use "${dtadir}/gjp_main_working.dta", clear 
cap drop y_resid 
reghdfe pm25 ${blcontrols} pm25_bl2001, a(dist_thresh_id year) resid(y_resid)

rd y_resid v_pop ,  xtitle("{bf: Population minus threshold}") ytitle("{bf: Annual PM 2.5}") ///
msize(small)  ylabel(-0.2(.1).2, format(%2.1f) nogrid ) xlabel(,nogrid)  ///
bin(20) degree(1) start(-80) end(80) bw scheme(white_tableau)

graph export "${outdir}/fig2c.pdf",  replace




/************************************/
/*  Table 2  */
/************************************/
use "${dtadir}/gjp_main_working.dta", clear 

est clear 

/*  1st stage  */

reghdfe receivedroad t left right ${blcontrols} [aw = kernel_tri_ik] , a(year dist_thresh_id) vce(cluster village_id)

eststo fs
su r if e(sample) & t == 0
estadd scalar depvarmean = r(mean)

/*  Reduced form estimates  */

reghdfe fires10km t left right fires2001_10km ${blcontrols} [aw = kernel_tri_ik] ,  a(year dist_thresh_id) cluster(village_id)
eststo rffires
su fires10km if e(sample) & t == 0
estadd scalar depvarmean = r(mean)

reghdfe pm25  t left right pm25_bl2001 ${blcontrols} [aw = kernel_tri_ik] ,  a(year dist_thresh_id) cluster(village_id)
eststo rfpm
su pm25 if e(sample) & t == 0
estadd scalar depvarmean = r(mean)

/*  RD-IV - fires and PM  */

ivreghdfe fires10km (receivedroad = t) left right fires2001_10km ${blcontrols}  [aw = kernel_tri_ik] ,  a(year dist_thresh_id) cluster(village_id)
eststo ivfires
su fires10km if e(sample) & t == 0
estadd scalar depvarmean = r(mean)


ivreghdfe pm25 (receivedroad = t) left right pm25_bl2001 ${blcontrols}  [aw = kernel_tri_ik] ,  a(year dist_thresh_id) cluster(village_id)
eststo ivpm
su pm25 if e(sample) & t == 0
estadd scalar depvarmean = r(mean)


/* table 2 */

esttab fs rffires ivfires rfpm ivpm  using "${outdir}/table2.tex" , replace keep(t receivedroad  ) coeflabels(t "Above threshold pop." receivedroad "Road built") mgroups("New road" "Annual fire activity"  "Annual average PM 2.5",  pattern(1 1 0 1 0 ) $estmgroupopts  )    mtitles("1^{st} stage"  "RF" "IV"  "RF" "IV") $estopts  $eststatopts





/************************************/
/*  Table 3  */
/************************************/
use "${dtadir}/gjp_main_working.dta", clear 

est clear 

/* [> fires by season; emissions by season and source <] */ 

foreach var of varlist firesharvestmonths firesnonharvest harvestmonths_BCEMAN nonharvest_BCEMAN harvestmonths_BCEMBB nonharvest_BCEMBB BCharvestmonths_all BCnonharvest_all harvestmonths_OCEMAN nonharvest_OCEMAN harvestmonths_OCEMBB nonharvest_OCEMBB OCharvestmonths_all OCnonharvest_all {

  ivregress 2sls `var' (receivedroad = t) left right ${blcontrols}  `var'_bl  i.year i.dist_thresh_id [aw = kernel_tri_ik] ,   vce(cluster village_id)

  eststo iv`var'
  sum `var' if e(sample) & t == 0
  estadd scalar depvarmean = r(mean)
}



/* [> table 3 <] */ 

file open   t     using "$outdir/table3.tex", replace write
file write t  "\begin{table}[htbp] \centering" _n "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n ///
            "\begin{tabular*}{1\textwidth}{@{\extracolsep{\fill}}l*{7}{c}}" _n "\hline\hline" _n ///
              "\multicolumn{8}{c}{Panel A: Winter harvest and post-harvest months}\\" _n ///
              "\midrule" _n 
file close  t

esttab ivfiresharvestmonths ivBCharvestmonths_all ivOCharvestmonths_all ivharvestmonths_BCEMBB ///
      ivharvestmonths_OCEMBB ivharvestmonths_BCEMAN ivharvestmonths_OCEMAN ///
       using "$outdir/table3.tex", ///
       b(3) se(3) varwidth(25) label se ///
       starlevels(* 0.1 ** 0.05 *** 0.01) ///
       nonotes nodepvars ///
        keep(receivedroad ) ///
        coeflabels(receivedroad "Road built") ///
        mgroups("Fires" "All sources"  "Biomass burning" "Other sources",  pattern(1 1 0 1 0 1 0 ) ///
          prefix(\multicolumn{@span}{c}{) suffix(})  span erepeat(\cmidrule(lr){@span})  ) ///
          mtitles(" " "BC" "OC" "BC" "OC" "BC" "OC") ///
        stat(N depvarmean , label("N"  "Control group mean"  ) fmt(%12.0fc %13.2fc)) ///
        append fragment 

file open   t   using "$outdir/table3.tex", append write
file write t "\midrule" _n ///
            "\multicolumn{8}{c}{Panel B: Rest of the year}\\" _n ///
            "\midrule" _n 
file close  t

esttab ivfiresnonharvest ivBCnonharvest_all ivOCnonharvest_all ivnonharvest_BCEMBB ///
      ivnonharvest_OCEMBB ivnonharvest_BCEMAN ivnonharvest_OCEMAN ///
       using "$outdir/table3.tex", ///
       b(3) se(3) varwidth(25) label se ///
       starlevels(* 0.1 ** 0.05 *** 0.01) ///
       nonotes nodepvars ///
        keep(receivedroad ) ///
        coeflabels(receivedroad "Road built") ///
        mgroups("Fires" "All sources"  "Biomass burning" "Other sources",  pattern(1 1 0 1 0 1 0 ) ///
          prefix(\multicolumn{@span}{c}{) suffix(})  span erepeat(\cmidrule(lr){@span})  ) ///
          mtitles(" " "BC" "OC" "BC" "OC" "BC" "OC") ///
        stat(N depvarmean , label("N"  "Control group mean"  ) fmt(%12.0fc %13.2fc)) ///
        append fragment 

file open   t   using "$outdir/table3.tex", append write

file write t   "\midrule" _n "\end{tabular*}" _n ///
               "\end{table}" _n 
file close  t 


******** END *********









