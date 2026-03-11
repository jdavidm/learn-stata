* course: AAE 497A/597A
* created on: dec 25
* created by: jdm
* edited on: 16 dec 25
* edited by: jdm
* Stata v.19.5

* does
	* establishes identical development environment for users
	* sets globals that define absolute paths
	* loads any user written packages needed for analysis
	* runs all assignment do-files

* assumes
	* access to all data and code

* TO DO:
	* done


******************************************************************
**# 0 - setup
******************************************************************

	clear			all

* set $pack to 0 to skip package installation
	global 			pack 	0
		
* Specify Stata version in use
    global          stataVersion 19.5
    version         $stataVersion


******************************************************************
**## 0.1 - Create user specific paths
******************************************************************

* Define root folder globals
	if `"`c(username)'"' == "jdmichler" {
		global	code	"C:/Users/jdmichler/git/learn-stata/code"
		global	data	"C:/Users/jdmichler/git/learn-stata/data"
		global	answ	"C:/Users/jdmichler/git/learn-stata/solutions"
		global	logout	"C:/Users/jdmichler/dropbox/teaching/AAE 597/logs"
	}

	if `"`c(username)'"' == "jdmic" {
		global	code	"C:/Users/jdmic/git/learn-stata/code"
		global	data	"C:/Users/jdmic/git/learn-stata/data"
		global	answ	"C:/Users/jdmic/git/learn-stata/solutions"
		global	logout	"C:/Users/jdmic/dropbox/teaching/AAE 597/logs"
	}


******************************************************************
**## 0.2 - Check if any required packages are installed
******************************************************************

* install packages if global is set to 1
if $pack == 1 {
	
	* for packages/commands, make a local containing any required packages
    * temporarily set delimiter to ; so can break the line
    #delimit ;		
	loc userpack = "blindschemes unique mdesc estout palettes reghdfe ftools 
					mrtab distinct winsor2 catplot colrspace ivreg2 ranktest
					carryforward missings xtivreg2 fre coefplot colrspace
					joyplot schemepack heatplot ridgeline graphfunctions labutil 
					eventstudyinteract avar grc1leg2" ;
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

*	do				"$code/01-intro.do"	
*	do				"$code/02-using-stata.do"
*	do				"$code/03-data-mgmt.do"
*	do				"$code/04-data.do"
*	do				"$code/05-datarlt.do"
*	do				"$code/06-programming.do"
*	do				"$code/07-solving.do"
*	do				"$code/08-design.do"
*	do				"$code/09-regress.do"
*	do				"$code/10-results.do"