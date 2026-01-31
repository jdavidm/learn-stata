---
layout: exercise
topic: Graphing
title: Histograms
language: Stata
---

Using the `nlsw88` data,

1\. Draw a histogram of hours worked per week, with the **percent of workers** on the y-axis.

2\. Draw a histogram of `hours` with 10 bins.

3\. Draw a histogram of `hours` controlling the bin width directly starting the first bin at 0 and having bins of width 5.

The variable `grade` records completed years of education and takes on **integer** values, meaning it is a discrete variable. In this case, Stata will make better looking historgrams if you tell Stata that the variable is discrete.

Start by graphing `grade` using just the `hist` command.

4\. Draw a histogram of `grade` using the `discrete` option along with frequency.

---
