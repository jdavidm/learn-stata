---
layout: exercise
topic: LaTeX
title: LaTeX Formatting and Math
language: Stata
---

In your `lastname.tex` file in the `semester26` Overleaf project, under `\section*{Assignment 10}`, write the following using proper LaTeX formatting. You do not need to run any Stata code for this exercise.

1\. Write a short paragraph (2–3 sentences) explaining what omitted variable bias is. Bold the term "omitted variable bias" and italicize the word "biased."

2\. Write the OLS regression equation in display math (using `\begin{equation}` ... `\end{equation}`):

$$Y_i = \beta_0 + \beta_1 X_i + \varepsilon_i$$

Use `\beta`, subscripts (`_`), and `\varepsilon`.

3\. Write the formula for the OLS estimator of $\hat{\beta}_1$ as a displayed equation:

$$\hat{\beta}_1 = \frac{\sum_{i=1}^{n}(X_i - \bar{X})(Y_i - \bar{Y})}{\sum_{i=1}^{n}(X_i - \bar{X})^2}$$

Use `\hat{}`, `\bar{}`, `\frac{}{}`, `\sum_{i=1}^{n}`, and superscripts (`^`).

4\. Write the formula for the standard error of the regression as a displayed equation:

$$SE(\hat{\beta}) = \sqrt{\frac{1}{n} \sum_{i=1}^{n} (X_i - \bar{X})^2}$$

Use `\sqrt{}`, `\frac{}{}`, `\sum_{i=1}^{n}`, `\bar{}`, and `\hat{}`.

---
