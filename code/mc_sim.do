* project: IRRI STRV
* created on: 16 July 2024
* created by: jdm
* edited on: 9 May 2025
* edited by: jdm
* Stata v.18.5

* does
	* imports Emerick et al (2016) replication data
	* runs MC simulations

* assumes
	* access to replication data
	* add packages needed

* to do:
	* need to replace negative yield values with zero
	* after about .13 noise to sd the yield values blow up
	
	
************************************************************************
**# 0 - setup
************************************************************************

	clear all

* define paths
	global	import	=	"$data/bangladesh/mc_sim"
	global	logout	=	"$data/bangladesh/analysis/logs"
	global 	figures	= 	"$data/documents/paper/figures"
	global 	tables	= 	"$data/documents/paper/tables"
	
* open log
	cap log 		close
	log using		"$logout/mc_sim", append
	
	
************************************************************************
**# 1 - field trial data from Dar et al. (2013)
************************************************************************

* load in trial data from Kyle
	import 			delimited "$import/agricultural_trials.csv", clear 

* create graphs
	twoway			(scatter yield duration if variety == "SS1", mcolor("dkgreen") ///
						msymbol("X")) ///
					(scatter yield duration if variety == "Swarna", mcolor("navy") ///
						msymbol("O")) ///
					(fpfit yield duration if variety == "SS1", lcolor("dkgreen") ///
						lpattern("l")) ///
					(fpfit yield duration if variety == "Swarna", lcolor("navy") ///
						lpattern("_-") xtitle("Duration of Submergence (days)") ///
						ytitle("Yield (t ha{sup:-1})")), ///
					legend(pos(6) col(2) order(1 "Swarna-Sub1" ///
					2 "Swarna"))

* save graphs
	graph export 	"$figures/field_trial.eps", replace as(eps)
	graph export 	"$figures/field_trial.png", replace as(png)
	
* generate sub1 indicator	
	gen				sub = 1 if variety == "SS1"
	replace			sub = 0 if sub == .
	
* generate flood > 12
	gen				fld_12 = duration - 12
	replace			fld_12 = 0 if fld_12 < 1
	
	gen				sub12 = sub*fld_12
	
* generate interactions
	gen				subfld = sub*duration
	
* location fe
	encode			location, gen(bl_fe)
	
* regression 3 in table 1	
	reg				yield sub duration subfld fld_12 sub12 i.bl_fe
						
************************************************************************
**# 2 - replication of Dar et al. (2013) using Emerick et al. (2016)
************************************************************************

	use 			"$import/r_plotlevel_year1.dta", replace
	
	gen				year = 1
	
	drop if			yield == .

	gen				sub = 1 if ricevar == "swarna-sub1"
	replace			sub = 0 if sub == .
	
	gen				mv = 1 if tvormv == 2 & ricevar != "swarna"
	replace			mv = 0 if mv == .
	
	gen				trv = 1 if tvormv == 1
	replace			trv = 0 if trv == .

*	gen				variety = 1 if ricevar == "swarna-sub1"
*	replace			variety = 2 if tvormv == 2 & variety == .
*	replace			variety = 3 if tvormv == 1 & variety == .
	
	sort			block
	egen			bl_fe = group(block)
	
	xtset			bl_fe

* regression 1 in table 1
	reg				yield sub mv trv durflood i.bl_fe, vce(cluster village_id)
	
* generate interactions
	gen				subfld = sub*durflood
	gen				mvfld = mv*durflood
	gen				trvfld = trv*durflood

* regression 2 in table 1	
	reg				yield sub mv trv durflood subfld mvfld trvfld i.bl_fe, vce(cluster village_id)
	
* generate flood > 12
	gen				fld_12 = durflood - 12
	replace			fld_12 = 0 if fld_12 < 1
	
	gen				sub12 = sub*fld_12
	
* regression 3 in table 1	
	reg				yield sub mv trv durflood subfld mvfld trvfld ///
						fld_12 sub12 i.bl_fe, vce(cluster village_id)
	
/*
Cannot replicate results in Dar et al. (2013). Data is similar across two studies,
and should be the same, but small differences in data give very different results.
Would like to sort out issues and be able to use panel to do MC sim but lack time now.
*/
	
************************************************************************
**# 3 - replication of Dar et al. (2013) using Dar et al. (2013)
************************************************************************

	use 			"$import/plot_prod_y1.dta", replace
	
	drop if 		yield > 8000
	drop if			yield == .
	drop if			vtype == ""
	
	replace			vtype = "swarna" if wetvar_ == "DHOLA SWARNA"
	
	sort			vtype
	egen			variety = group(vtype)

	gen				omv = 1 if variety == 1
	replace			omv = 0 if omv == .
	
	gen				swn = 1 if variety == 2
	replace			swn = 0 if swn == .
	
	gen				sub = 1 if variety == 3
	replace			sub = 0 if sub == .
	
	gen				trv = 1 if variety == 4
	replace			trv = 0 if trv == .
	
	sort			block
	egen			bl_fe = group(block)

* regression 1 in table 1
	reg				yield sub omv trv durflood i.bl_fe, vce(cluster village_id)

* generate interactions
	gen				subfld = sub*durflood
	gen				omvfld = omv*durflood
	gen				trvfld = trv*durflood

* regression 2 in table 1	
	reg				yield sub omv trv durflood subfld trvfld omvfld i.bl_fe, vce(cluster village_id)
	
* generate flood > 12
	gen				fld_12 = durflood - 12
	replace			fld_12 = 0 if fld_12 < 1
	
	gen				sub_12 = sub*fld_12
	
* regression 3 in table 1	
	reg				yield sub omv trv durflood subfld trvfld omvfld ///
						fld_12 sub_12 i.bl_fe, vce(cluster village_id)	

	save			"$import/mc_data", replace
	
/*
Can replicate results in Dar et al. (2013). Data is similar with at least 2 differences.
One less sub1 adopter than in paper and 5 more households than in paper.
Not sure if other differences exist.
*/


************************************************************************
**# 4 - MC simulations
************************************************************************


************************************************************************
**## 4.1 - MC simulations - noise in yield data
************************************************************************

	capture program drop yld_reg

* set up program to add noise to yield
	program 		yld_reg, rclass
		args 			np
		qui: sum        yield
		local           y_mean = r(mean)
		local           y_std = r(sd)
    
		local    		ymn = `y_mean'*`np'
		local    		ysd = `y_std'*`np'

		replace         yield = yield + rnormal(0,`ysd')
		replace			yield = 0 if yield < 0
        
		sum				yield
		return scalar 	mean = r(mean)
	
		reg				yield sub omv trv durflood subfld trvfld omvfld ///
							fld_12 sub_12 i.bl_fe, vce(cluster village_id)
end

* run mc simulations
	set				seed 5762
	forvalues 		j = 0/20 {
		local 			i = `j'/100
		tempfile 		results`j'
		use 			"$import/mc_data", clear
		simulate 		_b _se dfr=(e(df_r)) mean=r(mean), ///
							saving(`results`j'') reps(10000): yld_reg `i'
}

* save mc results
	clear
	tempfile 		building
	save 			`building', emptyok
	forvalues 		j = 0/20 {
		use 			`results`j'', clear
		gen 			noise = `j'/100
		append 			using `building'
		save 			`"`building'"', replace
}

* examine mc results
	rename 			_eq2_dfr dfr
	rename			_eq2_mean yield
	gen             t_subfld = _b_subfld/_se_subfld
	gen             p_subfld = 2*ttail(dfr,abs(t_subfld))
	gen				sig = 1 if p_subfld < 0.051
	replace			sig = 0 if sig == .
	replace			sig = . if p_subfld == .
	bys noise:		sum _b_subfld _se_subfld yield
	bys noise:		tab	sig

* label stuff for graph
	replace			noise = noise * 100
	replace			noise = 15 if noise > 15 & noise < 15.5
	lab de 			noise 0 "0.00{&sigma}" 1 "0.01{&sigma}" 2 "0.02{&sigma}" ///
						3 "0.03{&sigma}" 4 "0.04{&sigma}" 5 "0.05{&sigma}" ///
						6 "0.06{&sigma}" 7 "0.07{&sigma}" 8 "0.08{&sigma}" ///
						9 "0.09{&sigma}" 10 "0.10{&sigma}" 11 "0.11{&sigma}" ///
						12 "0.12{&sigma}" 13 "0.13{&sigma}" 14 "0.14{&sigma}" ///
						15 "0.15{&sigma}" 16 "0.16{&sigma}" 17 "0.17{&sigma}" ///
						18 "0.18{&sigma}" 19 "0.19{&sigma}" 20 "0.20{&sigma}", replace
	lab val 		noise noise

    save 			"$import/mc_sim_yield", replace
	use				"$import/mc_sim_yield", clear

* summarize p-values to determine when # of sig p-values ~ 5%	
	bys noise:		tab sig
	
* generate ridge plot of p-value variation
	set 			scheme white_tableau
	
	joyplot			p_subfld, by(noise) yline bwid(0.01) norm(local) rescale ///
						overlap(2) xline(0.05, lcolor(maroon)) alpha(60) ///
						xlabel(0(.1)1) xtitle("p-values") palette(crest) ///
						ytitle("Amount of Added Noise in Yield Measure") ///
						title("B", pos(11) size(large) ring(1) xoffset(-10))

* save graphs
	graph export 	"$figures/yield_mc.png", replace as(png)
	graph export 	"$figures/yield_mc.eps", replace as(eps)
	
	
************************************************************************
**## 4.2 - MC simulations - noise in flood data
************************************************************************

* reload data
	use				"$import/mc_data", clear

	capture program drop fld_reg

* set up program to add noise to yield
	program 		fld_reg, rclass
		args 			np
		qui: sum        durflood
		local           f_mean = r(mean)
		local           f_std = r(sd)
    
		local    		fmn = `f_mean'*`np'
		local    		fsd = `f_std'*`np'

		replace         durflood = durflood + rnormal(0,`fsd')
		replace			durflood = 0 if durflood < 0
		
		replace			subfld = sub*durflood
		replace			trvfld = trv*durflood
		replace			omvfld = omv*durflood
		replace			fld_12 = durflood - 12
		replace			fld_12 = 0 if fld_12 < 1
		replace			sub_12 = sub*fld_12
        
		sum				durflood
		return scalar 	mean = r(mean)
	
		reg				yield sub omv trv durflood subfld trvfld omvfld ///
							fld_12 sub_12 i.bl_fe, vce(cluster village_id)
end

* run mc simulations
	set				seed 5762
	forvalues 		j = 0/20 {
		local 			i = `j'/100
		tempfile 		results`j'
		use 			"$import/mc_data", clear
		simulate 		_b _se dfr=(e(df_r)) mean=r(mean), ///
							saving(`results`j'') reps(10000): fld_reg `i'
}

* save mc results
	clear
	tempfile 		building
	save 			`building', emptyok
	forvalues 		j = 0/20 {
		use 			`results`j'', clear
		gen 			noise = `j'/100
		append 			using `building'
		save 			`"`building'"', replace
}

* examine mc results
	rename 			_eq2_dfr dfr
	rename			_eq2_mean durflood
	gen             t_subfld =_b_subfld/_se_subfld
	gen             p_subfld = 2*ttail(dfr,abs(t_subfld))
	gen				sig = 1 if p_subfld < 0.051
	replace			sig = 0 if sig == .
	replace			sig = . if p_subfld == .
	bys noise:		sum _b_subfld _se_subfld durflood
	bys noise:		tab	sig

* label stuff for graph
	replace			noise = noise * 100
	replace			noise = 15 if noise > 15 & noise < 15.5
	lab de 			noise 0 "0.00{&sigma}" 1 "0.01{&sigma}" 2 "0.02{&sigma}" ///
						3 "0.03{&sigma}" 4 "0.04{&sigma}" 5 "0.05{&sigma}" ///
						6 "0.06{&sigma}" 7 "0.07{&sigma}" 8 "0.08{&sigma}" ///
						9 "0.09{&sigma}" 10 "0.10{&sigma}" 11 "0.11{&sigma}" ///
						12 "0.12{&sigma}" 13 "0.13{&sigma}" 14 "0.14{&sigma}" ///
						15 "0.15{&sigma}" 16 "0.16{&sigma}" 17 "0.17{&sigma}" ///
						18 "0.18{&sigma}" 19 "0.19{&sigma}" 20 "0.20{&sigma}", replace
	lab val 		noise noise

    save 			"$import/mc_sim_flood", replace
    use 			"$import/mc_sim_flood", clear
	
* summarize p-values to determine when # of sig p-values ~ 5%
	bys noise: 		tab sig
	
* generate ridge plot of p-value variation
	set 			scheme white_tableau
	
	joyplot			p_subfld, by(noise) yline bwid(0.01) norm(local) rescale ///
						overlap(2) xline(0.05, lcolor(maroon)) alpha(60) ///
						xlabel(0(.1)1) xtitle("p-values") palette(crest) ///
						ytitle("Amount of Added Noise in Flood Measure")  ///
						title("A", pos(11) size(large) ring(1) xoffset(-10))
	
* save graphs
	graph export 	"$figures/flood_mc.png", replace as(png)
	graph export 	"$figures/flood_mc.eps", replace as(eps)
	
	
************************************************************************
**## 4.3 - MC simulations - noise in adoption data
************************************************************************

	capture program drop sub_reg

* set up program to add noise to treatment assignment
	program 		sub_reg, rclass
		args 			np
		tempvar			r_num rank num tag
		gen				`r_num' = runiform()
		sort			`r_num'
		gen				`rank' = _n
		gen				`num' = 41.82*`np'
		gen				`tag' = 1 if `rank' < `num'
		replace			`tag' = 0 if `tag' == .
		
		gen				subn = sub if `tag' == 0
		replace			subn = 1 if `tag' == 1 & sub == 0	
		replace			subn = 0 if `tag' == 1 & sub == 1
		
		replace			subfld = subn*durflood
		replace			sub_12 = subn*fld_12
        
		sum				subn
		return scalar 	mean = r(mean)
	
		reg				yield subn omv trv durflood subfld trvfld omvfld ///
							fld_12 sub_12 i.bl_fe, vce(cluster village_id)
							
		drop			subn
end
	
* run mc simulations
	set				seed 5762
	forvalues 		j = 0/50 {
		tempfile 		results`j'
		use 			"$import/mc_data", clear
		simulate 		_b _se dfr=(e(df_r)) mean=r(mean), ///
							saving(`results`j'') reps(10000): sub_reg `j'
}

* save mc results
	clear
	tempfile 		building
	save 			`building', emptyok
	forvalues 		j = 0/50 {
		use 			`results`j'', clear
		gen 			noise = `j'
		append 			using `building'
		save 			`"`building'"', replace
}	

* examine mc results
	rename 			_eq2_dfr dfr
	rename			_eq2_mean subn
	gen             t_subfld =_b_subfld/_se_subfld
	gen             p_subfld = 2*ttail(dfr,abs(t_subfld))
	gen				sig = 1 if p_subfld < 0.051
	replace			sig = 0 if sig == .
	replace			sig = . if p_subfld == .
	gen				treated = subn*4182
	bys noise:		sum _b_subfld _se_subfld treated
	bys noise:		tab	sig

* label stuff for graph
	lab de 			noise 0 "0%" 1 "1%" 2 "2%" 3 "3%" 4 "4%" 5 "5%" ///
						6 "6%" 7 "7%" 8 "8%" 9 "9%" 10 "10%" 11 "11%" ///
						12 "12%" 13 "13%" 14 "14%" 15 "15%" 16 "16%" 17 "17%" ///
						18 "18%" 19 "19%" 20 "20%" 21 "21%" 22 "22%" ///
						23 "23%" 24 "24%" 25 "25%" 26 "26%" 27 "27%" ///
						28 "28%" 29 "29%" 30 "30%", replace
	lab val 		noise noise

    save 			"$import/mc_sim_sub", replace
    use 			"$import/mc_sim_sub", clear
	
* summarize p-values to determine when # of sig p-values ~ 5%
	bys noise: 		tab sig
	
* generate ridge plot of p-value variation
	set 			scheme white_tableau
	
	joyplot			p_subfld, by(noise) yline bwid(0.01) norm(local) rescale ///
						overlap(2) xline(0.05, lcolor(maroon)) alpha(60) ///
						xlabel(0(.1)1) xtitle("p-values") palette(crest) ///
						ytitle("Amount of Added Noise in Adoption")  ///
						title("C", pos(11) size(large) ring(1) xoffset(-10))
	
* save graphs
	graph export 	"$figures/sub_mc.png", replace as(png)
	graph export 	"$figures/sub_mc.eps", replace as(eps)	
	
* close the log
	log	close

/* END */		