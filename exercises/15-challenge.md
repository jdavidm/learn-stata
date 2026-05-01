---
layout: exercise
topic: Machine Learning
title: Challenge 15
language: Stata
---

#### Part 1 — Model Comparison

Now that you have fit lasso, elastic net, random forest, and gradient boosting on `plot_dataset.dta`, it is time to compare them. Which algorithm is best suited for this specific data generating process?

- Create a matrix to collect the results and loop over the models to compute MSE and RMSE:

```stata
* collect results
    matrix          compare = J(4, 2, .)
    matrix rownames compare = Lasso ElasticNet RF GBM
    matrix colnames compare = MSE RMSE

    local           row = 1
    foreach model in lasso enet rf gbm {
        gen         sq_err_`model' = (yield_kg - yhat_`model')^2
        sum         sq_err_`model' if sample == 2
        matrix      compare[`row', 1] = r(mean)
        matrix      compare[`row', 2] = sqrt(r(mean))
        local       ++row
    }
    matrix list     compare, format(%12.1f)
```

1\. Export a LaTeX table of the results for your Overleaf document:

```stata
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
```

2\. Rank the four models from best (lowest MSE) to worst. Which model wins? By how much does it improve over the second-best model?

#### Part 2 — Deployment

The dataset `plot_dataset.dta` has 257,154 observations, but only 228,448 observations actually have data on `yield_kg`. The remaining 28,706 observations have missing yield data! The goal of this part is to use the winning machine learning model to predict what the harvest would have been for those plots.

- Make sure your best-performing model is the active model in memory (if it's an H2O model, make sure `train_frame` is active and you've re-estimated it if necessary).
- Generate predictions for the *entire* dataset using `predict`.
- Replace the missing `yield_kg` values with the predicted values.

3\. How many missing `yield_kg` observations did your model successfully impute? Use `count if yield_kg == .` before and after to verify.

4\. Think about the economic implications of what you just did. If you were an agricultural researcher or policymaker, what is one major advantage of using machine learning to impute missing harvest data rather than just dropping those observations from your analysis?

---
