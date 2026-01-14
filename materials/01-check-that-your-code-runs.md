---
layout: page
element: notes
title: Check That Your Code Runs
language: Stata
---

### Setup

> Make sure that you open your Stata Project first, then run the project.do file every time

### Introduction to Reproducibility

* Goal - rerun full analysis with a single click (or command)
* First step - Make sure your code runs anytime and anywhere
  * next day (who has gotten code working & had it not work the next day?)
	* desktop vs. laptop
	* collaborators
	* advisor

### Make sure things you did before don't matter

* Computers store the results of each command run in sequence
* Change something
* Looks like it still works
* Only works because of something you did earlier in the same session

### Clearing environments and restarting Stata

* Clear Stata environment using `clear`.
  * removes data in memory
  * does not clear globals, macros, program, etc.
* Clear Stata environment using `clear all`
  * provide a complete reset of the Stata environment
  * removes data in memory
  * removes globals, macros, or anything else that Stata was keeping in memory
* Safest thing is to `clear all`
* Then run the entire file using the execute button or `Ctrl+D`
* Ensures that the code runs fully and produces desired result
* Last required exercise of every assignment will walk you through this process

### Check every assignment

* To reinforce this important step in coding the last required exercise each week is the check that your code runs
> *Show last exercise of first assignment*
* This will remind you to check that everything is running and fix any issues
* It will also make grading much easier because when I run your code it will run
* At the start of the semester if the code doesn't run when I go grade I'll DM you on Slack and give you a chance to fix it before grading
