---
layout: page
element: notes
title: ML Setup and Prediction
language: Stata
---

For fourteen weeks we have built a causal-inference toolkit: fixed effects, difference-in-differences, instrumental variables, regression discontinuity. Every one of those tools is designed to answer a *why* question — does X cause Y? This week we shift to a fundamentally different question: **can we predict Y well?**

Prediction problems are everywhere in applied economics. Which households are most likely to fall into poverty? Where should a government target an agricultural extension program? Which loan applicants will default? In each case, the goal is not to estimate a causal effect but to make an accurate forecast using whatever variables are available — even variables that would be "bad controls" in a causal model.

Machine learning (ML) gives us a family of algorithms designed to maximize prediction accuracy while guarding against **overfitting** — the tendency of a model to memorize the training data at the expense of performance on new data. This lecture introduces the core ideas of ML and how to use ML tools in Stata.

This lecture covers:
- When prediction (rather than causal inference) is the right goal
- The bias-variance tradeoff and overfitting
- Train/test splits and cross-validation
- Setting up H2O in Stata for advanced ML algorithms

We will use `eth_allrounds_final.dta` — the Ethiopia maize panel data from Weeks 11–13 — as our running example in the lecture. The task: **predict maize yield** (`yield_kg`) using household, plot, and weather variables. You already know this data, so we can focus on the new methods rather than explaining and exploring the data.

### Prediction vs. causal inference

In causal inference (Weeks 8–14), we care about isolating the effect of one specific variable. We worry about omitted variable bias, exclusion restrictions, and parallel trends. We deliberately *exclude* variables that could be "bad controls" (post-treatment variables, mediators, colliders).

In prediction, **none of that matters**. We want the best possible forecast of the outcome, so we throw in every variable that helps — including variables we would never use in a causal model. A variable that is endogenous, post-treatment, or even a mediator can still be a useful predictor.

This distinction matters for how economists use ML in practice:

| | Causal inference | Prediction |
|---|---|---|
| **Goal** | Estimate the effect of X on Y | Forecast Y as accurately as possible |
| **Variable selection** | Guided by theory and DAGs | Guided by predictive power |
| **Overfitting** | Less concern (fixed sample) | Central concern |
| **Standard errors** | Essential | Often secondary |

When is prediction the right goal? Examples from economics:
- **Targeting**: Which farmers should receive subsidized fertilizer? (Predict who benefits most.)
- **Nowcasting**: What is GDP this quarter before official statistics arrive?
- **Risk scoring**: Which microfinance borrowers will default?
- **Prediction policy problems** ([Kleinberg et al., 2015](https://doi.org/10.1257/aer.p20151023)): When should a judge release a defendant before trial? The policy question is fundamentally about predicting future behavior, not estimating a causal effect.

### The bias-variance tradeoff

The central tension in ML is the **bias-variance tradeoff**. A model can fail in two ways:

1. **High bias (underfitting)**: The model is too simple to capture the true relationship. A linear model fit to a nonlinear relationship will systematically miss the pattern, making large errors on both training and test data.

2. **High variance (overfitting)**: The model is too complex — it memorizes the noise in the training data. It fits the training data perfectly but makes poor predictions on new data because it learned idiosyncratic patterns that don't generalize.

The optimal model balances these two sources of error. We want a model complex enough to capture the real signal but simple enough to ignore the noise. Every ML method we study this week is, at its core, a different way of navigating this tradeoff.

How do we know if we're overfitting? We need to evaluate our model on data it has never seen. This brings us to train/test splits.

### Train/test splits and cross-validation

#### The holdout approach

The simplest strategy: randomly split the data into a **training set** (used to fit the model) and a **test set** (used to evaluate it). A common split is 70% training, 30% test. We fit the model on the training set, predict on the test set, and evaluate using a metric like **Mean Squared Error (MSE)**:

$$MSE = \frac{1}{n_{test}} \sum_{i \in test} (y_i - \hat{y}_i)^2$$

A model that overfits will have low MSE on the training set but high MSE on the test set. A model that generalizes well will have similar MSE on both.

Stata provides the `splitsample` command for creating reproducible random splits:

```stata
* split data: 70% training (sample==1), 30% testing (sample==2)
    splitsample,     generate(sample) split(0.70 0.30) rseed(8675309)
    
* label the values of sample
    lab def           svalues 1 "Training" 2 "Testing"
    lab val           sample svalues
```

`splitsample` randomly assigns each observation to a group — here, group 1 (training) or group 2 (testing) — based on the specified proportions. Setting `rseed()` ensures the split is reproducible. When we fit models, we restrict to the training set with `if sample == 1`; when we evaluate, we use `over(sample)` to see performance on both groups simultaneously.

#### k-fold cross-validation

The holdout approach wastes data — 30% of our observations are never used for training. **k-fold cross-validation** is more efficient:

1. Split the data into k equal folds (typically k = 5 or 10).
2. For each fold: use k-1 folds for training, predict on the held-out fold.
3. Average the MSE across all k folds.

This uses all the data for both training and evaluation. Stata's `lasso` and `elasticnet` commands use cross-validation internally to choose their tuning parameters. H2O's ML algorithms also support k-fold CV through the `cv()` option.

### Setting up H2O in Stata

Stata 19 introduced deep integration with [H2O](https://h2o.ai/), an open-source ML platform. H2O runs as a separate Java process — Stata sends data to H2O, H2O fits the model, and Stata retrieves the results. This architecture lets us use powerful ML algorithms (random forest, gradient boosting) that are not natively available in Stata.

> [!IMPORTANT]
> H2O requires **Stata 19** and a **Java Runtime Environment (JRE)** installed on your machine. If you have not already installed Java, follow the instructions on the [Computer Setup]({{ site.baseurl }}/computer-setup/) page. If you encounter errors when initializing H2O, consult Stata's documentation on H2O setup or the [StataCorp YouTube video on H2O setup](https://www.youtube.com/watch?v=Y1aPrScIdtg).

The H2O workflow in Stata has four steps:

```stata
* 1. start the H2O cluster (launches a Java process)
    h2o init

* 2. push your training and testing datasets to separate H2O frames
    _h2oframe put if sample == 1, into(train_frame) current
    _h2oframe put if sample == 2, into(test_frame)

* 3. (do your ML work here — random forest, GBM, etc.)

* 4. to free up memory, you can remove frames you no longer need
    _h2oframe remove framename

* 5. when finished, disconnect from the H2O cluster and shut it down
    h2o disconnect
    h2o shutdown
```

`h2o init` starts a local H2O server. `_h2oframe put` transfers the data to H2O's memory (as "H2O frames"). We push the training and testing sets separately so we can evaluate out-of-sample performance later. You can free up memory on the cluster by dropping specific frames with `_h2oframe remove`. After fitting models, `h2o disconnect` disconnects from the H2O cluster and `h2o shutdown` closes the H2O process and frees all memory.

For this week we will use H2O only for random forest and gradient boosting (Lecture 3). Lasso and elastic net use Stata's native commands and do not require H2O.

> Do [Exercise 1 - Setup and Train/Test Split]({{ site.baseurl }}/exercises/15-ml-split/)
