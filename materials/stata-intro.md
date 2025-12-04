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

### Variables

* Data sets will already contain variables
* A variable is a name that has a value associated with it

* We can manipulate an existing variable

```stata
    sum weight
    replace weight = weight / 2000
    sum weight
```

* We can also create new variables

```stata
    gen kmpl = mpg / 2.3520
    sum mpg kmpl
```

### Basic Stata syntax

```stata
    command [varlist] [=exp] [if exp] [in range] [weight] [, options]
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

```r
# Calculate weight of Kangaroo Rat in pounds
```

### Assignments format

* **SEPARATE FILES FOR CLASS CODE ALONG AND HOMEWORK**
* Comment before each problem and each sub-problem
* Make sure result prints out on `Source with echo`

```r
# Problem 1

# 1.1
2 + 2

# 1.2
2 - 8

# Problem 2

width = 2
height = 3
length = 1.5
volume = width * height * length
volume
```
> Create assignment script, put in new folder

* Now we're going to work on some exercises to get a feel for this
* In class we will often only do part of an exercise and save the rest for later

> Do [Exercise 1.1-1.3 - Basic Expressions]({{ site.baseurl }}/exercises/Expressions-and-variables-basic-expressions-R/)

> Do [Exercise 2 - Basic Variables]({{ site.baseurl }}/exercises/Expressions-and-variables-basic-variables-R/)


### Functions

* A function is a complicated expression.
* Command that returns a value

```r
sqrt(49)
```

* A function call is composed of two parts.
    * Name of the function
    * Arguments that the function requires to calculate the value it returns.
    * `sqrt()` is the name of the function, and `49` is the argument.
* We can also pass variables as the argument

```r
weight_lb <- 0.11
sqrt(weight_lb)
```

* Another function that we'll use a lot is `str()`
* All values and therefore all variables have types
* `str`, short for "structure", lets us look at them

```r
str(weight_lb)
```

* Another data type is for text data
* We write text inside of quotation makes

```r
"hello world"
```

* If we look at the structure of some text we see that it is type character

```r
str("hello world")
```

* Functions can take multiple arguments.
    * Round `weight_lb` to one decimal place
    * Typing `round()` shows there are two arguments
    * Number to be rounded and number of digits

```r
round(weight_lb, 1)
```

* Functions return values, so as with other values and expressions, if we don't save the output of a function then there is no way to access it later
* It is common to forget this when dealing with functions and expect the
  function to have changed the value of the variable
* But looking at `weight_lb` we see that it hasn't been rounded

```r
weight_lb
```

* To save the output of a function we assign it to a variable.

```r
weight_rounded <- round(weight_lb, 1)
weight_rounded
```

#### Optional arguments

* When we looked at the tip for the `round()` function it showed `x` and `digits = 0` as the arguments.
* When you see the argument name followed by `=` and a value that means that argument is optional
* If you don't include that argument it will use the default value shown after the `=`

```r
round(weight_lb)
```

* Since the default was 0 the weight is rounded to 0 decimal places
* So, this is the same as

```r
round(weight_lb, 0)
```

* Optional arguments are often written using the name of the argument

```r
round(weight_lb, digits = 1)
```

* When there are multiple optional arguments this lets us change only the ones where we don't want the defaults

> Do [Exercise 4.1-4.3 - Built-in Functions]({{ site.baseurl }}/exercises/Functions-built-in-functions-R/)