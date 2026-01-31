---
layout: exercise
topic: Data Analysis
title: Data Basics
language: Stata
---

To get a sense of how to work with data and the types of data that Stata handles, we will look at a data set on life expectancy in 68 countries:

If the file [`lifeexp.dta`]({{ site.baseurl }}/data/lifeexp.dta) is not already in your course folder then download it into your course folder.

Get familiar with the data by importing it using `use` then complete the following tasks. One thing to remember is that in Stata creating a variable requires one equal sign (`=`) while using logic expressions, like `[if exp]` requires two equal signs (`==`).

1. Describe the data (using `describe`). Which variable has a value label?
2. Calculate the mean life expectancy (using `sum` for summarize). What is the mean and standard deviation of life expectancy?
3. Calculate the median life expectancy (using the `detail` option to `sum`). What is median life expectancy?
4. Sort the data by country (using `sort`). Alphabetically, what is the first and last country in the data set?
5. List the regions in the data set (using `tab` for tabulate). How many regions are there?
6. Stata can label data (recall the region label). This means when you look at the data you see the label, but the label actually applies to a number. List the regions by their number (using the `nolab` option to `tab`). What number is assigned the label South America?
7. Calculate the mean life expectancy by region (using the prefix `bys` for bysort to the `sum` command). What is mean life expectancy in Europe and Central Asia?
8. Filter the data to calculate median population growth for North America (using the `if [exp]` conditional on `sum`). What is median population growth in the region?
9. Remove rows with null values of safewater (using `drop if`). How many observations were dropped?
10. Create a new data file called `lifeexp_no-sw` for no safewater (using `save`). What is the size in KB of this new file (look under data in the Properties Window)?

---
