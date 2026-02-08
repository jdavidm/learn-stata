---
layout: page
element: notes
title: Programming Fundamentals II – Loops and Programming Commands
language: Stata
---

In this second lecture on programming fundamentals we’ll build on macros and focus on **automation**:

- Writing loops to repeat tasks safely and quickly  
- Using `forvalues` and `foreach` for different kinds of lists  
- Understanding Stata’s `while` loop  
- Using the programming `if` command (different from the `if` *qualifier*)  
- Using `continue` and `continue, break` to control loop flow  

We’ll again mostly use `sysuse auto` and small examples so that the focus stays on the **logic**.

---

## 1. Implicit vs explicit looping

Stata already loops over observations for you:

```stata
gen logincome = log(income)
```

This line computes the log of `income` for **all** observations — there is no explicit loop, but Stata is looping behind the scenes. citeturn1view0

You only need **explicit** loops when you’re repeating a pattern over:

- A **sequence of numbers** (e.g., years 2000 to 2025)  
- A **list of variables**  
- A **list of arbitrary words or tokens**  

---

## 2. Looping over numbers with `forvalues`

### 2.1 Basic structure

Syntax:

```stata
forvalues i = 1/5 {
    display "`i'"
}
```

Key pieces:

- `forvalues` – loop command  
- `i` – name of a local macro that will take each value in the sequence  
- `1/5` – the sequence of numbers (1, 2, 3, 4, 5)  
- `{ ... }` – the **body** of the loop; everything inside runs once per value of `i`

Stata will execute:

```text
display "1"
display "2"
display "3"
display "4"
display "5"
```

### 2.2 Different sequences

You can specify sequences in two main ways:

```stata
* from min to max in steps of 1
forvalues i = 1/3 {
    display "`i'"       // 1, 2, 3
}

* from first to last in steps of step
forvalues j = 10(5)30 {
    display "`j'"       // 10, 15, 20, 25, 30
}
```

You can use these macros inside expressions and variable names:

```stata
* create 5 dummy variables x1, x2, ..., x5
    clear
    set obs 10

    forvalues k = 1/5 {
        gen x`k' = runiform()
    }
```

Stata will execute commands like `gen x1 = runiform()`, `gen x2 = runiform()`, …, `gen x5 = runiform()`.

---

## 3. Looping over lists with `foreach`

`foreach` is the other main loop workhorse in Stata. It loops over **lists** of things: words, variables, numbers, or macro contents. citeturn1view0

### 3.1 Generic list – `foreach item in ...`

Syntax:

```stata
foreach animal in cats dogs cows {
    display "`animal'"
}
```

This prints:

```text
cats
dogs
cows
```

Stata sets the local macro `animal` to each word in the list in turn.

More useful example – irregular year list:

```stata
foreach year in 2000 2005 2010 2020 {
    display "Processing year `year'"
    * you could add: use data for `year', do stuff, save results
}
```

### 3.2 Looping over variables – `foreach var of varlist`

Most often in data work you want to loop over **variables**:

```stata
sysuse auto, clear

* summary stats for multiple variables
    foreach v of varlist price mpg weight {
        summarize `v'
    }
```

You can use all of Stata’s varlist shorthand inside `foreach`:

```stata
* any variable whose name starts with "turn" or "gear"
    foreach v of varlist turn* gear* {
        summarize `v'
    }
```

### 3.3 Looping over a list stored in a local macro

This is where loops and macros really shine together:

```stata
* define macro with list of controls
    local controls price mpg weight

* loop over the words in that macro
    foreach x of local controls {
        summarize `x'
    }
```

Here `foreach x of local controls` means:

- Look up the macro `controls`  
- Split its contents into words  
- Loop over those words as `x`

---

## 4. Putting loops and macros together: cleaning variables

Example: Suppose we have several variables that should be logged:

```stata
sysuse auto, clear

* vars to take logs of
    local logvars price weight length

* loop over them
    foreach v of local logvars {
        gen ln_`v' = ln(`v')
        label var ln_`v' "log of `v'"
    }
```

This generates `ln_price`, `ln_weight`, and `ln_length` with consistent labels, using **3 lines** instead of copy-pasting (and possibly messing up) 9 lines.

---

## 5. Specialized `foreach` for number lists

If you want to loop over an irregular sequence of numbers and want Stata to **check** that they’re valid numbers, you can use `numlist`:

```stata
foreach year of numlist 1980 1985 1995 {
    display "`year'"
}
```

You can mix explicit numbers with ranges:

```stata
foreach year of numlist 1980 1985 1990(5)2010 {
    display "`year'"
}
```

---

## 6. Looping with conditions: `while`

Stata also has a `while` loop:

```stata
while condition {
    ... commands ...
}
```

- The loop runs as long as `condition` is **true** (non-zero)  
- You must make sure something inside the loop eventually makes `condition` false, or you’ll have an infinite loop  

Simple example:

```stata
local i = 1
while `i' <= 5 {
    display "i = `i'"
    local i = `i' + 1
}
```

This prints `i = 1`, `i = 2`, …, `i = 5` and then stops.

`while` loops are most useful when the number of iterations isn’t known in advance, e.g., iterative estimation until convergence. For most data tasks in this course, `forvalues` and `foreach` are clearer and safer.

---

## 7. Programming `if` vs the `if` *qualifier*

Very important distinction:

- **`if` qualifier** (what you’ve used so far) restricts **which observations** a command runs on:

  ```stata
  summarize wage if female == 1
  ```

- **Programming `if`** in Stata is a **command** that decides **whether to run some code at all**, based on a logical expression:

  ```stata
  if expression {
      ... commands ...
  }
  else {
      ... optional other commands ...
  }
  ```

Example – guard code based on sample size:

```stata
* check if we have enough observations before running a regression
    count if !missing(price, mpg, weight)
    local N = r(N)

    if `N' < 50 {
        display as error "Not enough complete observations (`N') – skipping regression."
    }
    else {
        regress price mpg weight
    }
```

The programming `if` does **not** loop over observations; it uses whatever scalar result you give it (here `N`).

---

## 8. Breaking out of loops with `continue` and `continue, break`

Sometimes you want to **skip** certain iterations or **stop** a loop early. Stata’s `continue` command handles both:

- `continue` – stop the current iteration and go to the next  
- `continue, break` – exit the loop entirely  

Example – loop over years but skip one and stop early:

```stata
foreach year of numlist 2000/2010 {

    * skip 2005
    if `year' == 2005 {
        continue
    }

    display "Working on year `year'"

    * stop the loop after 2008
    if `year' == 2008 {
        continue, break
    }
}
```

This prints:

- 2000, 2001, 2002, 2003, 2004, 2006, 2007, 2008  
- Skips 2005  
- Stops completely after 2008  

---

## 9. Example: automated summaries and graphs

Let’s put everything together in something closer to real work.

Goal: For a list of variables, produce:

- A table of summary statistics  
- A histogram saved to disk for each variable  

```stata
sysuse auto, clear

* 1. variables to summarize
    local vars price mpg weight length

* 2. loop over them
    foreach v of local vars {

        * summarize with detail and save N
            quietly summarize `v', detail
            local N = r(N)

        * only graph if we have at least 50 observations
            if `N' < 50 {
                display as txt "Skipping `v' (only `N' obs)"
                continue
            }

        * print a header and key stats
            display "-------------------------"
            display "Variable: `v'"
            display "Mean: "      %9.3f r(mean)
            display "Median: "    %9.3f r(p50)
            display "Std. dev.: " %9.3f r(sd)

        * histogram and save graph
            histogram `v', ///
                title("Distribution of `v'") ///
                name(hist_`v', replace)

            graph export "hist_`v'.png", replace
    }
```

Things to notice:

- We use a **local macro** `vars` as the source list for a `foreach` loop.  
- Inside the loop we rely on **stored results** from `summarize`.  
- We use a programming `if` to **skip** variables with too few observations (`continue`).  
- We reuse the macro `\`v'` in graph titles and filenames, avoiding copy-paste errors.

This is the kind of pattern that will be extremely helpful later in the course and in your own research.

---

## 10. A simple debugging workflow for loops

Loops can be harder to debug because one or two bad iterations are buried in many repetitions. Some tips:

1. **Start small**  
   - Test the body of the loop for a *single* value first (e.g., just for year 2000).  
   - Once it works, wrap it in a loop.

2. **Display what’s going on**  
   - Sprinkle `display` statements inside the loop to print the current macro values.

   ```stata
   foreach v of varlist price mpg weight {
       display "Working on `v'"
       summarize `v'
   }
   ```

3. **Use `set trace on` when you’re really stuck**  
   - Stata will print *every* step it executes, including macro substitutions.  
   - Turn it off with `set trace off` as soon as you’re done.

4. **Check that the loop boundaries are what you think**  
   - Off-by-one errors (`1/10` vs `0/9`) are common.  
   - Use small ranges while you’re testing.

---

## 11. Summary and what’s next

You now have:

- **Macros** to store text, lists of variables, and results  
- **`forvalues`** for looping over number sequences  
- **`foreach`** for looping over lists (including varlists and macro contents)  
- **`while`** for condition-driven loops (less common in this course)  
- **Programming `if`**, `continue`, and `continue, break` to control flow

In upcoming weeks we’ll use these tools to:

- Write more complex, reusable code for data cleaning and analysis  
- Wrap code in **programs** (your own Stata commands)  
- Make your assignments and research scripts shorter, safer, and easier to adapt.
