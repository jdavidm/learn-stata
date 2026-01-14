---
layout: exercise
topic: Data Management
title: Create Variables
language: Stata
---

Using the World Bank's LSMS data, 

1. Create a variable called `sector` that equals 0 if `urban = Rural` and equals 1 if `urban = Urban`
2. Label that variable "EA is rural or urban"
3. Define a value label set called `sec_lbl` where `0 = Rural` and `1 = Urban`
4. Assign the value label set `sec_lbl` to the variable `sector`