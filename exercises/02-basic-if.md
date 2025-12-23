---
layout: exercise
topic: Expressions & Variables
title: Basic If Statements
language: Stata
---

1\. Create a variable `y` that equals "1" if `price` is less than or equal to "4195". How many cars have a price less than "4195"?

2\. Replace the value of `y` with a "3" if `price` is greater than or equal to "6342". How many cars have a price greater than "6342"?

3\. Replace the value of `y` with a "2" if `price` is greater than "4195" and less than "6342". How many cars have a price between "4195" and "6342"?
3\. Complete the following `if` statement so that if `age_class` is equal to
   "sapling" it sets `y <- 10` and if `age_class` is equal to "seedling" it
   sets `y <- 5` and if `age_class` is something else then it sets the value of
   `y <- 0`.

```r
age_class = "adult"
if (){
  
}
y
```

4\. Convert your `if`/`else if`/ `else` statement from (3) into a function that takes
   `age_class` as an argument and returns `y`. Call this function 5 times, once
   with each of the following values for `age_class`: "sapling", "seedling",
   "adult", "mature", "established".
