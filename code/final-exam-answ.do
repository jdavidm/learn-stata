* course: AAE 497A/597A
* assignment: final exam
* created on: 10 may 26
* created by: jdm
* edited on: 12 may 26
* edited by: jdm
* Stata v.19.5

* ============================================================================
* FINAL EXAM — DEBUGGING
* ============================================================================
*
* instructions:
*
*   this .do file is FULL of bugs (> 25 & < 30). your job is to find and fix
*    them so the code runs cleanly from start to finish.
*
*   the file is organized into 8 independent sections, each separated by a
*   header. each section loads its own data, so you do NOT need to fix earlier
*   sections before working on later ones. work on whatever sections you feel
*   most confident about first.
*
*   not all bugs are syntax errors; some are conceptual errors, meaning that
*   the code runs, but it doesn't do what it's supposed to do. to determine
*   this, you may need to inspect the output and make sure it makes sense.
*
*   you may use Stata help documentation (e.g., `help regress`) but no other
*   outside sources.
*
*   for each bug you fix, leave a brief comment below the bug explaining 
*   what was wrong and what you changed, using three stars (***). for example:
*
*       *** changed `=` to `==` because `if` requires a logical comparison
*
*   good luck! you have spent a whole semester building these skills. now
*   you get to show what you can do.
*
* ============================================================================

**********************************************************************
**# 0 - setup
**********************************************************************

* define paths
	global	root 	"https://media.githubusercontent.com/media/jdavidm/learn-stata/main/data"
	global	logout	"C:/Users/jdmichler/git/semester26/logs"

* open log
	cap		log		close
	log 	using 	"$logout/final-exam", replace


**********************************************************************
**# 1 - data management (weeks 3–4)
**********************************************************************

* load lsms household data
	use			"$root/lsms_household.dta", clear

* label some variables
	lab var		hh_size "Household size"
	lab var		totcons_USD "Consumption per capita (USD)"

* create a binary variable for large households (more than 6 members)
	gen			large_hh = 1 if hh_size > 6
	replace		large_hh = 0 if large_hh == .
	lab var		large_hh "= 1 if household has more than 6 members"

* define and apply value labels
	lab def		size_lbl 0 "Small" 1 "Large"
	lab val		large_hh size_lbl 

* tabulate
	tab			large_hh

* generate mean consumption by wave
	egen		mean_cons = mean(totcons_USD), by(wave)
	lab var		mean_cons "Mean consumption per capita by wave (USD)"

* summarize
	sum			totcons_USD mean_cons

* keep essential variables and save
	keep		hhid eaid wave country hh_size large_hh ///
					totcons_USD mean_cons


**********************************************************************
**# 2 - distributions and graphing (weeks 4–5)
**********************************************************************

* load ethiopia plot data
	use			"$root/eth_allrounds_final.dta", clear

* summarize yield
	sum			yield_kg, detail

* histogram of yield
	histogram	yield_kg, ///
					percent ///
					bin(30) ///
					title("Distribution of Crop Yield") ///
					xtitle("Yield (kg)") ///
					ytitle("Percent of plots")

* overlay a kernel density on the histogram
	twoway		(histogram yield_kg, bin(30) percent color(%50)) || ///
				(kdensity yield_kg), ///
					title("Yield distribution with density overlay") ///
					xtitle("Yield (kg)") ///
					ytitle("Percent") ///
					legend(order(1 "Histogram" 2 "Kernel density") ///
					pos(6) col(2))


**********************************************************************
**# 3 - macros, loops, and stored results (week 6)
**********************************************************************

* load ethiopia plot data
	use			"$root/eth_allrounds_final.dta", clear

* store controls in a local
	local		controls nitrogen_kg plot_area_GPS irrigated

* use the local in a regression
	reg			yield_kg `controls'

* store the r-squared
	local		rsq = e(r2)
	display		"R-squared from baseline regression: `rsq'"

* loop over waves and summarize yield
	forvalues	w = 1/5 {
		display		"--- Wave `w' ---"
		sum			yield_kg if wave == `w'
	}

* loop over shock variables and tabulate each
	foreach		shock in crop_shock drought_shock flood_shock {
		display		"Shock: `shock'"
		tab			`shock'
	}

* generate log variables using a loop
	local		logvars yield_kg harvest_value_USD
	foreach v of varlist `logvars' {
		gen			ln_`v' = ln(`v')
		lab var		ln_`v' "Log of `v'"
	}

* summarize the new log variables
	sum			ln_*


**********************************************************************
**# 4 - regression and diagnostics (week 9)
**********************************************************************

* load ethiopia plot data
	use			"$root/eth_allrounds_final.dta", clear

* keep only maize
	keep if		crop_name == "MAIZE"

* create per-hectare input variables
	gen			fert = nitrogen_kg / plot_area_GPS
	lab var		fert "Fertilizer (kg/ha)"
	gen			labor = total_labor_days / plot_area_GPS
	lab var		labor "Labor (days/ha)"

* simple regression
	reg			yield_kg fert

* store the coefficient on fertilizer
	local		b_fert = _b[fert]
	display		"Coefficient on fertilizer: `b_fert'"

* residual plot
	predict		yhat
	predict		resid, residuals

* multivariate regression
	reg			yield_kg fert labor i.irr
	twoway		(scatter resid yhat, ///
					msymbol(oh) msize(vsmall)), ///
					yline(0) ///
					title("Residuals vs Fitted Values") ///
					xtitle("Fitted value") ///
					ytitle("Residual")

* compare standard errors
	reg			yield_kg fert labor i.irr, robust
	local		se_robust = _se[fert]

	reg			yield_kg fert labor i.irr, vce(cluster hh_id_obs)
	local		se_cluster = _se[fert]

	display		"Robust SE: `se_robust'"
	display		"Clustered SE: `se_cluster'"

* check for collinearity
	reg			yield_kg fert labor i.irr seed_value_LCU seed_value_USD
	estat		vif


**********************************************************************
**# 5 - presenting results with estout (week 10)
**********************************************************************

* load tenure data
	use			"$root/tenuredata.dta", clear

* run three specifications
	reg			yield q_f_ha lt_f_ha, vce(cluster panelid)
	estimates	store s1

	reg			yield q_f_ha lt_f_ha i.irrig i.tenure, vce(cluster panelid)
	estimates	store s2

	reg			yield q_f_ha lt_f_ha i.irrig i.tenure ///
					i.site i.year, vce(cluster panelid)
	estimates 	store s3

* export a table
	esttab		s1 s2 s3, ///
					se star(* 0.10 ** 0.05 *** 0.01) ///
					keep(q_f_ha lt_f_ha 1.irrig 1.tenure) ///
					order(q_f_ha lt_f_ha 1.irrig 1.tenure) ///
					indicate("Site FE = *.site" "Year FE = *.year") ///
					stats(N r2, labels("Observations" "R-squared") fmt(0 3)) ///
					label

* coefficient plot
	coefplot	(s1, label("Baseline")) ///
				(s2, label("+ Controls")) ///
				(s3, label("+ FE")), ///
					keep(q_f_ha lt_f_ha) xline(0) ///
					title("Fertilizer and Labor Across Specifications") ///
					xtitle("Coefficient")


**********************************************************************
**# 6 - fixed effects (week 11)
**********************************************************************

* load chickpea panel data
	use			"$root/mm.dta", clear

* pooled OLS
	reg			yield totfertcostha, vce(cluster qnno)
	eststo		ols_fe

* first differencing
	sort		qnno tindex

	by qnno:	gen d_yield = yield - yield[_n-1]
	by qnno:	gen d_fert = totfertcostha - totfertcostha[_n-1]

	reg			d_yield d_fert, vce(cluster qnno)
	eststo		fd

* demeaning
	bysort qnno: egen mean_yield = mean(yield)
	bysort qnno: egen mean_fert  = mean(totfertcostha)

	gen			dm_yield = yield - mean_yield
	gen			dm_fert  = totfertcostha - mean_fert

	reg			dm_yield dm_fert, vce(cluster qnno)
	eststo		dm

* set qnno and tindex as panel identifiers
	xtset		qnno tindex

* xtreg fixed effects
	xtreg		yield totfertcostha, fe vce(cluster qnno)
	eststo		fe

* two-way fixed effects with reghdfe
	reghdfe		yield totfertcostha, absorb(qnno tindex) vce(cluster qnno)
	eststo		twfe

* compare all models
	esttab		ols_fe fd dm fe twfe, ///
					b(3) se(3) ///
					keep(totfertcostha d_fert dm_fert) ///
					star(* 0.10 ** 0.05 *** 0.01) ///
					stats(N r2, labels("Observations" "R-squared") fmt(0 3))


**********************************************************************
**# 7 - difference-in-differences (week 12)
**********************************************************************

* load bangladesh panel data
	use			"$root/panel_gis.dta", clear

* set panel
	xtset		district_id year

* continuous treatment DiD
	xtreg 		evi_med c.seed i.year, fe ///
					vce(cluster district_id)
	eststo		did1
	
* create an adoption cohort variable
	gen			seed_yr = year if seed > 0
	bysort		district_id: ///
		egen	first_seed = min(seed_yr)
	drop		seed_yr

* generate relative time
	gen			ry = year - first_seed

* create 9 pre-treatment indicators for event study
	forvalues	k = 10(-1)2 {
		gen			g_`k' = ry == -`k'
		label var	g_`k' "-`k'"
	}

* create 9 post-treatment indicators for event study
	forvalues	k = 1/8 {
		gen			g`k' = ry == `k'
		label var	g`k' "`k'"
	}

* event study regression
	xtreg		evi_med g_* g1-g8 i.year, ///
					fe vce(cluster district_id)

* coefficient plot of event study with red line at time 0 (9.5)
	coefplot,	drop(_cons *.year) ///
					vertical xline(9.5, lcolor(maroon))  ///
					title("Event Study: EVI Response to Seed Adoption") ///
					ytitle("Coefficient") xtitle("Event Time")


**********************************************************************
**# 8 - instrumental variables (week 13)
**********************************************************************

* load conservation agriculture data
	use			"$root/Michler_JEEM.dta", clear
	keep if		crop == 1

* OLS
	reg			lnyield CA lnbasal lntop lnseed lnaream2 ///
					pdate pdate2 i.year, cluster(rc)
	eststo		ols_iv

* first stage
	reg			CA wardNGO lnbasal lntop lnseed lnaream2 ///
					pdate pdate2 i.year, cluster(rc)
	eststo		first_stage

* manual 2SLS - generate predicted values
	predict		CA_hat

* second stage using predicted values
	reg			lnyield CA_hat lnbasal lntop lnseed lnaream2 ///
					pdate pdate2 i.year, cluster(rc)
	eststo		manual_iv

* proper IV using ivreg2
	ivreg2		lnyield lnbasal lntop lnseed lnaream2 ///
					pdate pdate2 i.year (CA = wardNGO), ///
					cluster(rc) first
	eststo		iv

* compare coefficients and standard errors across OLS, manual 2SLS, and IV 
	esttab		ols_iv manual_iv iv, ///
					b(3) se(3) keep(CA) ///
					rename(CA_hat CA) ///
					star(* 0.10 ** 0.05 *** 0.01) ///
					stats(N r2, labels("Observations" "R-squared") fmt(0 3))


**********************************************************************
**# 9 - end matter
**********************************************************************

* close log
	log			close

/* END */
