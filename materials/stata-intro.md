---

layout: page
element: notes
title: Introduction to Stata
language: Stata
---

> Remind students to install Stata
> Have students open Github Desktop
> Have students open Stata.

### Stata

* Programming language
* IDE - Integrated Development Environment
* A statistics and data analysis environment
* Now can run simulations, do ML, produce markdown files, interact with Python
* R is what runs all of the code we will write this semester
* Separate from RStudio

### Stata Graphic User Interface (GUI)

* Three components for interfacing with Stata
    1. Command line - contains several windows
        * Command window
        * Results window
        * History window
        * Variable window
        * Results window
    2. Project Manager - contains several windows
        * Project window
        * Text Editor window
        * Navigator window
        * Properties window
    3. Data Editor/Browser
    4. Viewer - how one reads help files and logs
    5. Graph Editor

* Command window is where Stata is actually running
    * Can work in here "interactively"
    * Run a single command and see the result
    * This is also where Stata will run code written in the text editor
* Text editor (`.do`-files)
    * Where we write code we want to keep and potentially reuse later
    * Creates a plain text file that stores the code we've written
    * This is where you will write all your code and is what you will submit for assignments
* Can also run commands using Stata's drop-down menu
    * Never do this to actually execute commands!
    * can be useful to learn syntax of new commands or infrequently used commands

### Basic expressions

* _Write code directly in the text editor_

```stata
    display 2+2
    display 2 * ttail(20, 2.1) 
```

* This is called an expression
* A set of commands that returns a value

* Run line
* Run selection

* Save as `stata-intro.do`
* Need to add file or directory to see it in the Project window
* We can also use this tab to create, delete, and rename files & folders

### Loading data
* Load sample data file

```stata
    sysuse auto.dta, clear
    describe
```
* Stata files end in `.dta`
* Stata can input data in almost any format
* You can look directly at the data using Stata's Data Editor/Browser

* Look at the data

```stata
    sort price
```

* Take a look at the data again

### Variables

* Data sets will already contain variables
* A variable is a name that has a value associated with it

* We can manipulate an existing variable

```stata
    sum weight
    replace weight = weight * 2.205
    sum weight
```

* We can also create new variables

```stata
    gen kmpl = mpg / 2.3520
    sum mpg kmpl
```

* Often more useful than looking at the data in the data frame is visualizing the data
* Stata has numerous different graphics commands
* However, most start with `graph twoway`

```stata
    graph twoway (scatter price mpg) (lfit price mpg)
```

### Basic Stata syntax

```stata
    command [varlist] [= exp] [if exp] [in range] [weight] [, options]
```
* `command`: The specific Stata command you want to run, such as `summarize`, `list`, or `graph`. Most commands can be shortened (e.g., `sum` for `summarize`).
* `[varlist]`: A list of one or more variables to be used by the command.
* `[=exp]`: An optional expression to create a new variable.
* `[if exp]`: A conditional statement that restricts the command to only certain observations. The expression is evaluated as true or false. For example, if `rep78 > 3`.
* `[in range]`: A qualifier that selects a specific range of observations, such as `in 1/100` for the first 100 observations.
* `[weight]`: Specifies a weighting variable.
* `[, options]`: A comma followed by options that modify the command's behavior. Options are separated by spaces. For example, `summarize, detail` provides more detailed statistics. 

### Comments

* Remember what code is doing
* For humans, not computers
* Use the `*`

```stata
* Convert imperial to metric
```

### Assignments format

* **SEPARATE FILES FOR IN-CLASS CODING AND HOMEWORK**
* Comment before each problem and each sub-problem

```stata
**# Problem 1

**## 1.1 - convert length to metric

    replace     length = length * 2.54

**## 1.2 - compare mpg across car type
    sum         mpg, by(foreign)

**# Problem 2

* regress price on mpg and repair record
    reg         price mpg rep78
```
> Create assignment script, put in new folder

* Now we're going to work on some exercises to get a feel for this
* In class we will often only do part of an exercise and save the rest for later

> Do [Exercise 1.1-1.3 - Basic Expressions]({{ site.baseurl }}/exercises/Expressions-and-variables-basic-expressions/)

> Do [Exercise 2 - Basic Variables]({{ site.baseurl }}/exercises/Expressions-and-variables-basic-variables/)
