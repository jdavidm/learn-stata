---
layout: exercise
topic: Data Management
title: Append Data
language: Stata
---

Using the World Bank's LSMS data, we are going to simulate the common case where survey data arrive as separate files by wave. In fact, this is how the LSMS data comes, I've just given you a data set in which all the waves and all the countries have already been appended into a single data set. You will create wave-specific datasets and then append them.

Start by re-loading the household data (`household_all.dta`). Create a data set that contains only observations from wave 1 using the `keep if` command. Save this file as `hh_wave1.dta`.

1\. How many observations came from a wave that is **NOT** wave 1?

Now, re-open the full dataset and keep only wave 2 observations and save this as `hh_wave2.dta`.

2\. How many observations came from a wave that is **NOT** wave 2?

 Finally, append the data set that contains just wave 1 to the data set that contains just wave 2 using `append`.

 3\. How many observations are in the combined wave 1 and wave 2 data set?