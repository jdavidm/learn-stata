---
layout: page
element: notes
title: Label Variables and Values
language: Stata
---

### Why labels matter

Clean, well-labeled data are much easier to:

* Read a month from now (or in the middle of the night before a deadline),
* Share with collaborators,
* Use in regression tables and graphs.

Stata gives us **three main kinds of labels**:

* **Dataset labels** – a short description of the whole dataset  
* **Variable labels** – a human-readable description of what each variable is  
* **Value labels** – human-readable labels for the *values* of a variable (e.g., `1 = female`, `0 = male`)

### Labeling variables

A **variable label** is a short description attached to a variable.

It:

* Appears in the **Variables** window
* Appears in **output tables and graphs**
* Is stored with the dataset, so future-you will thank present-you

Suppose we have a dataset with variables:

```stata
describe
```

The output might look like:

```stata
variable name   storage   display    value
    name        type      format     label      variable label
----------------------------------------------------------------------
id             int       %9.0g
sex            byte      %8.0g
wage           float     %9.0g
```

Right now there are no variable labels. We can add them using the following command:

```stata
label variable varname "descriptive label"
```

The syntax here is `label variable` is the command that tells Stata you are going to label something and that something is a variable. Next, `varname` is my placeholder for whatever the actual name is of the variable you want to label. Finally, `"descriptive label"` is the text of the label you want to assign to the variable.

As in all things in Stata, commands can be abbreviated. Instead of writing out `label variable` you can just write `lab var`.

So, to label the above example data, we would write:

```stata
* label variables
    lab var         id "Individual ID"
    lab var         sex "=1 if respondent is female"
    lab var         wage "Hourly wage (USD)"
```

One can see the labels by running `describe` again:

```stata
variable name   storage   display   value
    name        type      format    label   variable label
----------------------------------------------------------------------
id             int       %9.0g              Individual ID
sex            byte      %8.0g              =1 if respondent is female
wage           float     %9.0g              Hourly wage (USD)
```

In the Stata command window, you can see the labels of variables in the **Variables** window as well as the **Properties** window. They also appear in the same place if you are looking at the data as a spreadsheet using Stata's data editor.

   ![Variable labels in command window]({{ site.baseurl }}/images/lab_var.png)


> Do [Exercise 3 - Label Variables]({{ site.baseurl }}/exercises/03-lab-var/)

### Defining value labels

Variable labels describe the variable. Value labels describe what the numbers inside that variable mean.

Typical use cases:
* Binary indicators: 0 = no, 1 = yes
* Sex: 0 = male, 1 = female (or other encodings)
* Likert scales: 1 = strongly disagree … 5 = strongly agree
* Categories: 1 = urban, 2 = rural, etc.

There are two steps for value labels
1. Define a value label (i.e., the mapping from numbers → text)
2. Apply that value label to one or more variables

The syntax for defining a value label is a little tricky and I almost never remember it, so I have to use the drop down menu to get Stata to generate a little example and then I edit that example and place it in my code.

```stata
label define lblname # "label" [# "label" ...]
```

Here the syntax is:
* `label define` or `lab def` tells Stata you are defining a label for later use
* `lblname` is the name of the value label set (you choose this)
* `#` is a numeric value (e.g., 0, 1, 2, 5)
* `"label"` is the text you want Stata to display for that numeric value

In our practice example, we would define a value label for use with the variable `sex` by writing:

```stata
* define label for sex
    lab def     sex_lbl 0 "Male" 1 "Female"
```

This creates a mappin `0 → "Male"`, `1 → "Female"`. It does **not** attach this mapping to any variable

> Do [Exercise 3.1 - Label Values]({{ site.baseurl }}/exercises/03-label-vals/)

### Apply value label