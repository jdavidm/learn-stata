---
layout: exercise
topic: Data Management
title: Challenge 3
language: Stata
---

Using the `household_ea.dta` data set that you created in exercise 8, we are going to dig a bit more into the consumption gap between households in rural and urban EAs. We will walk through a number of steps that require you to use the concepts and commands from earlier in Assignment 3.

- Start by using `gen` to create a variable called `gap` that equals 1 if the household's consumption gap is negative. Then `replace` the value of `gap` so that it equals 0 if the household's consumption gap  is positive.
    - Hint: there are a number of households with missing values because either the household or EA data was missing. For reasons that are not important, Stata treates a missing value (the sysmis `.`) as positive infinity. So if you were to just type `replace gen = 0 if cons_gap > 0` Stata will assign a 0 to household above the mean consumption **but also** to all households with missing values. So you need to add an additional conditional about `cons_gap` not equalling `.`
- Label the variable as `Indicator for sign of consumption gap`. Also define a value label called `gap_lbl` where 0 is `Positive Gap` and 1 is `Negative Gap`. Assign this value label to the `gap` variable.
- Use `egen` to create a variable called `below` that totals up all households with `gap = 1`. Do this by `eaid` and `sector`. Label the variable `Number of households below mean consumption`.
- Use `egen` to create a variable called `above` that totals up all households with `gap = 0`. Do this by `eaid` and `sector`. Label the variable `Number of households above mean consumption`.
    - Hint: when having Stata total up households with a positive gap, you need to explicitly tell Stata to count the households where `gap == 0`.
- Use `egen` to create a variable called `tot_hh` that counts up all households in an EA and sector. Label the variable `Total number of households in EA`.
- Use `gen` to create a variable called `share_below` that is the percentage of households with a negative consumption gap within an EA and sector. Label the variable `Percentage of households in EA below mean consumption`.

Now that we have all these variables created and labeled, we can ask questions about where the gap is most negative or most positive using `bys` in combination with `sum`.

1. Is the share of households with a negative consumption gap greater in urban or rural EAs?
2. Which country has the largest share of households with a negative consumption gap?
3. Which country has the smallest share of households with a negative consumption gap?

---
