---
layout: exercise
topic: Tidy Data
title: Label Values
language: Stata
---

Using the World Bank's LSMS data, 

1\. Define a value label set called `yesno` where `0 = No` and `1 = Yes`

2\. Assign the value label set `yesno` to the following variables:
   * `hh_shock`
   * `hh_primary_education`
   * `hh_electricity_access`
   * `hh_formal_education`
   * `nonfarm_enterprise`

Defining value labels when there are just a couple options (yes/no, male/female) is fairly straightforward, especially when variables are already binary (0/1). But sometimes a variable already exists that has the information we want, just not in the form we want. In that case, we can create a new, intermediate variable, whose values are based on the existing variable. This allows us to change one form of data (strings) into another form (numeric) and then apply labels. 

3\. Create a variable called `sector` that equals 0 if `urban = Rural` and equals 1 if `urban = Urban`. 
   * Label that variable "EA is rural or urban"
   * Define a value label set called `sec_lbl` where `0 = Rural` and `1 = Urban`
   * Assign the value label set `sec_lbl` to the variable `sector`
   * Drop `urban` and place `sector` after `eaid`

Defining value labels in this way when there are a lot of options can become very tedious very quickly. Luckily, Stata has a decode/encode command that can sometimes creatly reduce the amount of coding you have to do to define and assign a label.

You will often have a variable which is a string that you would like to convert to a numeric. As an example, you can think of a variable called `state` that takes values of the name of each state in the U.S. In order to use this information in a regression, we need to convert the string to a numeric, like we did with `sector`. But with 50 state names, it will take a long time to 1) create a new variable that takes a unique numerical value for each state name and 2) define a label set for every value.

In this case, we can use `encode` to change the strings to numerical values and then use the string text as a value label for each numerical value. The syntax for the command is:

```stata
 encode varname, gen(newvar)
 ```
 where `varname` is the name of the existing string variable and `newvar` is the new, numerical variable you want to create.

4\. Encode the variable `country` so that it is a numerical variable and uses the string values as labels.

   * Call the new variable you create `Country`
   * Drop the old variable `country`
   * Rename `Country` as `country`
   * Use the command `order` to place `country` as the first variable in the data set (use `help order` if you need help with the `order` command)

5\. Encode the variable `admin_1` so that it is a numerical variable and uses the string values as labels. Follow the same steps as in 4.3 and use `order` to place the new `admin_1` immediately in front of `admin_2`.