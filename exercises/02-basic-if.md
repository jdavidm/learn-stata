---
layout: exercise
topic: Expressions & Variables
title: Basic If Statements
language: Stata
---

1\. Create a variable `y` that equals "1" if `price` is less than or equal to "4195". How many cars have a price less than "4195"?

2\. Replace the value of `y` with a "3" if `price` is greater than or equal to "6342". How many cars have a price greater than "6342"?

3\. Replace the value of `y` with a "2" if `price` is greater than "4195" and less than "6342". How many cars have a price between "4195" and "6342"?

4\. Create a `global` called `pack` that equals "1". Then complete the code so that if `$pack == 1` the code prints "Setup mode: running installation/setup steps..." and if `$pack` doesn't equal "1" then the code prints "Run mode: skipping setup and continuing with the analysis." Set `$pack` to something other than "1" and run the code again.

```stata
	global   pack  1

	if XXX == y {
		
	}
	else {

	}
```

5\. Update your code above by adding an `else if` statement that prints "Update mode: updating ado files..." if `$pack == 2`