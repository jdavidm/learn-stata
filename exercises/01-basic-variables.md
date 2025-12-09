---
layout: exercise
topic: Expressions and Variables
title: Basic Variables
language: Stata
---

Here is a small program that converts a price in U.S. dollars to a price in Euros and then prints out the resulting value.

```stata
    gen         p_usd = 2.62
    gen         p_euro = p_usd * 0.86
    display     p_euro
```
Create similar code to calculate the exchange rate between Euros and British Pounds.
* Start by creating an "empty" data set by typing `set obs 1`. This creates a single row in Stata's data frame. 
* Create a variable to store a price in Euros. Assign this variable a value of 5.87 [(the price of a BigMac](https://www.visualcapitalist.com/mapped-the-price-of-a-big-mac-across-the-world/)).
* Create a variable to store a price in Pounds. Assign this variable a value of 5.09.
* Calculate and print the exchange rate (the value of 1 Euro in GBP).
