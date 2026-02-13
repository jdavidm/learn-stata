---
layout: page
element: notes
title: Macros and Storing Results
language: Stata
---

In Week 6 we start digging into **Stata as a programming language** rather than just a calculator.

This first lecture focuses on:

- What macros are and why they’re useful  
- Different types of macros (local vs global) and when to use each  
- How to store results from commands in macros and scalars  
- Good habits and common pitfalls when using macros

We’ll mostly use the `auto` data set that comes with Stata so load it now using `sysuse`.

### Why macros?
So far you’ve mostly typed literal text into your commands:

```stata
    regress             price mpg weight foreign
```

But as your code grows, you’ll find yourself repeating:
- Long lists of variables  
- File paths  
- Numbers or options you keep using (e.g., a significance level, a bin width)  

Macros let you:
- Define a **name** that stands for some **text**  
- Reuse that name instead of re-typing the text  
- Change the macro *once* and have all the code that uses it update automatically  

Conceptually: A macro is just a *name* that Stata will replace with some *text* **before** it runs a command.

We've already had experience with this when we set up our development environment and used `global` macros to define directory paths.

### Local macros: your default

#### Defining and using simple locals
Local macros live only in a limited scope (command window, current do-file, or current program) and then disappear. They’re the safest kind of macro and should be your default choice.

Basic syntax:

```stata
    local           macroname contents
```

To *use* a local macro you wrap its name in a **left backtick** (`` ` ``) and a **right straight quote** (` ' `):

```stata
    `macroname'
```

The two most common ways we use a local macro are:
1. To define a list of objects that we will loop over (more on loops next lecture)
2. To work as a shorthand for a list of variables, often ones we use in a regression

Example – list of control variables:

```stata
* load example data
    sysuse          auto, clear

* define a macro with controls
    local           controls mpg weight foreign

* use the macro in regressions
    regress         price `controls'
    regress         length `controls'
```

When Stata executes ```regress price \`controls'```, it first substitutes the macro contents, so it *really* runs:

```stata
    regress         price mpg weight foreign
```

This saves typing and keeps your code consistent. If you decide later that you also need `turn` as a control:

```stata
    local           controls mpg weight foreign turn
```

And **all** the regressions that use ```controls'`` now include `turn` automatically. You don't have to go and add it to every regression.

#### Locals with spaces and special characters
Macro contents are just text. If the contents include spaces or special characters, put them in quotes:

```stata
local               note "This is an example of a longer note."
display             "`note'"
```

Stata will substitute the whole string into the command before running it.

> Do [Exercise 1 - Using Locals in Regressions]({{ site.baseurl }}/exercises/06-locals-r/)

### Storing results in local macros

A second extremely important use of locals is to **capture results** from commands and reuse them.

Many Stata commands store their results in `r()`, `e()`, or `s()` (you’ve seen this with `summarize`). You can copy those results into a local macro so you can use them later.

Recall:

```stata
sum                 mpg
return              list
```

We can store the mean of `mpg` in a local:

```stata
* store mean in a local
    sum             mpg
    local           mean_mpg = r(mean)

* use it in a display
    display         "The mean of mpg is `mean_mpg'"
```

Key points:

- The `=` after the macro name tells Stata to **evaluate** the right-hand side as an expression and store the *result* (not the literal text).
- The macro stores the result as text (a string representation of the number). Good enough for most purposes, but not infinite precision.

You can then reuse the result later in a calculation:

```stata
* define a standardized mpg using stored mean and sd
    sum             mpg
    local           mean_mpg = r(mean)
    local           sd_mpg   = r(sd)

    gen             mpg_std = (mpg - `mean_mpg') / `sd_mpg'
```

> Do [Exercise 2 - Using Locals to Store Results]({{ site.baseurl }}/exercises/06-locals-s/)

### Global macros: powerful and dangerous

Global macros are like locals, but:
- They are visible **everywhere** (all do-files, all programs) in your current Stata session  
- They persist until you close Stata or change them  

Syntax:

```stata
global macroname contents
display "$macroname"
```

The `$` prefix tells Stata to substitute a **global** macro.

Example – a path (for illustration; in this course we’ll usually prefer locals in `project.do`):

```stata
* define a global path to raw data
    global rawdata "/Users/jdm/data/raw"

* use it in a use command
    use "$rawdata/eth_allrounds_final.dta", clear
```

Globals can be convenient for things like paths or version numbers, but they’re **easy to abuse**:

- They can be accidentally overwritten by other code  
- They make your code harder to reason about (hidden dependencies)  

**House rule for this class:**  
- Use **local macros almost always**  
- Use **globals only** for a small set of carefully chosen things (e.g., paths in `project.do`) and document them clearly. fileciteturn0file2

> Do [Exercise 3 - Using Globals]({{ site.baseurl }}/exercises/06-globals/)

### Storing results as scalars

Macros store numbers as *text*, which is sometimes not ideal (rounding, comparisons). Stata also has **scalars**, which store numeric or string values in a separate namespace with full precision. citeturn1view0

Syntax:

```stata
scalar scalname = expression
display scalname
```

Example – store and reuse R-squared from a regression:

```stata
* run a regression
    quietly regress price mpg weight

* store the R-squared in a scalar
    scalar rsq_price = e(r2)

* use it later
    display "R-squared from price model: " rsq_price
```

Compare to storing in a local:

```stata
* store in a local instead
    local rsq_local = e(r2)
    display "R-squared (local macro): `rsq_local'"
```

Differences:

- **Scalars**:  
  - Stored with full numeric precision  
  - Live in a global namespace (can be accessed anywhere in the session)  
  - Good when you care about exact numeric values

- **Local macros**:  
  - Store a text representation (about 8 digits)  
  - Limited scope (current do-file / program)  
  - Safer for modular code

Rule of thumb:

- If you just need to plug a stored number into another command in the *same* do-file, a **local** is usually enough.  
- If you need high precision or want to reuse the result across multiple do-files/programs, a **scalar** may be better (or write the value to disk).

> Do [Exercise 4 - Storing Results as Numbers]({{ site.baseurl }}/exercises/06-store/)

### Using macros to store file paths and filenames

A very common pattern is to store **paths** and **filenames** in macros, so that moving your project (or renaming a folder) takes changing a couple of lines rather than hundreds.

Inside your `project.do`:

```stata
**********************************************************************
**# 0 – setup paths
**********************************************************************

* project root (set once)
    local root    "/Users/yourname/projects/semester26"

* subdirectories relative to root
    local data    "`root'/data"
    local code    "`root'/code"
    local logs    "`root'/logs"

* use the macros
    use "`data'/eth_allrounds_final.dta", clear
    log using "`logs'/week6_macros.log", replace
```

This keeps paths **centralized** and makes your code portable (change directory structure in one place).

For this course, we combine this idea with our standard **house style** and `project.do` structure.

### Common macro pitfalls (and how to avoid them)

#### Forgetting the quotes or backticks

```stata
local x 5
display x        // WRONG: Stata looks for variable x, not the macro

display `x'      // WRONG: missing quotes → Stata sees display 5 (ok here)
display "`x'"    // RIGHT: Stata sees display "5"
```

Rule:  
- When you *display* text or a number stored in a macro, wrap the macro in quotes: ```display "`macroname'"```.

#### Typos don’t error – they silently disappear

If you use a macro name that doesn’t exist:

```stata
local controls mpg weight
regress price `contrls'
```

Stata just substitutes an empty string for ``contrls'` and runs:

```stata
regress price
```

which is probably **not** what you intended. Get in the habit of:

- Checking your output carefully  
- Using meaningful macro names  
- Being careful with spelling and copy-paste

#### Overusing globals

Globals seem convenient, but:

- They are visible everywhere  
- One do-file can change a global another do-file depends on  
- Debugging becomes painful (“Where did `$data` get set?”)

So again: **locals by default**, globals rarely.

#### Macro scope in do-files and programs

Locals exist only in the current context:

- If you define `local x 5` in one do-file, it is *not* visible in a different do-file unless that do-file is called from inside the first one (and even then you need to be careful).  
- When a program finishes, its locals disappear.

We’ll revisit this when we write our own programs later in the course.

### Short workflow: using macros to make code cleaner

When you catch yourself repeating text, try this pattern:

```stata
* 1. Define your macros near the top of the do-file
    local controls   mpg weight foreign
    local yvars      price length

* 2. Use them in your code
    foreach y of local yvars {
        regress `y' `controls'
    }

* 3. If something changes (add a control, drop an outcome),
*    edit the macros, not the loop body.
```

This keeps your code:

- Shorter  
- Less error prone  
- Easier to modify later  

In the next lecture we’ll lean heavily on macros as we learn how to **write loops** and add simple **programming commands** (`forvalues`, `foreach`, `while`, `if`, `continue`) to your Stata toolkit.
