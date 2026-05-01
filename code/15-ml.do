* course: 597a
* assignment: 15
* created on: 24 apr 26
* created by: jdm
* edited on: 1 may 26
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

**## 1.1 - report split
    *** report the number of training and test observations
    count if        sample == 1
    count if        sample == 2

	
**********************************************************************
**# exercise 2 - Lasso for Prediction
**********************************************************************

global inputs   seed_kg nitrogen_kg total_labor_days ///
                    total_hired_labor_days improved ///
                    used_pesticides organic_fertilizer ///
                    irrigated intercropped ///
                    age_manager female_manager ///
                    formal_education_manager ///
                    plot_slope elevation ///
                    dist_market dist_popcenter ///
                    soil_fertility_index ///
                    crop_shock drought_shock ///
                    i.crop i.agro_ecological_zone ///
                    i.wave i.country

* fit lasso on training data
    lasso linear    yield_kg $inputs ///
                        if sample == 1
    estimates store cv

* fit adaptive lasso on training data
    lasso linear    yield_kg $inputs ///
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

* generate predictions for final comparison (using standard lasso)
    estimates restore cv
    predict         yhat_lasso

* report goodness of fit out-of-sample
    lassogof cv adpt, over(sample) postselection


**********************************************************************
**# exercise 3 - Elastic Net and Ridge
**********************************************************************

* lasso via elasticnet (alpha = 1)
	elasticnet linear yield_kg $inputs ///
						if sample == 1, alpha(1)
						
    estimates store 	alph1

* elastic net (alpha = 0.5)
	elasticnet linear yield_kg $inputs ///
						if sample == 1, alpha(0.5) ///
						grid(100, ratio(1e-5)) stop(0)
						
    estimates store 	alph5

* ridge (alpha = 0)
	elasticnet linear yield_kg $inputs ///
						if sample == 1, alpha(0)
						
    estimates store 	alph0
	
* inspect and compare selected variables
    lassocoef 			alph1 alph5 alph0, display(coef, standardized)

* compare in-sample and out-of-sample MSE for both models
    lassogof 			alph1 alph5 alph0, over(sample) postselection
	
* generate predictions for final comparison (using alpha = 0.5)
    estimates restore alph5
    predict         yhat_enet
	
	
**********************************************************************
**# exercise 4 - Random Forest
**********************************************************************

* initialize H2O cluster
    h2o init

* push training and testing data to separate H2O frames
    _h2oframe put if sample == 1, into(train_frame) current
    _h2oframe put if sample == 2, into(test_frame)
	
* strip i. prefixes for H2O commands
    local h2o_inputs = subinstr("$inputs", "i.", "", .)

* fit random forest
    h2oml rfregress yield_kg `h2o_inputs', ///
                        ntrees(200) maxdepth(10) cv(5)

* set testing frame and report out-of-sample goodness of fit
    h2omlpostestframe test_frame
    h2omlgof

* generate predictions (kept so the final loop works)
     cap noisily h2omlpredict       yhat_rf

* variable importance plot
	h2omlgraph varimp
	graph export    "$answ/15-rf-1.png", replace

**## 4.1 - interpretation
	*** report out-of-sample MSE and compare to lasso

**## 4.2 - depth sensitivity
* shallow trees (maxdepth = 3)
    _h2oframe change train_frame
* strip i. prefixes for H2O commands
    local h2o_inputs = subinstr("$inputs", "i.", "", .)

    h2oml rfregress yield_kg `h2o_inputs', ///
                        ntrees(200) maxdepth(3) cv(5)

    h2omlpostestframe test_frame
    h2omlgof

* deep trees (maxdepth = 20)
    _h2oframe change train_frame
* strip i. prefixes for H2O commands
    local h2o_inputs = subinstr("$inputs", "i.", "", .)

    h2oml rfregress yield_kg `h2o_inputs', ///
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

* strip i. prefixes for H2O commands
    local h2o_inputs = subinstr("$inputs", "i.", "", .)

* fit gradient boosting model
    h2oml gbregress yield_kg `h2o_inputs', ///
                        ntrees(500) maxdepth(5) ///
                        lrate(0.05) cv(5)

* set testing frame and report out-of-sample goodness of fit
    h2omlpostestframe test_frame
    h2omlgof

* generate predictions (kept so the final loop works)
	cap noisily h2omlpredict       yhat_gbm

**## 5.1 - interpretation
	*** report MSE and compare to random forest.
	*** boosting uses shallower trees because complexity
	*** comes from the sequential ensemble, not individual
	*** trees. each tree corrects the errors of the prior
	*** ensemble.

**## 5.2 - learning rate sensitivity
* high learning rate
    _h2oframe change train_frame
* strip i. prefixes for H2O commands
    local h2o_inputs = subinstr("$inputs", "i.", "", .)

    h2oml gbregress yield_kg `h2o_inputs', ///
                        ntrees(500) maxdepth(5) ///
                        lrate(0.3) cv(5)

    h2omlpostestframe test_frame
    h2omlgof

    *** a higher learning rate makes each tree contribute more,
    *** which can cause overfitting. smaller learning rates
    *** make finer corrections and often generalize better.


**********************************************************************
**# exercise 6 - SHAP and Variable Importance
**********************************************************************

* make sure the training frame is the active frame
    _h2oframe change train_frame

* generate variable importance plot
    h2omlgraph varimp
    graph export    "$answ/15-ml-shap-1.png", replace

* generate partial dependence plots for the two most important predictors
* (assuming nitrogen_kg and seed_kg for this example)
    h2omlgraph pdp crop
    graph export    "$answ/15-ml-shap-2.png", replace

    h2omlgraph pdp dist_popcenter
    graph export    "$answ/15-ml-shap-3.png", replace

* generate SHAP summary plot
    h2omlgraph shapsummary
    graph export    "$answ/15-ml-shap-4.png", replace

**## 6.1 - interpretation
    *** Example interpretation of the SHAP summary plot:
    *** Higher nitrogen application (red) is associated with positive
    *** SHAP values, meaning it pushes yield predictions upward.


**********************************************************************
**# Challenge 15 - Model Comparison and Deployment
**********************************************************************

**## part 1 - model comparison

    clear
    _h2oframe get      test_frame
	
* collect out-of-sample MSE for each model
    matrix          compare = J(4, 2, .)
    matrix rownames compare = Lasso ElasticNet RF GBM
    matrix colnames compare = MSE RMSE

    local           row = 1
    foreach model in lasso enet rf gbm {
        gen         sq_err_`model' = (yield_kg - yhat_`model')^2
        sum         sq_err_`model' if sample == "Testing"
        matrix      compare[`row', 1] = r(mean)
        matrix      compare[`row', 2] = sqrt(r(mean))
        local       ++row
    }
    matrix list     compare, format(%12.1f)

* export results to latex
    esttab          matrix(compare) using "$answ/15-ml-compare.tex", replace ///
                        nomtitles noobs booktabs ///
                        collabels("MSE" "RMSE") ///
                        fragment label ///
                        prehead("\begin{tabular}{l*{2}{c}} " ///
                            "\\[-1.8ex]\hline \hline \\[-1.8ex] " ///
                            "& \multicolumn{2}{c}{Out-of-Sample Prediction Error} " ///
                            "\\ \midrule") ///
                        postfoot("\hline \hline \\[-1.8ex] " ///
                            "\multicolumn{3}{p{\linewidth}}{\small " ///
                            "\noindent \textit{Note}: MSE is Mean Squared Error. " ///
                            "RMSE is Root Mean Squared Error. Models evaluated " ///
                            "on the 20 percent testing sample.} " ///
                            "\end{tabular}")


**## part 2 - deployment

* assuming your best model is GBM and it is currently active
* push the full dataset to H2O to get predictions for everyone
    _h2oframe put, into(full_data)
    _h2oframe change full_data

* generate predictions for all observations
    predict         future_yield

    clear
    _h2oframe get      test_frame
	
* check how many are missing before
    count if        yield_kg == .
	sum				yield_kg
	
* impute missing yields
    replace         yield_kg = future_yield if yield_kg == .

* check how many are missing after
    count if        yield_kg == .
	sum				yield_kg

**## part 3 - reflection
    *** discuss the economic implications of using machine learning
    *** to impute missing harvest data rather than dropping
    *** observations with missing yield data.


**********************************************************************
**# 8 - end matter
**********************************************************************

* shut down H2O
    _h2oframe remove train_frame
    _h2oframe remove test_frame
    h2o shutdown, force

* close log
    cap             log close

/* end */
