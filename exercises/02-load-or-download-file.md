---
layout: exercise
topic: Data Management
title: Load or Download File
language: Stata
---

There are a number of different ways to get data into Stata. And Stata can handle a number of different file formats. The way to load data into Stata requires answering several different questions.

* Is the data remote (in the cloud) or local (on your machine)?
* If the data is local, what is its location relative to your working directory?
* What is the file format of the data?

Knowing the answer to these questions will tell you which of the many ways you will want to load data into Stata.

1. You can load data into Stata directly from a website. If the data is in Stata's `.dta` format, you can use the standard Stata commands for loading data, just give it the absolute pathway to the location of the data on the internet. Install data from `https://haghish.github.io/github/langlist.dta` and then `describe` the data.

2. You can also download data to your machine, placing it in a specific folder, and then use the absolute path to load the data useing `use`. Download the file [`tenuredata.dta`]({{ site.baseurl }}/data/tenuredata.dta). Take care to note where you save this file. Then load the data into stata and `describe` the data.

3. Stata has a number of different example data sets that get download to your machine when you install Stata. Stata knows where these files are so one does not need to provide an aboslute or relative path when loading them. Load `cancer.dta` using the `sysuse` command. Then `describe` the data.

4. Stata can also input almost any type of data file and convert it to a `.dta` format. To do this, you use a compound command that starts with `import` and is followed by the format of the file. Type in `help import` to get a list of all the different types of files Stata can import. Download the file [`district_size.csv`]({{ site.baseurl }}/data/district_size.csv). Again, take care to note where you saved the file. Then use `help` to find the Stata command to import a comma-separated (the `cs` in `.csv`) file. Describe the data.

---
