---
layout: page
element: notes
title: Basic Debugging in Stata
language: Stata
---

### Debugging is normal

* Every programmer spends a lot of time **debugging** (finding and fixing errors).
* Bugs are not a sign that you’re bad at coding; they’re a sign that you’re coding at all.
* The key is to learn a systematic debugging process, not to randomly poke at your code.

We’ll cover:
- A basic debugging mindset
- Making bugs reproducible
- Reading Stata error messages
- A step-by-step debugging example

### Basic debugging mindset: be a scientist

The best way to debug is to approach the problem like you would any research problem - use the scientific method:

* **Be a scientist**
    * Form a hypothesis about what is wrong
    * Make one change that should fix that hypothesis
    * Test if the change worked
* Don’t change things at random
* Don’t make five changes and then run the whole file again
* Treat each bug as a mini-experiment

### Make bugs reproducible

You can’t fix a bug you can’t reliably reproduce.

1. Start from a clean environment
    * Use `clear all` or restart Stata
    * Then run your `project.do` file to set up paths, globals, etc.
    * Then run the `.do` file you’re working on from the top
2. Run the code the same way every time
    * Avoid running random blocks out of order
    * For debugging, run the whole file until it breaks, see where it stops
    * Use comments to document where it stops and your initial hypothesis as to why
3. Save the broken version
    * Save the .do file (or better yet, commit to Git) before you start “fixing”
    * That way you can go back if your fixes introduce new problems

### Reading Stata error messages

When Stata errors, it:
1. Prints a message
2. Gives an error code like `r(111)`
3. Stops execution

**First rule:** *read* the error message. It often tells you exactly what’s wrong.

Common examples:
* `variable not found`
    * Typo in the name, or variable never created
* `type mismatch`
    * Trying to do math with a string, or compare string and numeric
* `no observations`
    * Your `if` condition drops everything; `sum Y if X == 1` finds no rows
* `option xyz not allowed`
    * You copied an option from another command or version

You can look up error codes with:

```stata
    help             r(111)
```

or search the Stata docs:

```stata
    search           "type mismatch"
```

### Debugging by example: a broken Stata script

Here’s a deliberately broken script:

```stata
**********************************************************************
**# 1 - example: broken code
**********************************************************************

* load data
    use             "$data/eth_allrounds_final.dta"

* create yield per hectare
    gen             yield_ha = harvestg / plot_area_GPS

* summarize average yield for irrigated plots only
    sum             yield_ha if irr = 1, details

* save results
    save            "eth_yield_ha.dta"
```

This script has multiple problems:

1. `use` without `, clear` may fail if data are already in memory
2. The variable names might be wrong (`harvestkg` vs `harvest_kg`, `irr` vs `irrigated`, etc.)
3. `irr = 1` in an `if` condition is **assignment**, not comparison (`==` is needed)
4. `details` is not the correct option name (should be `detail`)
5. `save` without `, replace` may fail if the file already exists

Let’s debug this systematically.

#### Step 1: Run and see where it fails

* Start fresh: `clear all`
* Run from the top
* Suppose Stata stops at the `gen` line with:

> `variable harvestkg not found  
> r(111);`

*Hypothesis*: I spelled the variable name wrong.

Check:

```stata
    describe
```

Look for something like `harvest_kg`. Fix:

```stata
* create yield per hectare
    gen             yield_ha = harvest_kg / plot_area_GPS
```

Run again from the top.

#### Step 2: Fix the next error

Suppose now Stata stops at:

```stata
sum             yield_ha if irr = 1, details
```

with:

> `= invalid name  
> r(198);`

This usually means you used `=` where Stata expects a variable name.

*Hypothesis*: I used assignment (`irr = 1`) instead of comparison.

Fix:

```stata
* summarize average yield for irrigated plots only
    sum             yield_ha if irr == 1, detail
```

Changes:

* `irr == 1` instead of `irr = 1`
* `detail` instead of `details`

Run again from the top.

#### Step 3: Fix file I/O issues

Finally, Stata may complain:

> `file eth_yield_ha.dta already exists  
> r(602);`

*Hypothesis*: I’m trying to overwrite an existing file without permission.

Decide what you want:

* If you really want to overwrite:

```stata
* save results
    save            "eth_yield_ha.dta", replace
```

* Or choose a new file name (`eth_yield_ha_v2.dta`)

After each fix, **re-run from the top** until you hit the next error or everything works.

> Do [Exercise 4 - Debugging]({{ site.baseurl }}/exercises/07-debug/)

### Tools for observing what’s going on

Debugging is often about **seeing what Stata sees**:

* Use `describe` to check variables exist and types
* Use `sum` (or `sum, detail`) to check values
* Use `list` or `browse` on a small subset:

```stata
* inspect first 10 irrigated plots
    list            hh_id plot_area_GPS yield_kg irr in 1/10

* or
    list            hh_id plot_area_GPS yield_kg irr if irr == 1 in 1/10
```

* Add temporary `display` lines:

```stata
* check that r(mean) has the value we expect
    sum             yield_ha if irr == 1
    display         "Mean irrigated yield_ha = " r(mean)
```

If the `display` output surprises you, your mental model is wrong. Fix the model or the code.

### Rubber duck debugging and talking through code

Another powerful technique:

* **Rubber duck debugging**: explain your code out loud, line by line, to an inanimate object or your cat (or a human, if nothing better is available).
* Saying “this line loads the data, this line creates `yield_ha`, this line summarizes for irrigated plots…” often makes mistakes jump out:
    * “Wait, where did `yieldkg` come from?”
    * “Why am I using `=` instead of `==` here?”
You can do this:
* to your plants or your pets
* With a friend or classmate
* In office hours
* With an actual rubber duck on your desk if that’s your vibe

### Using LLMs to help debug

We’ve talked already about **Large Language Models** (LLMs) like ChatGPT and Copilot. In this course you are allowed to use them, especially for debugging, but with some important caveats.

Good uses:
* Ask: “Here is a short Stata do-file and the error message `type mismatch`. What might be wrong?”
* Ask for explanations of error messages
* Ask for alternative ways to implement something you already tried

Less good uses (the forklift-at-the-gym problem):
* Dump an entire assignment in and ask for the solution
* Copy-paste LLM code without understanding it

How to use LLMs effectively for debugging:
1. Create a minimal reproducible example
    * Small `.do` snippet (10–20 lines)
    * A short description of the data (or small fake data)
    * The exact error message
2. Ask focused questions
    * “Why might this `merge 1:1` be producing a `not uniquely identified` error?”
    * “What does `r(111)` mean in Stata?”
3. Verify suggestions
    * Run their proposed fix on your data
    * Make sure you understand *why* it works
    * Ask the model to write your code into house style before putting it in your assignment (feed it our style guide)

Remember: the goal is to **learn Stata**, not just to get your assignment to run.

### Summary debugging workflow

When you hit a bug:

1. Reproduce it
    * `clear all`  
    * Run `project.do`  
    * Run your code from the top
2. Read the error message
3. Form a hypothesis
4. Make one small change
5. Test from the top until it breaks again (or not)
6. Use tools like `describe`, `sum`, `list`, `display`
7. If stuck, **talk through the code** or ask for help (plants, cats, classmates, Slack, office hours, or an LLM)
