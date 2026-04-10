---
layout: page
element: notes
title: Code Execution
language: Stata
---

### Basic code execution

* When we run a chunk of code it runs from top to bottom in order
* It runs the first line, then the second line, and so on
* This means that order is important
* Write code to calculate GDP growth from GDP in 2025 and 2024

```stata
    clear           all
    set obs         1
    gen             gdp_d = gdp_25 - gdp_24 / gdp_24
    gen             gdp_24 = 12.9
    gen             gdp_25 = 13.5
    display         gdp_d
```

* Returns an error because neither `gdp_24` or `gdp_25` exists yet

* Within a line code executes everything before assigning the output to a variable
* So it starts to the right of the equal sign
* Looks up the value for `gdp_25 `
* Can't find the variable and so errors

* Rearrange the code so that all variables are created before they are used

```stata
    clear           all
    set obs         1
    gen             gdp_24 = 12.9
    gen             gdp_25 = 13.5
    gen             gdp_d = gdp_25 - gdp_24 / gdp_24
    display         gdp_d
```

* This executes in the following sequence
* The right hand side of the first line creates a scalar
* It is then stored or "assigned" to the variable `gdp_24`
* The second line then runs creating a scalar and assigning it to the variable `gdp_25`
* The third line first looks up the variable `gdp_25` and replaces it with its value
* It then looks up the the variable `gdp_24` and replaces it with its value
* It then again looks up the the variable `gdp_24` and replaces it with its value
* It then performs the mathmatical operations 
* It assigns the resulting scalar to the variable `gdp_d`
* The fourth line first looks up the variable `gdp_d` and then prints its value on the screen

### Operator precedence in expressions

* The above code will execute but it will give the wrong answer
* That is because code executes following Stata's order of operations (similar to the order of operations in math: PEMDAS)
* Within a single command that involves a complex expression (e.g., in a `gen` or `replace` command), Stata follows the following order (from first to last): 
    * `!` (or `~`): Logical NOT
    * `^`: Exponentiation
    * `-`: Negation
    * `/`, `*`: Division, Multiplication
    `-`, `+`: Subtraction, Addition
    * `!=` (or `~=`), `>`, `<`, `<=`, `>=`, `==`: Relational operators (not equal, greater than, etc.)
    * `&`: Logical AND
   `|`: Logical OR 
* Like in PEMDAS, parentheses can be used to override this default order and force specific parts of an expression to be evaluated first. 
* Stata processes the entire dataset for a single command, then moves to the next command. This is different from some other statistical software, where a command is executed for one observation before moving to the next.

### Our example

* The sequence of execution for the third line is
    * Look up the variable `gdp_25` and replaces it with its value
    * Look up the the variable `gdp_24` and replaces it with its value
    * Again look up the the variable `gdp_24` and replaces it with its value
    * Divide `gdp_25` by `gdp_24`
    * Subtract the result of the division from `gdp_25`
    * It assigns the resulting scalar to the variable `gdp_d`
* The fourth line first looks up the variable `gdp_d` and then prints its value on the screen


* The program is dumb and will do exactly what you tell it based on the program's rules
* If you get an unwanted or unexpected result, the problem is with your directions NOT with how the program executed your directions

```stata
    clear           all
    set obs         1
    gen             gdp_24 = 12.9
    gen             gdp_25 = 13.5
    gen             gdp_d = (gdp_25 - gdp_24) / gdp_24
    display         gdp_d
```

* One needs to take care in how you order actions to the right of the equal sign
* But also need to take care in how you order objects to the right of the command you are executing
* Think carefully on how to use brackets and parenthesis
* Think carefully on how you structure the logic of your commands
* Particularly if they involve
    * Conditionals: `if`, `&`, and `||` (or)
    * Loops: `foreach`, `forevery`, assignment of `locals`
    * Replacing or removing values: `replace`, `drop`, `drop if`
### Summary

- Stata executes code sequentially from top to bottom.
- The order of commands strictly dictates the state of your session.
- Variables must be created before they can be referenced in calculations.
