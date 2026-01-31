---
layout: exercise
topic: Expressions and Variables
title: Modify the Code
language: Stata
---

The following code explores wages and correlates using the National Longitudinal Surveys, Women sample, 1988. We will explore relationship in the entire data and then modify the code to explore differences in these relationships by union membership and college graduate.

```stata
    sysuse                  nlsw88.dta, clear
    sum                     wage hours
    tab                     married race, row
    bys married race:       sum wage hours           
```

Copy this code into your assignment and then add additional lines of code to calculate the following for union/non-union members and college grads/non-college grads:

1.  Mean wage and hours (use `bys` and `sum`)
    1. For union members
    3. For non-union members
    2. For college grads
    4. For non-college grads
2.  The percentage of Blacks who are (use `tab`)
    1. Union member
    3. Non-union members
    2. College grads
    4. Non-college gradss
3.  Mean wage and hours of 
    1. Union members who are college grads
    2. Union members who are non-college grads
    3. Non-union members who are college grads
    4. Non-union members who are non-college grads

---
