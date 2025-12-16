---
layout: exercise
topic: Style & Execution
title: Create Project Do
language: Stata
---

For this exercise we are going to create a `project.do` file that we will use on this and all subsequent assignments.

1. Open your Stata Project and in the blank `.do` file editor start by typing in our standard preamble

```stata
* course: 597A
* created on: dec 25
* created by: jdm
* edited on: 16 dec 25
* edited by: jdm
* Stata v.19.5
```
2. Then type in a a bulletted list of what this file does and what it assumes that a user has on their computer. This part of the preamble isn't required for assignments, since what an assignment `.do` file does and assumes is pretty self explanatory. But when you start doing research, having a list of what a file does, assumes, and if the file is complete (`TO DO`) is very useful. It allows you (or your advisor) to quickly see what a file contains without reading through the code.

```stata
* does
	* establishes an identical development environment between users
	* sets globals that define absolute paths
	* loads any user written packages needed for analysis
	* runs all assignment do-files

* assumes
	* access to all data and code

* TO DO:
	* done
```

3. Next, create the `0 - setup` section that comes after the preamble in every file that you write. Typically this is where we set our relative paths. But for the `project.do` file we are going to start by creating a `global` called `pack` (short for package) and we will set the value of this `global` to `0`. We will call this `global` later in the `project.do` file. After we create `pack` we want to specify which version of Stata the code runs on.

```stata

************************************************************************
**# 0 - setup
************************************************************************

* set $pack to 0 to skip package installation
	global 			pack 	0
		
* Specify Stata version in use
    global          stataVersion 19.5
    version         $stataVersion


************************************************************************
**## 0.1 - Create user specific paths
************************************************************************


* Define root folder globals
    if `"`c(username)'"' == "jdmichler" {
        global 		code  	"C:/Users/jdmichler/git/irri_strv"
		global 		data	"C:/Users/jdmichler/dropbox/irri_strv/SPIA_RMS"
    }

    if `"`c(username)'"' == "jdmic" {
        global 		code  	"C:/Users/jdmic/git/irri_strv"
		global 		data	"C:/Users/jdmic/dropbox/irri_strv/SPIA_RMS"
    }


************************************************************************
**## 0.2 - Check if any required packages are installed:
************************************************************************

* install packages if global is set to 1
if $pack == 1 {
	
	* for packages/commands, make a local containing any required packages
    * temporarily set delimiter to ; so can break the line
    #delimit ;		
	loc userpack = "blindschemes unique mdesc estout palettes reghdfe ftools 
					mrtab distinct winsor2 catplot colrspace ivreg2 ranktest
					carryforward missings xtivreg2 fre coefplot colrspace
					joyplot schemepack heatplot ridgeline graphfunctions labutil 
					eventstudyinteract avar" ;
    #delimit cr
	
	* install packages that are on ssc	
		foreach package in `userpack' {
			capture : which `package', all
			if (_rc) {
				capture window stopbox rusure "You are missing some packages." "Do you want to install `package'?"
				if _rc == 0 {
					capture ssc install `package', replace
					if (_rc) {
						window stopbox rusure `"This package is not on SSC. Do you want to proceed without it?"'
					}
				}
				else {
					exit 199
				}
			}
		}

	* install -xfill and dm89_1 - packages
		net install xfill, 	replace from(https://www.sealedenvelope.com/)
		
	* update all ado files
		ado update, update

	* set graph and Stata preferences
		set scheme plotplain, perm
		set more off
}


************************************************************************
**# 1 - run assignment files
************************************************************************

	do				"$code/assignments/assignment_1.do"
```

