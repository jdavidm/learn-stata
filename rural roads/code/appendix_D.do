****.do file to replicate results in Appendix D *****

/************************************/
/* Set-up  */
/************************************/



************************************
**** Figure D.1. *****
************************************
use "${dtadir}/appD_harvestdates.dta", clear 

gen omittedtm_1 = 0     
la var omittedtm_1 "-1"

reghdfe bldevmonsoonharvest tm4_minus_comp tm3_comp  tm2_comp omittedtm_1  t0_comp t1_comp t2_comp t3_comp t4_plus_comp ///
 				if has_comp_4 , absorb(svgroup sdygroup  i.year#c.pc01_pca_tot_p   i.year#c.monsoonharvest2002 ///
					i.year#c.(distance50 total_forest_2000 pc01_st_share) ) cluster(sdgroup)

coefplot, omitted keep(tm4_minus_comp tm3_comp tm2_comp omittedtm_1 t0_comp t1_comp t2_comp t3_comp t4_plus_comp) ///
			yline(0) vert label xtitle("Years after Road Completion" ) ytitle("Change in harvest date relative to baseline" "(day of year)") ///
			graphregion(color(white)) name(harvest, replace) mcolor(black) ylabel(,nogrid) 

graph export "${outdir}/figD1.pdf", replace

************************************
**** Figure D.2. *****
************************************
use "${dtadir}/appD_sowdates.dta", clear 


gen omittedtm_1 = 0     
la var omittedtm_1 "-1"

reghdfe bldevmonsoonsow tm4_minus_comp tm3_comp  tm2_comp omittedtm_1  t0_comp t1_comp t2_comp t3_comp t4_plus_comp ///
 				if has_comp_4 , absorb(svgroup sdygroup  i.year#c.pc01_pca_tot_p   i.year#c.monsoonsow2002 ///
					i.year#c.(distance50 total_forest_2000 pc01_st_share) ) cluster(sdgroup)

coefplot, omitted keep(tm4_minus_comp tm3_comp tm2_comp omittedtm_1 t0_comp t1_comp t2_comp t3_comp t4_plus_comp) ///
			yline(0) vert label xtitle("Years after Road Completion" ) ytitle("Change in sowing date relative to baseline" "(day of year)") ///
			graphregion(color(white)) name(sowing, replace) mcolor(black) ylabel(,nogrid) 

graph export "${outdir}/figD2.pdf", replace