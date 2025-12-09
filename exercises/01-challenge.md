---
layout: exercise
topic: Expressions and Variables
title: Challenge 1
language: Stata
---

Sticking with the National Longitudinal Surveys, Women sample, 1988, we are going to graph some of the relationships we just explored numerically.

1. Create a scatterplot in which `hours` is on the x-axis and `wage` is on the y-axis. Save the graph as a `.png` file (using `graph save`).

Stata's default graphics scheme is pretty ugly. A number of users have developed their own, much more attractive, schemes. This also gives us a chance to load in user written packages. Stata maintains a repository of user written pacakges that can be installed within Stata from the internet. The one we are going to install is `blindschemes`. Then we will set that package's graphic scheme as the default for our system.

```stata
ssc install blindschemes
set scheme plotplain, perm
```
2. Create a scatterplot in which `tenure` is on the x-axis and `wage` is on the y-axis. Save the graph as a `.png` file.

3. Add a line of best fit to the scatterplot using `lfit`. Use the command `help twoway` to open the help file. Scroll down to Definition and look for an example of putting two different types of graphs in the same region. Save the graph as a `.png`.
