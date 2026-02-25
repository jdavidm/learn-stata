---
layout: page
element: notes
title: Searching for Help
language: Stata
---

### Everyone searches for help

* Professional programmers and applied economists **constantly** look things up.
* You are *not* expected to memorize every command and option in Stata.
* You *are* expected to learn how to:
    * Search effectively
    * Read help pages and online answers
    * Adapt examples safely to your own work

Today we’ll focus on three sources:
1. Built-in Stata help and documentation
2. Online help (Stata docs, Statalist, Stack Overflow, blogs)
3. Large Language Models (LLMs) like ChatGPT

### Built-in Stata help

Before you open a browser, try Stata’s own tools.

#### `help` for a specific command

```stata
* open the help file for summarize
    help            summarize
```

* Shows syntax
* Lists options
* Often includes examples at the bottom (pay attention to these)

If you know roughly what you want but not the exact syntax (e.g., `xtile`, `merge`, `collapse`), `help` is your friend.

#### `search` for related commands

```stata
* search for commands related to "percentile"
    search          percentile
```

This looks through:
* Command names and descriptions
* Installed help files
* Sometimes user-written packages

You can click on entries in the Viewer to open help pages.

> Habit to build: when you see a new command in lecture or sample code, run `help commandname` and skim the help file.

#### Good targets for Stata help

Places where `help`/`search` are especially useful:

* Basic data management commands
    * `help generate`, `help replace`, `help egen`
    * `help merge`, `help append`, `help collapse`
* Graphics
    * `help graph`, `help histogram`, `help twoway`
* Common analysis commands
    * `help regress`, `help ttest`

When debugging, also consider `help r(###)` for error codes.

> Do [Exercise 5 - Stata Help]({{ site.baseurl }}/exercises/07-s-help/)

### Online Stata resources

Some high-value websites:

1. Official Stata documentation
    * Mirrors the `help` system
    * Searchable on the web
    * Very precise, includes lots of examples
2. Statalist
    * Long-running forum where people ask detailed Stata questions
    * Often your exact error or task has been discussed
3. Stack Overflow / Cross Validated
    * More general programming/stats Q&A
    * Stata content mixed in with R, Python, etc.

### How to search effectively

When you go to Google (or DuckDuckGo, etc.), your goal is to express your problem in **search-engine language**. One thing I've learned in 10 years of teaching is that students often struggle with developing useful prompts or key-words for searches. *The returns you get from a search are only as good as what you ask it to search for*.

#### Get the vocabulary right

Include:
* `stata`  
* The command (if you know it)  
* A short phrase about what you want  
* Or the error code

Good examples:
* `stata collapse mean by group`
* `stata merge 1:m not uniquely identified`
* `stata graph bar mean by group`
* `stata r(111) variable not found`

Less good:
* `collapse not working`
* `missing unique identifier`
* `how do I write bar graph code?`
* `stata help please`

#### Avoid extra words

Start simple:
* `stata reshape wide long example`
* `stata -999 missing value`

You can always add words if results are off.

### Reading results: help sites, forums, blogs

When you click a search result:

#### Help sites / Q&A (Statalist, Stack Overflow)

1. Read the question carefully
    * Does it sound like your situation?
    * Same command? Same type of data?
2. Look at the setup
    * Are they reshaping wide-to-long or long-to-wide?
    * Are their variable names similar?
3. Check the age
    * Stata syntax is fairly stable, but a 2003 post may reference ancient versions
4. Check the top answers
    * On Stack Overflow, higher-voted answers are usually better
    * On Statalist, look for answers from known experts
5. Glance at the comments
    * Sometimes corrections or caveats are discussed there
6. Test and modify the example
    * Never copy-paste blindly
    * Adapt variable names and paths to your data
    * Confirm that the code does what you think it does

#### Blog posts and tutorials

1. Scan for the section you need
    * Use your browser’s `Find` (`Ctrl+F` / `Cmd+F`)
    * Search within the page for “merge”, “collapse”, etc.
2. Focus on code blocks
    * They usually contain the key ideas
    * Try to understand them, then rewrite into **house style** before using

### Testing and integrating code you find

When you grab code from online (or from an LLM):

1. Try it on a small subset
    * Add `in 1/50` or a restrictive `if` to avoid damaging your whole dataset
2. Watch for paths and filenames
    * Change `"C:\Users\someone\Downloads\mydata.dta"` to your project paths and globals
3. Check for version issues
    * Some commands/options only exist in newer versions of Stata
    * If you see `version` lines in example code, pay attention
4. Check that it respects course rules
    * Doesn’t overwrite raw data
    * Keeps data and code separated
    * Fits into your project structure (globals, logs, etc.)
5. Rewrite in your own words and style
    * Rename variables to match the rest of your project
    * Add comments in your own language
    * Use house-style alignment and headings

> Do [Exercise 6 - Online Help]({{ site.baseurl }}/exercises/07-o-help/)

### Using LLMs as a help resource

LLMs (ChatGPT, Copilot, etc.) are like a very fast, sometimes-wrong search engine that can write code.

* They are good at:
    * Explaining error messages
    * Suggesting possible approaches
    * Pointing out obvious bugs in short code snippets
* They are **not always**:
    * Correct about Stata syntax
    * Efficient in their approach to coding
    * Aligned with our house style
    * Using the same workflow (projects, `project.do`, etc.)

**How to ask good questions to an LLM:**

Include:
1. A short description of your goal
2. A minimal code snippet (10–20 lines)
3. The exact error message or unexpected output
4. Any constraints (e.g., “Stata 17, cannot use user-written packages”)

Example prompt:

> "I'm using Stata 17. I’m trying to merge household-level data into plot-level data. Here's my code and the error `not uniquely identified`. Can you help me understand what's wrong?"

Then:
* Check its explanation against your understanding of `merge` (`1:m` vs `m:1`, keys, etc.)
* Test any suggested fix on a small subset
* Rewrite any accepted code into your own `.do` file with house style

Remember the **forklift at the gym** analogy: don’t have the LLM do all your “lifting” for you.

> Do [Exercise 7 - LLM Help]({{ site.baseurl }}/exercises/07-llm-help/)

### When and how to ask humans

Sometimes the fastest path is to ask a person:

* Classmates / study groups
    * Great for “am I doing this in a reasonable way?” type questions
* Slack
    * Include a short description and a small, well-formatted code block
    * Mention the exact error message
* Office hours
    * Bring your `.do` file
    * Be ready to walk through what you’ve already tried

A good question includes:
* What you’re trying to do
* What you expected to happen
* What actually happened (including errors)
* What you’ve already tried based on help files / Google / LLMs
* The file name and exact lines of code that are a problem
* **Before you ask for help, push your commits so the person can actually help you!**

> Do [Exercise 7 - LLM Help]({{ site.baseurl }}/exercises/07-llm-help/)

### Summary: a help-searching workflow

When you’re stuck:
1. Try Stata help
    * `help command`
    * `search keyword`
2. Search the web
    * Include `stata` + command + a keyword or error
3. Read answers critically
    * Understand before copying
    * Adapt to your project and house style
4. Test on small subsets
5. Use LLMs as assistants, not oracles
6. Ask humans (Slack, office hours) with a clear, specific question

The goal is not just to “find the code” but to **build your own library of patterns** for solving problems in Stata.
