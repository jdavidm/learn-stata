---
layout: page
element: notes
title: Setting Up Your Development Environment
language: Stata
---

### Introduction to development environments

* Goal - fully reproducible cleaning and analysis
* Code should be able to rerun full analysis with a single click (or command)
* First step - Make sure your code runs anytime and anywhere
  * next day (who has gotten code working & had it not work the next day?)
	* desktop vs. laptop
	* collaborators
	* advisor

### Make sure things you did before don't matter

* Computers store the results of each command run in sequence
* Change something
* Looks like it still works
* Only works because of something you did earlier in the same session

### Clearing environments and restarting R

* Clear Stata using `clear`.
  * Removes data from memory
  * Doesn't unload packages or erase globals
  * Necessary every time you load a new data set
* Restart Stata or use `clear all` to get a clean environment
  * Removes data
  * Unloads packages and erases globals
  * Drops all results, closes all windows (graphs)
* Safest thing is to restart Stata
* Then run your `project.do` file to set up a new development environment
* Then run your code - ideally from the `project.do`
* Ensures that the code runs fully and produces desired result
* Last required exercise of every assignment will walk you through this process

### Creating a `project.do` file

* For those who use R, the Stata Project is equivalent to an R Studio Project
* If
  * We kept all data and code in the same directory as the Stata Project
  * Only used relative paths
  * Then we'd be 80% of the way to setting up our dev enviro
* But we don't keep data and code together
* And there is still that 20% of set-up remaining

* To completely set-up the dev enviro in a way that is fully reproducible
* Will create a `proect.do` file that
  * Sets the version of Stata that the code works on
  * Determines what computer it is running on
  * Sets directories for data and code
  * Loads any necessary user written programs
  * Sets any preferences we might want
  * Ideally runs all code for the project
* It is important to define which version of Stata the code works on because
  * Different versions have different capabilities and commands
  * User written packages only work on specific versions
* If the goal is reproducibility, one needs to tell a user what version of the software they need to ensure that the code works

  * Now we're going to start writing the `project.do` file

> Do [Exercise 5.1 & 5.2 - Create Project Do]({{ site.baseurl }}/exercises/02-create-project/)

### Macros

* A key concept in computer coding is the idea of a `macro`
* A `macro` is a string of characters, called the `macroname`, that stands for another string of characters, called the `macro contents`.
* Macros can be
  * Expressions like `2 + 2`
  * Functions like `c(username)`
  * Programs (more on these later in the course)
* Stata has two types of macros
  * `global` - a public macro available to all programs whose value remains constant throughout a Stata session until it's value is expliccitly changed
  * `local` - a private macro available only to the program using the macro and whose value cannot be modified
* Essentially, a `global` sticks in Stata's memory and can be used and referenced throught a Stata session while a `local` is immediately forgotten by Stata and thus only retains its value when you run the code block that contains the `local`

* We assign values to `global` and `local` macros in the same way

```stata
  global    globalmacroname   globalmacrocontent
  local     localmacroname    localmacrocontent
  ```

  * But we reference or call these macros in very different ways

  ```stata
  $globalmacroname
  `localmacroname'
```

> Do [Exercise 5.3 & 5.4 - Create Project Do]({{ site.baseurl }}/exercises/02-create-project/)


### Make sure code works on other computers

* Don't use `setwd()`
    * Use projects and relative paths
    * `data/mydata.csv` not `C:\Users\Batman\DataCarp\data\mydata.csv`
* Write code that works on all operating systems
    * Filenames in code should match actual names exactly, including capitalization
    * Use `/` instead of `\` or `\\` in paths

### Clean up extra code

* Remove experiments from your code
* Or at least comment them out
* Remove `install.packages()` lines from your code
* Avoid reinstalling packages repeatedly

### Checklist

* There is an Assignment Turn In Checklist to help
* Show link on main page
