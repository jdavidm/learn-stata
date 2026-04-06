---
layout: page
element: notes
title: Writing Custom Stata Programs
language: Stata
---

In previous lectures, we learned how to use locals and loops to automate repetitive tasks. But what if you have a complex sequence of commands that you need to run dozens of times across different datasets, or within a simulation? 

For that, you don't just want a loop—you want to write your own Stata command. Stata allows you to package any set of commands into a custom **program**. 

### Defining a Basic Program

To create a program, we use the `program define` command (or just `program`), followed by the name we want to give it. We end the program with the `end` command.

```stata
program hello_world
    display "Hello, world! This is my first Stata program."
end
```

Once Stata runs this block of code, `hello_world` is stored in its memory. You can now type `hello_world` anywhere in your `.do` file or command window, and Stata will execute the code inside it.

```text
. hello_world
Hello, world! This is my first Stata program.
```

### The Golden Rule: `capture program drop`

If you try to run your `.do` file a second time, Stata will give you an error: `program hello_world already defined r(110);`. 

Stata holds onto programs until it is closed. To ensure your `.do` file can be run top-to-bottom over and over again without throwing an error, you must **always drop** the program before defining it. Because dropping a program that doesn't exist yet *also* throws an error, we prepend the `capture` prefix to silently suppress any errors.

The standard pattern for writing *any* Stata program looks like this:

```stata
* safely drop the program if it already exists in memory
capture program drop hello_world

* define the program
program hello_world
    display "This is the right way to write a program!"
end
```

### Making Programs Flexible: `args`

A program that always does the exact same thing isn't very useful. We want to pass inputs (arguments) into our program so it behaves dynamically.

You can declare arguments inside your program using the `args` command.

```stata
capture program drop greet_user

program greet_user
    args first_name last_name
    
    display "Hello there, `first_name' `last_name'! Welcome to Stata programming."
end
```

When you call this program, you simply pass the arguments in order:

```text
. greet_user "Jane" "Doe"
Hello there, Jane Doe! Welcome to Stata programming.
```

The `args` command takes the inputs provided by the user and assigns them to local macros (in this case, ``` `first_name' ``` and ``` `last_name' ```).

### Returning Results: `rclass`

Often, you don't just want a program to *do* something—you want it to *calculate* something and give the answer back to you, so you can use it later. 

To tell Stata that your program will return results, you must add the `, rclass` option to your `program` definition. Inside the program, you can then use `return scalar` to pass numbers back out.

```stata
capture program drop add_numbers

program add_numbers, rclass
    args num1 num2
    
    * calculate the sum
    local sum = `num1' + `num2'
    
    * return the result as a scalar
    return scalar total = `sum'
end
```

Now, let's run the program and use the `return list` command to see what we caught:

```text
. add_numbers 5 10

. return list

scalars:
              r(total) =  15
```

Because `add_numbers` returned a scalar, you can now access `r(total)` anywhere else in your `.do` file! This is the exact same mechanism that Stata's native commands (like `summarize` returning `r(mean)`) use.

### Why does this matter?

Writing `rclass` programs is the foundation of **Monte Carlo simulations**. Stata's built-in `simulate` command works by calling a custom program thousands of times, passing in different noise parameters via `args`, and automatically catching the `r()` values your program returns on every single iteration!
