---
layout: exercise
topic: Style & Execution
title: Code Shuffle
language: Stata
---

We are interested in understanding the monthly variation in precipitation near Gainesville, FL, so that we can understand the correlation between rainfall and citrus yield. We'll use some data from the [NOAA National Climatic Data Center](http://www.ncdc.noaa.gov/). Each row of the data is a year (from 1961-2013) and each column is a month (January - December).

Rearrange the following program so that it:

- Imports the data from the web into a data frame
- Creates a variable called `year` which tracks how many years it has been since 1960
- Calculates the mean precipitation in each month across years
- Plots the monthly averages as a simple line plot

Finally, add comments above each code bloack that describes what it does.

It's OK if you don't know exactly how the details of the program work at this point, you just need to figure out the right order of the lines based on when variables are defined and when they are used.

```stata
    egen		mean_rain = rowmean(v*)
	twoway		(line mean_rain year)
	gen			year = _n
    import		delimited "https://datacarpentry.org/semester-biology/data/gainesville-precip.csv", clear
```

---
