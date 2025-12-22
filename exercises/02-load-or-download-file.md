---
layout: exercise
topic: Data Management
title: Load or Download File
language: Stata
---

There are a number of different ways to get data into Stata. And Stata can handle a number of different file formats. The way to load data into Stata requires answering several different questions.
1. Is the data remote (in the cloud) or local (on your machine)?
2. If the data is local, what is its location relative to your working directory?
3. What is the file format of the data?
Knowing the answer to these questions will tell you which of the many ways you will want to load data into Stata.

1. Stata has a number of different example data sets that you can download from online. Download `cancer.dta` using the `sysuse` command. Then `describe` the data.

2. You can also load data into Stata directly from a website. If the data is in Stata's `.dta` format, you can use the standard Stata commands for loading data, just give it the absolute pathway to the location of the data on the internet. Install data from `https://haghish.github.io/github/langlist.dta` and then `describe` the data.
