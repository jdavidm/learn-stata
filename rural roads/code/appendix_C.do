****.do file to replicate results in Appendix C *****

/************************************/
/* Set-up  */
/************************************/




gl estopts 	b(3) se(3) varwidth(25) label se starlevels(* 0.1 ** 0.05 *** 0.01) nonotes nodepvars
gl estopts2 	b(3) se(3) varwidth(25) label se starlevels(* 0.1 ** 0.05 *** 0.01) nonotes depvars 
gl eststatopts stat(N depvarmean , label("N"  "Control group mean"  ) fmt(%12.0fc %13.2fc)) 
gl eststatopts2  stat(N depvarmean r2 , label("N"   "Control group mean" "$ R^{2} $" ) fmt(%12.0fc %13.2fc))
gl estmgroupopts prefix(\multicolumn{@span}{c}{) suffix(})  span erepeat(\cmidrule(lr){@span})



************************************
**** Table C.1. *****
************************************
use "${dtadir}/appC_data_01.dta", clear 

est clear

foreach v in male_ag female_ag mf_ag {

	eststo ols_`v': reghdfe `v'_cpi06 c.r2006#c.year ,   a(year villageid  ) vce(cluster villageid)
	su `v'_cpi06 if e(sample)
	estadd scalar depvarmean = r(mean)


	eststo ln_`v': reghdfe ln_`v'_cpi06 c.r2006#c.year ,   a(year villageid  ) vce(cluster villageid)
	su `v'_cpi06 if e(sample)
	estadd scalar depvarmean = r(mean)

}


 esttab  ols_* ln_*  using "${outdir}/tableC1.tex" , replace ///
    keep(c.r2006#c.year )  coeflabel(c.r2006#c.year "Treat X Post")  ///
    mgroups("Wage rate"  "Log wage",  pattern(1 0 0 1 0 0) $estmgroupopts )         ///  
     mtitles("Male" "Female" "Average" "Male" "Female" "Average"   ) $estopts  $eststatopts2

************************************
**** Table C.2 *****
************************************
use "${dtadir}/appC_data_01.dta", clear 

est clear

local machines combines threshers tractors powertillers

foreach m of local machines {
	
	** extensive margin - present Y/N ***
	reghdfe `m'_YN c.r2006#c.year, vce(cluster villageid)  a(year villageid  ) 
	eststo YN`m'reg
	estadd ysumm, mean 


	reghdfe ln_`m' c.r2006#c.year, vce(cluster villageid)  a(year villageid ) 
	eststo ln`m'reg
	estadd ysumm, mean 
}	

#delimit ;
esttab YN* using "${outdir}/tableC2.tex", 
prehead("\begin{tabular}{l*{4}{c}} \hline") 
posthead("\hline \\ \multicolumn{5}{c}{\textit{Panel A: Present (Yes = 1)}} \\\\ [-1ex] \hline 
         &\multicolumn{1}{c}{Combines} & \multicolumn{1}{c}{Threshers} &\multicolumn{1}{c}{Tractors}
         &\multicolumn{1}{c}{Power tillers} \\ \hline")       
drop(_cons)  b(3) se(3)
coeflabel(c.r2006#c.year "Treat X Post") 
stats(ymean N r2  , fmt(%9.2f %9.0g %9.2f  ) 
labels("Sample mean" "\$N$" "\$R^2$" )) label  se r2 star( * .1 ** .05 *** .01)    
nonumbers  nonotes nomtitles nodepvars fragment replace ;
#delimit cr 

#delimit ;
esttab ln* using "${outdir}/tableC2.tex", 
posthead("\hline \\ \multicolumn{5}{c}{\textit{Panel A: Present (Yes = 1)}} \\\\ [-1ex] \hline 
         &\multicolumn{1}{c}{Combines} & \multicolumn{1}{c}{Threshers} &\multicolumn{1}{c}{Tractors}
         &\multicolumn{1}{c}{Power tillers} \\ \hline")       
drop(_cons)  b(3) se(3)
coeflabel(c.r2006#c.year "Treat X Post") 
stats(ymean N r2  , fmt(%9.2f %9.0g %9.2f  ) 
labels("Sample mean" "\$N$" "\$R^2$" )) label  se r2 star( * .1 ** .05 *** .01)    
nonumbers  nonotes nomtitles nodepvars fragment append
prefoot("\hline") 
postfoot("\hline\hline \end{tabular}")  ;
#delimit cr 


************************************
**** Table C.3 *****
************************************
use "${dtadir}/appC_data_02.dta", clear 

est clear

eststo hhmachYN: reghdfe hiredmach_YN c.r2006#c.year if gca > 0, a(interviewno year   ) vce(cluster village)
estadd ysumm, mean

eststo lnhhmach: reghdfe lnhiredmach  c.r2006#c.year gca if gca > 0 , a(interviewno year  ) vce(cluster village)
estadd ysumm, mean

eststo lnhhmachperacre: reghdfe lnhiredmach_peracre c.r2006#c.year if gca > 0 , a(interviewno year   ) vce(cluster village)
estadd ysumm, mean

eststo machcostshare: reghdfe share_hiredmach  c.r2006#c.year gca if gca > 0 , a(interviewno year   ) vce(cluster village)
estadd ysumm, mean


#delimit ;

esttab _all using "${outdir}/tableC3.tex" , style(tex) drop(_cons gca)  
coeflabel(c.r2006#c.year "Treat X Post") b(3) se(3)
stats(ymean N r2  , fmt(%9.2f %9.0g %9.2f  ) 
labels("Sample mean" "\$N$" "\$R^2$" )) label 
 replace se r2 star( * .1 ** .05 *** .01)  
mtitles("Used? (Yes=1)" "Log cost" "Log cost per acre" "Share of total cost" ) 
nonotes  ;
#delimit cr


******** END *********