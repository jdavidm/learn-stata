* course: aae 497a/597a
* assignment: 9
* created on: mar 26
* created by: jdm
* edited on: 10 mar 26
* edited by: openai
* stata v.19.5

**********************************************************************
**# 0 - setup
**********************************************************************

* open log
	cap				log				close
	log using		"$logout/09-regress", append

* define helper program to load maize-only analysis data
	cap program		drop			load_maize_data
	program define	load_maize_data
		use			"$data/eth_allrounds_final.dta", clear

		* keep maize observations
		keep if			lower(crop_name) == "maize"

		* drop plots with missing or nonpositive area
		drop if			missing(plot_area_GPS) | plot_area_GPS <= 0

		* create per-hectare input variables
		cap drop		fert
		gen				fert  = nitrogen_kg / plot_area_GPS
		lab var			fert  "nitrogen fertilizer (kg/ha)"

		cap drop		labor
		gen				labor = total_labor_days / plot_area_GPS
		lab var			labor "labor (days/ha)"

		cap drop		seed
		gen				seed  = seed_value_USD / plot_area_GPS
		lab var			seed  "seed value (usd/ha)"

		* drop observations missing core analysis variables
		drop if			missing(yield_kg, fert, labor)
	end

* load prepared analysis data once
	load_maize_data
    *** this creates the maize-only data with per-hectare inputs used throughout

**********************************************************************
**# 1 - simple reg
**********************************************************************

**## 1.1 - create scatter plot with fitted line

* graph yield against fertilizer with linear fit
	twoway			(scatter yield_kg fert, ///
							msymbol(oh) msize(vsmall)) ///
					(lfit yield_kg fert), ///
						title("yield vs fertilizer") ///
						xtitle("fertilizer (kg/ha)") ///
						ytitle("yield (kg/ha)") ///
						legend(order(1 "plots" 2 "linear fit")) ///
						name(g_simple_reg, replace)

	graph export	"$answ/09-simple-reg-1.png", replace
    *** exported the scatter plot requested in exercise 1

**## 1.2 - run simple regression and report answers

* estimate simple regression
	reg				yield_kg fert

* store results needed for the written answers
	local			b_fert_simple = _b[fert]
	local			se_fert_simple = _se[fert]
	local			t_fert_simple = _b[fert] / _se[fert]
	local			p_fert_simple = 2 * ttail(e(df_r), abs(`t_fert_simple'))
	local			r2_simple = e(r2)

* print the answers to the log
	di as result	"exercise 1.2 solution"
	di as text		"slope on fert: " %9.4f `b_fert_simple'
	di as text		"interpretation: a one-kg increase in fertilizer per hectare is associated with a " ///
					%9.4f `b_fert_simple' " kg change in yield, on average."
	di as text		"statistically significant at the 5% level: " ///
					cond(`p_fert_simple' < 0.05, "yes", "no")
	di as text		"p-value on fert: " %9.4f `p_fert_simple'
	di as text		"r-squared: " %9.4f `r2_simple'
	di as text		"interpretation: the model explains " %6.2f (100 * `r2_simple') ///
					"% of the sample variation in yield_kg."
    *** the log reports the exact coefficient, significance result, and r-squared

**********************************************************************
**# 2 - multivariate reg
**********************************************************************

**## 2.1 - compare simple and multivariate coefficients

* re-estimate simple regression for a direct comparison
	reg				yield_kg fert
	local			b_fert_simple = _b[fert]

* estimate multivariate regression
	reg				yield_kg fert labor i.irr
	local			b_fert_multi = _b[fert]
	local			b_irr_multi = _b[1.irr]

* print the requested answers
	di as result	"exercise 2 solution"
	di as text		"simple-regression coefficient on fert: " %9.4f `b_fert_simple'
	di as text		"multivariate coefficient on fert:     " %9.4f `b_fert_multi'
	di as text		"change in coefficient:                " %9.4f (`b_fert_multi' - `b_fert_simple')
	di as text		"holding fixed labor and irrigation status, a one-kg increase in fertilizer" ///
					" per hectare is associated with a " %9.4f `b_fert_multi' ///
					" kg change in yield."
	di as text		"coefficient on 1.irr: " %9.4f `b_irr_multi'
	di as text		"interpretation: holding fixed fertilizer and labor, irrigated plots have" ///
					" average yield that is " %9.4f `b_irr_multi' ///
					" kg higher or lower than rainfed plots, depending on the sign."
    *** the log compares the simple and multivariate fertilizer slopes and interprets irrigation

**********************************************************************
**# 3 - factor variables
**********************************************************************

**## 3.1 - add regional fixed effects

* estimate model with regional fixed effects
	reg				yield_kg fert labor i.admin_1

* identify the omitted base category
	levelsof			admin_1, local(admin_levels)
	local			base_admin_1 : word 1 of `admin_levels'

* print the answer
	di as result	"exercise 3.1 solution"
	di as text		"omitted reference category for i.admin_1: " "`base_admin_1'"
	di as text		"stata uses the lowest listed category as the default base level unless told otherwise."
    *** the omitted category is the comparison group for the region fixed effects

**## 3.2 - interact fertilizer and irrigation

* estimate interaction model
	reg				yield_kg c.fert##i.irr labor i.admin_1

* store coefficients for interpretation
	local			b_fert_rainfed = _b[fert]
	local			b_fert_irr_int = _b[1.irr#c.fert]

* print the answer
	di as result	"exercise 3.2 solution"
	di as text		"slope for rainfed plots: " %9.4f `b_fert_rainfed'
	di as text		"interaction coefficient: " %9.4f `b_fert_irr_int'
	di as text		"interpretation: the coefficient on fert is the fertilizer slope for the omitted" ///
					" irrigation group, which is rainfed plots."
	di as text		"the interaction tells us how much the fertilizer slope changes on irrigated plots."
	di as text		"slope for irrigated plots: " %9.4f (`b_fert_rainfed' + `b_fert_irr_int')
    *** the interaction coefficient is the difference in slopes between irrigated and rainfed plots

**## 3.3 - fit a quadratic in fertilizer

* estimate quadratic specification
	reg				yield_kg c.fert##c.fert labor i.irr i.admin_1

* store the squared-term coefficient
	local			b_fert_sq = _b[c.fert#c.fert]

* print the answer
	di as result	"exercise 3.3 solution"
	di as text		"coefficient on fert squared: " %9.4f `b_fert_sq'
	di as text		"interpretation: a negative squared term is consistent with diminishing returns" ///
					" to fertilizer over the observed range, while a positive squared term would" ///
					" suggest increasing marginal returns over that range."
    *** the sign of the squared term is the key answer for the diminishing-returns question

**********************************************************************
**# 4 - predict
**********************************************************************

**## 4.1 - generate predicted values

* estimate the prediction model
	reg				yield_kg fert labor i.irr i.admin_1

* create fitted values
	cap drop		yhat
	predict			yhat
    *** yhat contains the predicted values from the regression

**## 4.2 - graph actual yield against predicted yield

* store graph range for the 45-degree line
	qui sum			yhat, meanonly
	local			yhat_min = r(min)
	local			yhat_max = r(max)

	qui sum			yield_kg, meanonly
	local			yield_min = r(min)
	local			yield_max = r(max)

	local			gmin = min(`yhat_min', `yield_min')
	local			gmax = max(`yhat_max', `yield_max')

* graph actual against predicted with 45-degree reference line
	twoway			(scatter yield_kg yhat, ///
							msymbol(oh) msize(vsmall)) ///
					(function y = x, range(`gmin' `gmax')), ///
						title("actual vs predicted yield") ///
						xtitle("predicted yield") ///
						ytitle("actual yield") ///
						legend(order(1 "plots" 2 "45-degree line")) ///
						name(g_predict, replace)

	graph export	"$answ/09-predict-1.png", replace
    *** points closer to the 45-degree line indicate better in-sample fit

**********************************************************************
**# 5 - residuals
**********************************************************************

**## 5.1 - create fitted values and residuals

* re-estimate the same model used for the residual plot
	reg				yield_kg fert labor i.irr i.admin_1

* generate fitted values and residuals
	cap drop		yhat
	cap drop		resid
	predict			yhat
	predict			resid, residuals
    *** residuals measure the difference between actual and fitted yield

**## 5.2 - plot residuals against fitted values

* graph residuals against fitted values
	twoway			(scatter resid yhat, ///
							msymbol(oh) msize(vsmall)), ///
						yline(0) ///
						title("residuals vs fitted values") ///
						xtitle("fitted value") ///
						ytitle("residual") ///
						name(g_resid, replace)

	graph export	"$answ/09-resid-plot-1.png", replace
    *** a fan shape in this plot would suggest heteroskedasticity

* print the interpretation prompt to the log
	di as result	"exercise 5.2 solution"
	di as text		"check whether the vertical spread of residuals changes as yhat increases."
	di as text		"if the spread widens or narrows, that suggests heteroskedasticity."
	di as text		"if the spread stays roughly constant, the errors look closer to homoskedastic."
    *** the visual pattern in the plot is the primary answer for this exercise

**********************************************************************
**# 6 - robust
**********************************************************************

**## 6.1 - compare default and robust standard errors

* estimate default model
	reg				yield_kg fert labor i.irr i.admin_1
	local			b_default = _b[fert]
	local			se_default = _se[fert]
	local			p_default = 2 * ttail(e(df_r), abs(_b[fert] / _se[fert]))

* estimate robust model
	reg				yield_kg fert labor i.irr i.admin_1, robust
	local			b_robust = _b[fert]
	local			se_robust = _se[fert]
	local			p_robust = 2 * ttail(e(df_r), abs(_b[fert] / _se[fert]))

* print the answer
	di as result	"exercise 6 solution"
	di as text		"did coefficients change: " ///
					cond(abs(`b_default' - `b_robust') < 1e-10, "no", "yes")
	di as text		"default se on fert: " %9.4f `se_default'
	di as text		"robust se on fert:  " %9.4f `se_robust'
	di as text		"default p-value on fert: " %9.4f `p_default'
	di as text		"robust p-value on fert:  " %9.4f `p_robust'
	di as text		"did the 5% conclusion change: " ///
					cond((`p_default' < 0.05 & `p_robust' < 0.05) | ///
						 (`p_default' >= 0.05 & `p_robust' >= 0.05), "no", "yes")
    *** robust standard errors affect inference, not the coefficient estimates themselves

**********************************************************************
**# 7 - cluster
**********************************************************************

**## 7.1 - compare robust and clustered standard errors

* estimate robust model
	reg				yield_kg fert labor i.irr i.admin_1, robust
	local			se_robust = _se[fert]

* estimate clustered model
	reg				yield_kg fert labor i.irr i.admin_1, vce(cluster hhid)
	local			se_cluster = _se[fert]

* print the answer
	di as result	"exercise 7 solution"
	di as text		"robust se on fert:    " %9.4f `se_robust'
	di as text		"clustered se on fert: " %9.4f `se_cluster'
	di as text		"change in se:         " %9.4f (`se_cluster' - `se_robust')
	di as text		"clustering at the household level makes sense because multiple plots from the same" ///
					" household may share shocks, measurement error, or management practices."
	di as text		"plot-level clustering would usually be too fine here because each plot is often the" ///
					" unit of observation rather than a cluster containing multiple correlated observations."
    *** household clustering is the appropriate correction when errors may be correlated within hhid

**********************************************************************
**# 8 - vif
**********************************************************************

**## 8.1 - diagnose collinearity

* estimate model with potentially collinear seed measures
	reg				yield_kg fert labor i.irr i.admin_1 seed_value_LCU seed_value_USD

* compute variance inflation factors
	estat			vif

* print the interpretation guidance
	di as result	"exercise 8 solution"
	di as text		"inspect the vif table above for values above 5 and above 10."
	di as text		"the two seed-value variables may be collinear because they measure the same input" ///
					" in different currencies, so one is nearly a rescaled version of the other."
	di as text		"high vif implies imprecision from collinearity, not omitted-variable bias in the coefficients."
    *** the seed-value variables are the most likely source of high vif in this specification

**********************************************************************
**# 9 - challenge
**********************************************************************

**## 9.1 - estimate the main challenge regression

* estimate the challenge specification
	reg				yield_kg fert labor seed i.irr i.intercropped i.crop_shock i.admin_1 i.wave

* store key coefficients
	local			b_labor_main = _b[labor]

* print the answer
	di as result	"exercise 9.1 solution"
	di as text		"holding fixed fertilizer, seed, irrigation, intercropping, crop shock, region," ///
					" and survey wave, a one-day increase in labor per hectare is associated with a " ///
					%9.4f `b_labor_main' " kg change in yield."
    *** this is the requested holding-fixed interpretation for labor

**## 9.2 - run vif for the challenge model

* compute variance inflation factors
	estat			vif

* print the interpretation guidance
	di as result	"exercise 9.2 solution"
	di as text		"inspect the vif table above and note whether any variables exceed 5."
	di as text		"collinearity is more concerning when vif values are large enough to inflate standard" ///
					"errors materially, but it does not by itself imply biased coefficients."
    *** the vif table provides the direct answer to the collinearity question

**## 9.3 - generate predictions and check heteroskedasticity

* generate fitted values and residuals from the challenge model
	cap drop		yhat
	cap drop		resid
	predict			yhat
	predict			resid, residuals

* graph residuals against fitted values
	twoway			(scatter resid yhat, ///
							msymbol(oh) msize(vsmall)), ///
						yline(0) ///
						title("challenge residuals vs fitted") ///
						xtitle("fitted value") ///
						ytitle("residual") ///
						name(g_challenge_resid, replace)

	graph export	"$answ/09-challenge-resid-1.png", replace
    *** use the shape of the residual cloud to judge whether heteroskedasticity is visible

* print the interpretation guidance
	di as result	"exercise 9.3 solution"
	di as text		"use the plot above to judge whether residual spread changes across fitted values."
	di as text		"a wider spread at higher fitted values would be evidence of heteroskedasticity."
    *** this visual check answers the heteroskedasticity part of the challenge

**## 9.4 - compare default, robust, and clustered standard errors

* estimate default model
	reg				yield_kg fert labor seed i.irr i.intercropped i.crop_shock i.admin_1 i.wave
	local			se_default = _se[fert]

* estimate robust model
	reg				yield_kg fert labor seed i.irr i.intercropped i.crop_shock i.admin_1 i.wave, robust
	local			se_robust = _se[fert]

* estimate clustered model
	reg				yield_kg fert labor seed i.irr i.intercropped i.crop_shock i.admin_1 i.wave, ///
					vce(cluster hhid)
	local			se_cluster = _se[fert]

* print the answer
	di as result	"exercise 9.4 solution"
	di as text		"default se on fert:    " %9.4f `se_default'
	di as text		"robust se on fert:     " %9.4f `se_robust'
	di as text		"clustered se on fert:  " %9.4f `se_cluster'
	di as text		"the clustered approach is usually most appropriate here because the data are at the" ///
					" plot level and plots from the same household may have correlated errors."
    *** the log reports all three standard errors for direct comparison

**## 9.5 - interact fertilizer and labor

* estimate model with a fertilizer-labor interaction
	reg				yield_kg c.fert##c.labor seed i.irr i.intercropped i.crop_shock i.admin_1 i.wave

* store interaction coefficients
	local			b_fert_int = _b[fert]
	local			b_labor_int = _b[labor]
	local			b_fert_labor = _b[c.fert#c.labor]

* print the answer
	di as result	"exercise 9.5 solution"
	di as text		"coefficient on fert: " %9.4f `b_fert_int'
	di as text		"coefficient on labor: " %9.4f `b_labor_int'
	di as text		"coefficient on c.fert##c.labor: " %9.4f `b_fert_labor'
	di as text		"interpretation: the coefficient on fert is the marginal effect of fertilizer when" ///
					" labor equals zero."
	di as text		"the coefficient on labor is the marginal effect of labor when fertilizer equals zero."
	di as text		"the interaction coefficient tells us how the marginal effect of fertilizer changes" ///
					" as labor increases, and equivalently how the marginal effect of labor changes as" ///
					" fertilizer increases."
    *** with continuous-by-continuous interactions, marginal effects depend on the level of the other input

**********************************************************************
**# 10 - end matter, clean up
**********************************************************************

* close log
	log				close

/* end */
