* course: 597a
* assignment: 15
* created on: 24 apr 26
* created by: jdm
* edited on: 29 apr 26
* edited by: jdm
* stata v.19.5


**********************************************************************
**# 0 - setup
**********************************************************************

* open log
	cap             log close
	log             using "$logout/15-ml.log", append

* load data
	use             "$data/plot_dataset.dta", clear


**********************************************************************
**# exercise 1 - Setup and Train/Test Split
**********************************************************************

* examine the data
	sum             yield_kg

* create random split variable
    splitsample,    generate(sample) split(0.70 0.30) rseed(8675309)
    
* label the values of sample
    lab def         svalues 1 "Training" 2 "Testing"
    lab val         sample svalues
    tab             sample

* initialize H2O cluster
    h2o init

* push training and testing data to separate H2O frames
    _h2oframe put if sample == 1, into(train_frame) current
    _h2oframe put if sample == 2, into(test_frame)

**## 1.1 - report split
    *** report the number of training and test observations
    count if        sample == 1
    count if        sample == 2

	
**********************************************************************
**# exercise 2 - Lasso for Prediction
**********************************************************************

* fit lasso on training data
    lasso linear    yield_kg plot_area_GPS seed_kg ///
                        nitrogen_kg total_labor_days ///
                        total_hired_labor_days improved ///
                        used_pesticides organic_fertilizer ///
                        irrigated intercropped ///
                        age_manager female_manager ///
                        formal_education_manager ///
                        plot_slope elevation ///
                        dist_market dist_popcenter ///
                        soil_fertility_index ///
                        crop_shock drought_shock ///
                        i.crop i. agro_ecological_zone ///
						i.wave i.country ///
                        if sample == 1
    estimates store cv

* fit adaptive lasso on training data
    lasso linear    yield_kg plot_area_GPS seed_kg ///
                        nitrogen_kg total_labor_days ///
                        total_hired_labor_days improved ///
                        used_pesticides organic_fertilizer ///
                        irrigated intercropped ///
                        age_manager female_manager ///
                        formal_education_manager ///
                        plot_slope elevation ///
                        dist_market dist_popcenter ///
                        soil_fertility_index ///
                        crop_shock drought_shock ///
                        i.crop i. agro_ecological_zone ///
						i.wave i.country ///
                        if sample == 1, selection(adaptive)
    estimates store adpt

* inspect and compare selected variables
    lassocoef cv adpt, display(coef, standardized)

* plot the cross-validation curves
    estimates restore cv
    cvplot
    graph export    "$answ/15-ml-lasso-2.png", replace

    estimates restore adpt
    cvplot
    graph export    "$answ/15-ml-lasso-3.png", replace

* report goodness of fit out-of-sample
    lassogof cv adpt, over(sample) postselection


**********************************************************************
**# exercise 3 - Elastic Net and Ridge
**********************************************************************

* lasso via elasticnet (alpha = 1)
	elasticnet linear yield_kg plot_area_GPS seed_kg ///
                        nitrogen_kg total_labor_days ///
                        total_hired_labor_days improved ///
                        used_pesticides organic_fertilizer ///
                        irrigated intercropped ///
                        age_manager female_manager ///
                        formal_education_manager ///
                        plot_slope elevation ///
                        dist_market dist_popcenter ///
                        soil_fertility_index ///
                        crop_shock drought_shock ///
                        i.crop i. agro_ecological_zone ///
						i.wave i.country ///
						if sample == 1, alpha(1)
						
    estimates store 	alph1

* elastic net (alpha = 0.5)
	elasticnet linear yield_kg plot_area_GPS seed_kg ///
                        nitrogen_kg total_labor_days ///
                        total_hired_labor_days improved ///
                        used_pesticides organic_fertilizer ///
                        irrigated intercropped ///
                        age_manager female_manager ///
                        formal_education_manager ///
                        plot_slope elevation ///
                        dist_market dist_popcenter ///
                        soil_fertility_index ///
                        crop_shock drought_shock ///
                        i.crop i. agro_ecological_zone ///
						i.wave i.country ///
						if sample == 1, alpha(0.5) ///
						grid(100, ratio(1e-5)) stop(0)
						
    estimates store 	alph5

* ridge (alpha = 0)
	elasticnet linear yield_kg plot_area_GPS seed_kg ///
                        nitrogen_kg total_labor_days ///
                        total_hired_labor_days improved ///
                        used_pesticides organic_fertilizer ///
                        irrigated intercropped ///
                        age_manager female_manager ///
                        formal_education_manager ///
                        plot_slope elevation ///
                        dist_market dist_popcenter ///
                        soil_fertility_index ///
                        crop_shock drought_shock ///
                        i.crop i. agro_ecological_zone ///
						i.wave i.country ///
						if sample == 1, alpha(0)
						
    estimates store 	alph0
	
* inspect and compare selected variables
    lassocoef 			alph1 alph5 alph0, display(coef, standardized)

* compare in-sample and out-of-sample MSE for both models
    lassogof 			alph1 alph5 alph0, over(sample) postselection
	
	
**********************************************************************
**# exercise 4 - Random Forest
**********************************************************************

* make sure the training frame is the active frame
    _h2oframe change train_frame

* fit random forest
    h2oml rfregress yield_kg plot_area_GPS seed_kg ///
                        nitrogen_kg total_labor_days ///
                        total_hired_labor_days improved ///
                        used_pesticides organic_fertilizer ///
                        irrigated intercropped ///
                        age_manager female_manager ///
                        formal_education_manager ///
                        plot_slope elevation ///
                        dist_market dist_popcenter ///
                        soil_fertility_index ///
                        crop_shock drought_shock ///
                        crop agro_ecological_zone ///
                        wave country, ///
                        ntrees(200) maxdepth(10) cv(5)

* set testing frame and report out-of-sample goodness of fit
    h2omlpostestframe test_frame
    h2omlgof

* generate predictions (kept so the loop below works)
    predict         yhat_rf
    gen             sq_err_rf = (yield_kg - yhat_rf)^2
    sum             sq_err_rf if sample == 2

* variable importance plot
	h2omlgraph varimp
	graph export    "$export/15-ml-varimp-rf.png", replace

**## 4.1 - interpretation
	*** report out-of-sample MSE and compare to lasso

**## 4.2 - depth sensitivity
* shallow trees (maxdepth = 3)
    _h2oframe change train_frame
    h2oml rfregress yield_kg plot_area_GPS seed_kg ///
                        nitrogen_kg total_labor_days ///
                        total_hired_labor_days improved ///
                        used_pesticides organic_fertilizer ///
                        irrigated intercropped ///
                        age_manager female_manager ///
                        formal_education_manager ///
                        plot_slope elevation ///
                        dist_market dist_popcenter ///
                        soil_fertility_index ///
                        crop_shock drought_shock ///
                        crop agro_ecological_zone ///
                        wave country, ///
                        ntrees(200) maxdepth(3) cv(5)

    h2omlpostestframe test_frame
    h2omlgof

* deep trees (maxdepth = 20)
    _h2oframe change train_frame
    h2oml rfregress yield_kg plot_area_GPS seed_kg ///
                        nitrogen_kg total_labor_days ///
                        total_hired_labor_days improved ///
                        used_pesticides organic_fertilizer ///
                        irrigated intercropped ///
                        age_manager female_manager ///
                        formal_education_manager ///
                        plot_slope elevation ///
                        dist_market dist_popcenter ///
                        soil_fertility_index ///
                        crop_shock drought_shock ///
                        crop agro_ecological_zone ///
                        wave country, ///
                        ntrees(200) maxdepth(20) cv(5)

    h2omlpostestframe test_frame
    h2omlgof

	*** shallow trees have higher bias (underfit), deep trees
	*** may have slightly higher variance (overfit).
	*** the optimal depth balances bias and variance.


**********************************************************************
**# exercise 5 - Gradient Boosting
**********************************************************************

* make sure the training frame is the active frame
    _h2oframe change train_frame

* fit gradient boosting model
    h2oml gbregress yield_kg plot_area_GPS seed_kg ///
                        nitrogen_kg total_labor_days ///
                        total_hired_labor_days improved ///
                        used_pesticides organic_fertilizer ///
                        irrigated intercropped ///
                        age_manager female_manager ///
                        formal_education_manager ///
                        plot_slope elevation ///
                        dist_market dist_popcenter ///
                        soil_fertility_index ///
                        crop_shock drought_shock ///
                        crop agro_ecological_zone ///
                        wave country, ///
                        ntrees(500) maxdepth(5) ///
                        learnrate(0.05) cv(5)

* set testing frame and report out-of-sample goodness of fit
    h2omlpostestframe test_frame
    h2omlgof

* generate predictions (kept so the loop below works)
    predict         yhat_gbm
    gen             sq_err_gbm = (yield_kg - yhat_gbm)^2
    sum             sq_err_gbm if sample == 2

**## 5.1 - interpretation
	*** report MSE and compare to random forest.
	*** boosting uses shallower trees because complexity
	*** comes from the sequential ensemble, not individual
	*** trees. each tree corrects the errors of the prior
	*** ensemble.

**## 5.2 - learning rate sensitivity
* high learning rate
    _h2oframe change train_frame
    h2oml gbregress yield_kg plot_area_GPS seed_kg ///
                        nitrogen_kg total_labor_days ///
                        total_hired_labor_days improved ///
                        used_pesticides organic_fertilizer ///
                        irrigated intercropped ///
                        age_manager female_manager ///
                        formal_education_manager ///
                        plot_slope elevation ///
                        dist_market dist_popcenter ///
                        soil_fertility_index ///
                        crop_shock drought_shock ///
                        crop agro_ecological_zone ///
                        wave country, ///
                        ntrees(500) maxdepth(5) ///
                        learnrate(0.3) cv(5)

    h2omlpostestframe test_frame
    h2omlgof

    *** a higher learning rate makes each tree contribute more,
    *** which can cause overfitting. smaller learning rates
    *** make finer corrections and often generalize better.

**## 5.3 - deployment
* simulate "new" data where the outcome is unknown
    preserve
    keep in 1/5
    replace yield_kg = .

* use our trained GBM model to forecast the missing yields
    predict future_yield

* view our predictions
    list nitrogen_kg seed_kg plot_area_GPS future_yield
    restore


**********************************************************************
**# exercise 6 - Model Comparison
**********************************************************************

* OLS on training data
	reg             yield_kg plot_area_GPS seed_kg ///
						nitrogen_kg total_labor_days ///
						total_hired_labor_days improved ///
						used_pesticides organic_fertilizer ///
						irrigated intercropped ///
						age_manager female_manager ///
						formal_education_manager ///
						plot_slope elevation ///
						dist_market dist_popcenter ///
						soil_fertility_index ///
						crop_shock drought_shock ///
						i.wave i.admin_1 ///
						if sample == 1
	predict         yhat_ols
	gen             sq_err_ols = (yield_kg - yhat_ols)^2

* collect out-of-sample MSE for each model
	matrix          compare = J(5, 2, .)
	matrix rownames compare = OLS Lasso ElasticNet RF GBM
	matrix colnames compare = MSE RMSE

	local           row = 1
	foreach model in ols lasso enet rf gbm {
		sum         sq_err_`model' if sample == 2
		matrix      compare[`row', 1] = r(mean)
		matrix      compare[`row', 2] = sqrt(r(mean))
		local       ++row
	}
	matrix list     compare, format(%12.1f)

* create dataset from matrix for export
	preserve
	clear
	svmat           compare
	gen             model = ""
	replace         model = "OLS" in 1
	replace         model = "Lasso" in 2
	replace         model = "Elastic Net" in 3
	replace         model = "Random Forest" in 4
	replace         model = "Gradient Boosting" in 5
	order           model
	rename          (compare1 compare2) (mse rmse)
	export delimited "$export/15-ml-compare.csv", replace

* create bar chart
	gen             id = _n
	twoway          (bar mse id, ///
						barwidth(0.7) color(navy%70)), ///
						xlabel(1 "OLS" 2 "Lasso" 3 "E-Net" ///
							4 "RF" 5 "GBM", angle(0)) ///
						ytitle("Out-of-Sample MSE") ///
						xtitle("") ///
						graphregion(color(white))
	graph export    "$export/15-ml-compare.png", replace
	restore

**## 6.1 - interpretation
	*** rank models from best to worst based on out-of-sample MSE.
	*** tree-based methods (RF, GBM) typically outperform linear
	*** methods when there are nonlinearities and interactions.


**********************************************************************
**# exercise 7 - SHAP and Variable Importance
**********************************************************************

* re-estimate GBM (to ensure it is the active h2oml model)
	h2oml gbregress yield_kg plot_area_GPS seed_kg ///
						nitrogen_kg total_labor_days ///
						total_hired_labor_days improved ///
						used_pesticides organic_fertilizer ///
						irrigated intercropped ///
						age_manager female_manager ///
						formal_education_manager ///
						plot_slope elevation ///
						dist_market dist_popcenter ///
						soil_fertility_index ///
						crop_shock drought_shock ///
						wave admin_1 ///
						if sample == 1, ///
						ntrees(500) maxdepth(5) ///
						learnrate(0.05) cv(5)

* SHAP summary plot
	h2omlgraph shapsummary
	graph export    "$export/15-ml-shap.png", replace

* partial dependence plots for top predictors
	h2omlgraph pdp nitrogen_kg
	graph export    "$export/15-ml-pdp-nitrogen.png", replace

	h2omlgraph pdp seed_kg
	graph export    "$export/15-ml-pdp-seed.png", replace

* variable importance for GBM
	h2omlgraph varimp
	graph export    "$export/15-ml-varimp-gbm.png", replace

**## 7.1 - interpretation
	*** describe the relationship between variable values and
	*** SHAP values for the top three variables

**## 7.2 - interpretation
	*** discuss any nonlinear relationships revealed by PDPs

**## 7.3 - interpretation
	*** compare GBM variable importance to lasso selection

**## 7.4 - interpretation
	*** high variable importance does not imply causation.
	*** predictive importance means the variable helps
	*** forecast the outcome, but the relationship may be
	*** driven by confounders. causal claims require the
	*** tools from weeks 8-14 (FE, DiD, IV, RDD).


**********************************************************************
**# challenge 15 - Full ML Workflow
**********************************************************************

**## part 1 - new prediction target

* lasso to predict harvest value
	lasso linear    harvest_value_USD plot_area_GPS seed_kg ///
						nitrogen_kg total_labor_days ///
						total_hired_labor_days improved ///
						used_pesticides organic_fertilizer ///
						irrigated intercropped ///
						nb_seasonal_crop ///
						age_manager female_manager ///
						formal_education_manager ///
						plot_slope elevation ///
						dist_market dist_popcenter ///
						soil_fertility_index ///
						crop_shock drought_shock ///
						i.wave i.admin_1 ///
						if sample == 1
	predict         yhat_val_lasso
	gen             sq_err_val_lasso = ///
						(harvest_value_USD - yhat_val_lasso)^2
	sum             sq_err_val_lasso if sample == 2

* GBM to predict harvest value
	h2oml gbregress harvest_value_USD plot_area_GPS seed_kg ///
						nitrogen_kg total_labor_days ///
						total_hired_labor_days improved ///
						used_pesticides organic_fertilizer ///
						irrigated intercropped ///
						nb_seasonal_crop ///
						age_manager female_manager ///
						formal_education_manager ///
						plot_slope elevation ///
						dist_market dist_popcenter ///
						soil_fertility_index ///
						crop_shock drought_shock ///
						wave admin_1 ///
						if sample == 1, ///
						ntrees(500) maxdepth(5) ///
						learnrate(0.05) cv(5)
	predict         yhat_val_gbm
	gen             sq_err_val_gbm = ///
						(harvest_value_USD - yhat_val_gbm)^2
	sum             sq_err_val_gbm if sample == 2

**## part 2 - comparison table

* collect MSE results
	matrix          chal = J(2, 2, .)
	matrix rownames chal = Lasso GBM
	matrix colnames chal = MSE RMSE

	sum             sq_err_val_lasso if sample == 2
	matrix          chal[1, 1] = r(mean)
	matrix          chal[1, 2] = sqrt(r(mean))

	sum             sq_err_val_gbm if sample == 2
	matrix          chal[2, 1] = r(mean)
	matrix          chal[2, 2] = sqrt(r(mean))

	matrix list     chal, format(%12.4f)

**## part 3 - interpretation

* SHAP summary plot for harvest value GBM
	h2omlgraph shapsummary
	graph export    "$export/15-challenge-shap.png", replace

**## part 4 - reflection
	*** 1. report which model predicts harvest value better
	*** 2. discuss which variables are important for predicting
	***    harvest value and whether they would be bad controls
	***    in a causal regression
	*** 3. discuss whether a single ML model trained on all
	***    seven countries predicts well for each individual
	***    country
	*** 4. a trained ML model could identify low-harvest-value
	***    households for cash transfer targeting, using only
	***    observable plot characteristics and input use


**********************************************************************
**# 8 - end matter
**********************************************************************

* shut down H2O
	h2o shutdown

* close log
	cap             log close

/* end */
