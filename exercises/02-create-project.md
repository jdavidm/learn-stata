---
layout: exercise
topic: Style & Execution
title: Create Project Do
language: Stata
---

For this exercise we are going to create a `project.do` file that we will use on this and all subsequent assignments.

1\. Open your Stata Project and in the blank `.do` file editor start by typing in our standard preamble (using either 497 or 597 for course).

```stata
* course: AAE 597A
* created on: dec 25
* created by: jdm
* edited on: 16 dec 25
* edited by: jdm
* Stata v.19.5
```

2\. Then type in a a bulletted list of what this file does and what it assumes that a user has on their computer. This part of the preamble isn't required for assignments, since what an assignment `.do` file does and assumes is pretty self explanatory. But when you start doing research, having a list of what a file does, assumes, and if the file is complete (`TO DO`) is very useful. It allows you (or your advisor) to quickly see what a file contains without reading through the code.

```stata
* does
	* establishes identical development environment for users
	* sets globals that define absolute paths
	* loads any user written packages needed for analysis
	* runs all assignment do-files

* assumes
	* access to all data and code

* TO DO:
	* done
```

3\. Next, create the `0 - setup` section that comes after the preamble in every file that you write. Typically this is where we set our relative paths. But for the `project.do` file we are going to start by creating a `global` called `pack` (short for package) and we will set the value of `pack` to `0`. We will call this `global` later in the `project.do` file. After we create `pack` we want to specify which version of Stata the code runs on.

```stata
******************************************************************
**# 0 - setup
******************************************************************

* set $pack to 0 to skip package installation
	global 			pack 	0
		
* Specify Stata version in use
    global          stataVersion 19.5
    version         $stataVersion
```

4\. Now we will use a combination of `local` and `global` macros, along with a conditional `if` statement, to dynamically set the working directory.
    * The `if` statement will define the global `code` and `data` as absolute paths, depending on which computer the code runs on
    * The `c(username)` local checks to see what the computer's username is (`c(username)`)
    * The global `code` is assigned a value that equals the absolute path on the machine `jdmichler` to the git repo where the code lives
    * The global `data` is assigned a value that equals the absolute path on the machine `jdmichler` to the cloud-based storage system where the data lives
    	* Since git syncs repos with the cloud, it is redundant to store code on a cloud-based storage system
    	* This is not true for data, so make sure you save data to Dropbox, OneDrive, Google Drive, Box, or some other storage system that syncs or backs up to the cloud
	* In addition to defining the globals `code` and `data` for your own machine, make sure you also define them for my office desktop (`jdmichler`) and my laptop (`jdmic`) as written below.
		* This will allow me to run your code on my machine without changing any of your code.

```stata
******************************************************************
**## 0.1 - Create user specific paths
******************************************************************

* Define root folder globals
	if `"`c(username)'"' == "jdmichler" {
		global	code	"C:/Users/jdmichler/git/semester26"
		global	data	"C:/Users/jdmichler/dropbox/semester26/data"
	}

	if `"`c(username)'"' == "jdmic" {
		global	code	"C:/Users/jdmic/git/semester26"
		global	data	"C:/Users/jdmic/dropbox/semester26/data"
	}
```

5\. Add an additional section (call it `**# 1 - run assignment files`) to the `project.do` file that runs or executes assignment 2 so that when I check your work I only have to run the `project.do` file and it sets the development environment and runs all the code you wrote for assignment 2. This is what is known as "push button replicability." To do this, you need to use the `do` command and write out the relative path for the location of assignment 2. The path will be "relative" to the absolute path defined in `code` so it should start with the global `$code`.

