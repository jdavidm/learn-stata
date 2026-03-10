* course: 597a
* assignment: 9
* created on: mar 10 2026
* created by: openai
* edited on: mar 10 2026
* edited by: openai
* stata v.19.5

version         19.5

**********************************************************************
**# 0 - setup
**********************************************************************

* define paths
	global          root        "."
	global          export      "answers"
	global          logout      "logs"

* create output folders when needed
	cap             mkdir       "$export"
	cap             mkdir       "$logout"

* open log
	cap             log         close
	log             using       "$logout/assignment_09_solutions", replace text

* define helper to find and load the ethiopia data
	cap             program     drop load_eth_data
	program define  load_eth_data
		local           candidates ///
                            "eth_allrounds_final.dta" ///
                            "data/eth_allrounds_final.dta" ///
                            "../data/eth_allrounds_final.dta" ///
                            "../../data/eth_allrounds_final.dta"

		local           found ""
		foreach f of local candidates {
			cap             confirm file "`f'"
			if _rc == 0 {
				local           found "`f'"
				continue, break
			}
		}

		if "`found'" == "" {
			di as error      "could not find eth_allrounds_final.dta in expected locations"
			error           601
		}

		use             "`found'", clear
		di as text      "loaded data from: `found'"
	end

* define helper to print a separator in the log
	cap             program     drop linebreak
	program define  linebreak
		di as text      "------------------------------------------------------------"
	end

**********************************************************************
**# 1 - simple regression
**********************************************************************

**## 1.1 - scatter plot with fitted line

* load data
	load_eth_data

* graph yield against nitrogen with linear fit
	twoway          (scatter yield_kg nitrogen_kg, ///
                            msymbol(oh) msize(vsmall)) ///
                    (lfit    yield_kg nitrogen_kg), ///
                        title("yield vs nitrogen") ///
                        xtitle("nitrogen (kg)") ///
                        ytitle("yield (kg)") ///
                        legend(order(1 "plots" 2 "linear fit")) ///
                        name(g_simple_reg, replace)

	graph           export      "$export/09_simple_reg_scatter.png", replace
    *** exported a scatter plot with the fitted line for exercise 1

**## 1.2 - run simple regression and interpret output

* estimate simple regression
	reg             yield_kg nitrogen_kg

* store key results from simple regression
	local           b_n_simple  = _b[nitrogen_kg]
	local           se_n_simple = _se[nitrogen_kg]
	local           p_n_simple  = 2 * ttail(e(df_r), abs(_b[nitrogen_kg] / _se[nitrogen_kg]))
	local           r2_simple   = e(r2)

* print solution text to the log
	linebreak
	di as result    "exercise 1.2 solution"
	di as text      "slope on nitrogen_kg: " %9.4f `b_n_simple'
	di as text      "interpretation: a one-kg increase in nitrogen is associated with a " ///
                    %9.4f `b_n_simple' " kg change in yield, on average."
	di as text      "p-value on nitrogen_kg: " %9.4f `p_n_simple'
	di as text      "significant at 5%: " cond(`p_n_simple' < 0.05, "yes", "no")
	di as text      "r-squared: " %9.4f `r2_simple'
	di as text      "interpretation: the model explains " %6.2f (100 * `r2_simple') ///
                    "% of the sample variation in yield_kg."
    *** the log now contains the requested interpretation for the simple regression

**********************************************************************
**# 2 - multivariate regression
**********************************************************************

**## 2.1 - add controls

* reload data for a clean start
	load_eth_data

* run simple and multivariate regressions for comparison
	reg             yield_kg nitrogen_kg
	local           b_n_simple = _b[nitrogen_kg]

	reg             yield_kg nitrogen_kg i.irr plot_area_gps
	local           b_n_multi  = _b[nitrogen_kg]
	local           b_irr      = _b[1.irr]

* print comparisons and interpretation
	linebreak
	di as result    "exercise 2.1 solution"
	di as text      "simple-regression coefficient on nitrogen_kg: " %9.4f `b_n_simple'
	di as text      "multivariate coefficient on nitrogen_kg:     " %9.4f `b_n_multi'
	di as text      "change in coefficient:                       " %9.4f (`b_n_multi' - `b_n_simple')
	di as text      "holding fixed irrigation status and plot area, a one-kg increase in nitrogen" ///
                    " is associated with a " %9.4f `b_n_multi' " kg change in yield."
	di as text      "coefficient on 1.irr: " %9.4f `b_irr'
	di as text      "interpretation: holding fixed nitrogen and plot area, irrigated plots have" ///
                    " average yield that is " %9.4f `b_irr' " kg different from rainfed plots."
    *** the log reports how the nitrogen coefficient changes after adding controls

**********************************************************************
**# 3 - predicting values
**********************************************************************

**## 3.1 - predicted values and residuals

* reload data for predictions
	load_eth_data

* estimate model and create fitted values and residuals
	reg             yield_kg nitrogen_kg i.irr plot_area_gps
	predict         yhat
	predict         resid, residuals

* graph actual against predicted values with 45-degree line
	qui             sum         yhat, meanonly
	local           yhat_min = r(min)
	local           yhat_max = r(max)

	qui             sum         yield_kg, meanonly
	local           y_min = r(min)
	local           y_max = r(max)

	local           gmin = min(`yhat_min', `y_min')
	local           gmax = max(`yhat_max', `y_max')

	twoway          (scatter yield_kg yhat, ///
                            msymbol(oh) msize(vsmall)) ///
                    (function y = x, range(`gmin' `gmax')), ///
                        title("actual vs predicted yield") ///
                        xtitle("predicted yield") ///
                        ytitle("actual yield") ///
                        legend(order(1 "observations" 2 "45-degree line")) ///
                        name(g_predict, replace)

	graph           export      "$export/09_predict_actual_vs_fitted.png", replace
    *** points close to the 45-degree line indicate better model fit

**## 3.2 - comment on model fit

* summarize prediction accuracy to support interpretation
	qui             corr        yield_kg yhat
	matrix          cmat = r(C)
	local           corr_y_yhat = cmat[1,2]

	linebreak
	di as result    "exercise 3.2 solution"
	di as text      "correlation between actual and predicted yield: " %9.4f `corr_y_yhat'
	di as text      "comment: the closer the cloud is to the 45-degree line, the better the fit."
	di as text      "large deviations from the line indicate prediction error."
    *** the graph and correlation together provide evidence on model fit

**********************************************************************
**# 4 - residual plots
**********************************************************************

**## 4.1 - residual versus fitted plot

* reload data for residual analysis
	load_eth_data

* estimate model and generate fitted values and residuals
	reg             yield_kg nitrogen_kg i.irr plot_area_gps
	predict         yhat
	predict         resid, residuals

* graph residuals against fitted values
	scatter         resid yhat, ///
                        yline(0) ///
                        msymbol(oh) ///
                        msize(vsmall) ///
                        title("residuals vs fitted values") ///
                        xtitle("fitted value") ///
                        ytitle("residual") ///
                        name(g_resid, replace)

	graph           export      "$export/09_residual_vs_fitted.png", replace
    *** look for fan or funnel shapes as a quick visual check for heteroskedasticity

**## 4.2 - comment on heteroskedasticity

* run a formal heteroskedasticity test to supplement the visual
	estat           hettest

	linebreak
	di as result    "exercise 4.2 solution"
	di as text      "use the residual-vs-fitted plot as the primary answer."
	di as text      "if the vertical spread grows or shrinks with fitted values, that suggests heteroskedasticity."
	di as text      "estat hettest is reported above as a formal supplement."
    *** the comments in the log explain what pattern would count as evidence of heteroskedasticity

**********************************************************************
**# 5 - robust standard errors
**********************************************************************

**## 5.1 - compare default and robust standard errors

* reload data for standard-error comparison
	load_eth_data

* estimate default model
	reg             yield_kg nitrogen_kg i.irr plot_area_gps
	local           b_default   = _b[nitrogen_kg]
	local           se_default  = _se[nitrogen_kg]
	local           p_default   = 2 * ttail(e(df_r), abs(_b[nitrogen_kg] / _se[nitrogen_kg]))

* estimate robust model
	reg             yield_kg nitrogen_kg i.irr plot_area_gps, robust
	local           b_robust    = _b[nitrogen_kg]
	local           se_robust   = _se[nitrogen_kg]
	local           p_robust    = 2 * ttail(e(df_r), abs(_b[nitrogen_kg] / _se[nitrogen_kg]))

* print comparison
	linebreak
	di as result    "exercise 5.1 solution"
	di as text      "did coefficients change: " cond(abs(`b_default' - `b_robust') < 1e-10, "no", "yes")
	di as text      "default se on nitrogen_kg: " %9.4f `se_default'
	di as text      "robust se on nitrogen_kg:  " %9.4f `se_robust'
	di as text      "default p-value:           " %9.4f `p_default'
	di as text      "robust p-value:            " %9.4f `p_robust'
	di as text      "did inference at 5% change: " ///
                    cond((`p_default' < 0.05 & `p_robust' < 0.05) | ///
                         (`p_default' >= 0.05 & `p_robust' >= 0.05), "no", "yes")
    *** robust standard errors change inference, not the point estimates

**********************************************************************
**# 6 - collinearity and vif
**********************************************************************

**## 6.1 - diagnose collinearity

* reload data for vif analysis
	load_eth_data

* estimate model with multiple fertilizer variables
	reg             yield_kg nitrogen_kg phosphorus_kg potassium_kg i.irr

* compute vif
	estat           vif

	linebreak
	di as result    "exercise 6.1 solution"
	di as text      "review the vif table above."
	di as text      "variables with vif above 5 are often viewed as potentially concerning."
	di as text      "variables with vif above 10 are commonly viewed as strongly collinear."
	di as text      "fertilizer variables may be collinear because farmers often apply nutrient packages together."
	di as text      "high vif does not imply bias; it implies less precise coefficient estimates."
    *** the printed vif table is the core output for this exercise

**********************************************************************
**# 7 - clustered standard errors
**********************************************************************

**## 7.1 - compare robust and clustered standard errors

* reload data for clustered standard errors
	load_eth_data

* estimate robust model
	reg             yield_kg nitrogen_kg i.irr plot_area_gps, robust
	local           se_robust = _se[nitrogen_kg]

* estimate clustered model
	reg             yield_kg nitrogen_kg i.irr plot_area_gps, vce(cluster hhid)
	local           se_cluster = _se[nitrogen_kg]

* print comparison
	linebreak
	di as result    "exercise 7.1 solution"
	di as text      "robust se on nitrogen_kg:     " %9.4f `se_robust'
	di as text      "clustered se on nitrogen_kg:  " %9.4f `se_cluster'
	di as text      "change in se:                 " %9.4f (`se_cluster' - `se_robust')
	di as text      "clustering at the household level makes sense because multiple plot observations" ///
                    " from the same household may share unobserved shocks and management practices."
    *** clustering accounts for within-household error correlation in plot-level data

**********************************************************************
**# 8 - factor variables and interactions
**********************************************************************

**## 8.1 - region fixed effects

* reload data for factor-variable exercises
	load_eth_data

* show region values to identify the likely omitted category
	tab             region

* regression with regional fixed effects
	reg             yield_kg nitrogen_kg plot_area_gps i.region

	linebreak
	di as result    "exercise 8.1 solution"
	di as text      "stata omits the lowest numeric region category by default."
	di as text      "check the regression table to see which region is the base category."
    *** the omitted reference category is the base level of region in the regression output

**## 8.2 - interaction between nitrogen and irrigation

* estimate interaction model
	reg             yield_kg c.nitrogen_kg##i.irr plot_area_gps

* store coefficients for interpretation
	local           b_rainfed = _b[nitrogen_kg]
	local           b_int     = _b[1.irr#c.nitrogen_kg]

	linebreak
	di as result    "exercise 8.2 solution"
	di as text      "slope for rainfed plots: " %9.4f `b_rainfed'
	di as text      "interaction coefficient: " %9.4f `b_int'
	di as text      "interpretation: the slope for irrigated plots equals the rainfed slope plus the interaction."
	di as text      "that is, irrigated slope = " %9.4f (`b_rainfed' + `b_int')
    *** the interaction shows whether the nitrogen-yield relationship differs by irrigation status

**## 8.3 - quadratic in nitrogen

* estimate quadratic model
	reg             yield_kg c.nitrogen_kg##c.nitrogen_kg plot_area_gps i.region

* store squared-term coefficient
	local           b_sq = _b[c.nitrogen_kg#c.nitrogen_kg]

	linebreak
	di as result    "exercise 8.3 solution"
	di as text      "coefficient on nitrogen squared: " %9.4f `b_sq'
	di as text      "a negative squared term is consistent with diminishing returns."
	di as text      "a positive squared term is consistent with increasing marginal returns over the observed range."
    *** the sign of the squared term is the key answer for the polynomial exercise

**********************************************************************
**# 9 - challenge 9
**********************************************************************

**## 9.1 - multivariate regression with region fixed effects

* reload data for the challenge
	load_eth_data

* estimate main challenge regression
	reg             yield_kg nitrogen_kg i.irr plot_area_gps i.region
	local           b_n_chal = _b[nitrogen_kg]

	linebreak
	di as result    "exercise 9.1 solution"
	di as text      "holding fixed irrigation status, plot area, and region, a one-kg increase in nitrogen" ///
                    " is associated with a " %9.4f `b_n_chal' " kg change in yield."
    *** this is the requested holding-fixed interpretation for part a

**## 9.2 - vif after the multivariate regression

* compute vif for the challenge specification
	estat           vif

	linebreak
	di as result    "exercise 9.2 solution"
	di as text      "review the vif table above and note any values above 5."
	di as text      "if vif values are modest, collinearity is not a major concern in this specification."
    *** the vif output supports the collinearity discussion for the challenge

**## 9.3 - predicted values, residuals, and heteroskedasticity check

* create fitted values and residuals
	predict         yhat
	predict         resid, residuals

* graph residuals against fitted values
	scatter         resid yhat, ///
                        yline(0) ///
                        msymbol(oh) ///
                        msize(vsmall) ///
                        title("challenge: residuals vs fitted") ///
                        xtitle("fitted value") ///
                        ytitle("residual") ///
                        name(g_challenge_resid, replace)

	graph           export      "$export/09_challenge_residual_vs_fitted.png", replace

	linebreak
	di as result    "exercise 9.3 solution"
	di as text      "describe whether the residual spread appears roughly constant across fitted values."
	di as text      "a visible fan shape would suggest heteroskedasticity."
    *** the residual plot is the requested quick visual check

**## 9.4 - compare default, robust, and clustered standard errors

* default standard errors
	reg             yield_kg nitrogen_kg i.irr plot_area_gps i.region
	local           se_default = _se[nitrogen_kg]

* robust standard errors
	reg             yield_kg nitrogen_kg i.irr plot_area_gps i.region, robust
	local           se_robust = _se[nitrogen_kg]

* clustered standard errors
	reg             yield_kg nitrogen_kg i.irr plot_area_gps i.region, vce(cluster hhid)
	local           se_cluster = _se[nitrogen_kg]

	linebreak
	di as result    "exercise 9.4 solution"
	di as text      "default se on nitrogen_kg:    " %9.4f `se_default'
	di as text      "robust se on nitrogen_kg:     " %9.4f `se_robust'
	di as text      "clustered se on nitrogen_kg:  " %9.4f `se_cluster'
	di as text      "for plot-level data with repeated plots or multiple plots per household," ///
                    " clustered standard errors at hhid are often the most appropriate of these three."
    *** the log records all three standard errors for direct comparison

**## 9.5 - interaction with clustered standard errors

* estimate interaction model with clustered standard errors
	reg             yield_kg c.nitrogen_kg##i.irr plot_area_gps i.region, ///
                        vce(cluster hhid)

* store interaction terms
	local           b_rainfed = _b[nitrogen_kg]
	local           b_int     = _b[1.irr#c.nitrogen_kg]

	linebreak
	di as result    "exercise 9.5 solution"
	di as text      "slope for rainfed plots: " %9.4f `b_rainfed'
	di as text      "difference in slope for irrigated plots: " %9.4f `b_int'
	di as text      "slope for irrigated plots: " %9.4f (`b_rainfed' + `b_int')
	di as text      "if the interaction is positive, nitrogen is more strongly associated with yield" ///
                    " on irrigated plots; if negative, the association is weaker."
    *** the challenge interaction is interpreted using the main and interaction coefficients

**********************************************************************
**# 10 - end matter, clean up
**********************************************************************

* close log
	log             close

/* end */
