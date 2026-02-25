---
layout: exercise
topic: Problem Solving
title: LLM Help
language: Stata
---

In this exercise you will practice using a **large language model (LLM)** (e.g., ChatGPT, Copilot) to help debug or understand a small piece of Stata code. The point is not to have the LLM do the assignment for you. Instead, you will:
- Write a short piece of Stata code that actually produces an error or surprising result when run with `plot_dataset.dta`
- Ask an LLM for help understanding and fixing that specific issue
- Implement the fix and verify it works

1\. Copy and paste the following code into your `.do` file. Run this block and confirm that it fails or produces unexpected output. What error message do you get?

2\. Outside of Stata, open an LLM (e.g., ChatGPT, Copilot) and:
- Explain briefly what you are trying to do.
- Paste your short code snippet.
- Include the **exact error message** or describe the unexpected result.

In your `.do` file, summarize what you asked and the LLM's response. Do **not** paste the full conversation into your `.do` file—just your own summary.

```stata
**## 7.2 - what i asked the llm

* in 2–4 sentences, summarize:
* - what task you described
* - what code you showed
* - what error or odd behavior you reported
* - what the llm thought the problem was
* - what fix or explanation it suggested
```

3\. Write a corrected version of your code, using the LLM’s suggestion (possibly with your own modifications). You should:
- re-run from the top of the exercise section, and
- use `describe`, `sum`, `tab`, `list`, or `browse` to confirm that the behavior is now correct.
