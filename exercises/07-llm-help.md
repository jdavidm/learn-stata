---
layout: page
element: exercise
title: LLM Help
language: Stata
---

### Overview

In this exercise you will practice using a **large language model (LLM)** (e.g., ChatGPT, Copilot) to help debug or understand a small piece of Stata code.

The point is not to have the LLM do the assignment for you. Instead, you will:

1. Write a short piece of Stata code that actually **produces an error or surprising result** when run with `plot_dataset.dta`.
2. Ask an LLM for help understanding and fixing that specific issue.
3. Implement the fix and verify it works.
4. Reflect on how helpful the LLM was.

### Instructions

In your assignment `.do` file, create a new section:

```stata
**********************************************************************
**# exercise 7 - llm help
**********************************************************************
```

Then complete the steps below.

---

### Step 1 – Write a minimal reproducible example

Create a small code block (about 10–20 lines) that:

- loads `plot_dataset.dta`,
- does something non-trivial (e.g., generates a new variable, runs a command),
- results in **an error** (e.g., type mismatch, “no observations”) or a clearly **wrong-looking result**.

Example structure (you should create your own bug):

```stata
**## 7.1 - minimal reproducible example

* load data
    use             "$root/plot_dataset.dta", clear

* do something that produces an error or strange result
    * (your code goes here)
```

Run this block and confirm that it fails or produces unexpected output.

---

### Step 2 – Ask an LLM for help

Outside of Stata, open an LLM (e.g., ChatGPT, Copilot) and:

1. Explain briefly what you are trying to do.
2. Paste your short code snippet.
3. Include the **exact error message** or describe the unexpected result.

In your `.do` file, summarize what you asked:

```stata
**## 7.2 - what i asked the llm

* in 2–4 sentences, summarize:
* - what task you described
* - what code you showed
* - what error or odd behavior you reported
```

Do **not** paste the full conversation into your `.do` file—just your own summary.

---

### Step 3 – Summarize the LLM’s response

In comments, summarize what the LLM told you:

```stata
**## 7.3 - what the llm said

* in 2–4 sentences, summarize:
* - what the llm thought the problem was
* - what fix or explanation it suggested
```

Try to restate the explanation in your *own* words so you really understand it.

---

### Step 4 – Implement the fix and verify

Write a corrected version of your code, using the LLM’s suggestion (possibly with your own modifications):

```stata
**## 7.4 - fixed version and checks

* load data
    use             "$root/plot_dataset.dta", clear

* fixed code goes here
    * ...

* add at least one check
    sum             some_variable
    *** brief comment confirming the result now makes sense
```

You should:

- re-run from the top of the exercise section, and
- use `describe`, `sum`, `tab`, `list`, or `browse` to confirm that the behavior is now correct.

---

### Step 5 – Reflect on the LLM’s usefulness

At the end of this exercise section, add a short reflection:

```stata
* reflection:
* - was the llm's first suggestion correct?
* - did it misunderstand anything about the problem or the data?
* - what did you still have to figure out on your own?
```

### Deliverables

By the end of this exercise, your `.do` file should contain:

- A house-style heading for Exercise 7.
- A minimal reproducible example that actually fails or misbehaves.
- Comments summarizing your LLM prompt and the LLM’s response.
- A fixed version of your code with at least one diagnostic check.
- A short reflection on how useful the LLM was and what its limitations were.
