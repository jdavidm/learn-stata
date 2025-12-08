---
layout: exercise
topic: Functions
title: Built-in Functions
language: Stata
---

A built-in function is one that you don't need to write yourself. Some come with the factory version of Stata while others are user written and must first be installed. Some examples include:

* `abs()` returns the absolute value of a number (e.g., `abs(-2`))
* `round()`, rounds a number (the first argument) to a given number of decimal places (the second argument) (e.g., `round(12.1123, 0.01)`)
* `sqrt()`, takes the square root of a number (e.g., `sqrt(4)`)
* `strlower()`, makes a string all lower case (e.g., `strlower("HELLO")`)
* `strupper()`, makes a string all upper case (e.g., `strupper("hello")`)

Use these built-in functions to display the following items:

1. The absolute value of -15.5.
2. 4.483847 rounded to one decimal place.
3. 3.8 rounded to the nearest integer. *You don't have to specify the number of
   decimal places in this case if you don't want to, because `round()` will
   default to using `0` if the second argument is not provided.*
4. `"unemployment"` in all capital letters.
5. `"INFLATION"` in all lower case letters.
6. The square root of 2.6 rounded to 2 decimal places by putting the `sqrt()` call inside the `round()` call.
