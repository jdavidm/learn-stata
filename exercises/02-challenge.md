---
layout: exercise
topic: Style & Execution
title: Challenge 2
language: Stata
---

For this challange, you will need to use `if` and `else` statements along with the global `$pack` to set up a loop that installs user written packages that we will need throughout the length of the course.

1\. Add an additional subsection (call it `**## 0.2 - Check if any required packages are installed`) to the `project.do` file that will contain the code to install packages.

2\. Next, write an `if` statement that will execute a code block if the global `$pack` is equal to 1.

3\. After the `if` statement, add braces (`{}`). The code that we write within these braces will be what gets executed if `$pack` equals 1.

4\. Within the braces, define a local (`loc`) called `userpack`. The contents of the local will be the following user written packages. When using a local in this way you need to use `=` in order to set `userpack` equal to the list of user written packages. You will also need to inclose the list of packages in `" "`. Packages should be listed with just a space in between each package name and they must all be on the same line (no breaking or wrapping the line like we do in the style guide. This is the only exception to that rule). 
    * `blindschemes`
    * `estout`
    * `palettes`
    * `distinct`
    * `catplot`
    * `colrspace`
    * `coefplot`

5\. After you define the local `userpack` then paste in the following code block. For each user written package in the local `userpack` (`foreach package in  userpack`) the code checks to see if the package is already installed (`capture : which package, all`). If it isn't (`if (_rc)`), it creates a pop up window (`capture window stopbox`) called `rusure` that tells the user that the package is missing (`You are missing some packages`) and asks if the user wants to install the package (`Do you want to install package?`). If the user selectes "yes" than the code installs the package from the "ssc" repository (`capture ssc install package, replace`). If the package is not on "ssc" (`if (_rc)`), then the code creates another pop up window (`window stopbox rusure`) that tells the user the package is missing (`This package is not on SSC. `) and asks the user if they want to proceed without the package (`Do you want to proceed without it?`). Alternatively, if the package is already installed (`else`) then the code simply exists the loop (`exit 199`).

```stata
	loc userpack = "blindschemes estout palettes distinct catplot colrspace coefplot"
	
* install packages that are on ssc	
	foreach package in `userpack' {
		capture : which `package', all
		if (_rc) {
			capture window stopbox rusure "You are missing some packages." "Do you want to install `package'?"
			if _rc == 0 {
				capture ssc install `package', replace
				if (_rc) {
					window stopbox rusure `"This package is not on SSC. Do you want to proceed without it?"'
				}
			}
			else {
				exit 199
			}
		}
	}
```

6\. Finally, after the above code block, but still within the `{}` of the original `if` statment, tell Stata to update all user written packages (`ado` files). And then permanently change the graphic scheme to one we just downloaded (`set scheme plotplain, perm`). Lastly, Stata's default is to freeze the output it displays until you tell it to move on. We will turn this feature off (`set more off`).

```stata
	* update all ado files
		ado update, update

	* set graph and Stata preferences
		set scheme plotplain, perm
		set more off
```
