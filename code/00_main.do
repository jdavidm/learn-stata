* course: AAE 497A/597A
* assignment: 6.3
* created on: feb 26
* created by: jdm
* edited on: 18 feb 26
* edited by: jdm
* Stata v.19.5

	clear

* run replication code
	do 				"$code/01_cleaning.do"
	do 				"$code/02_revise.do"
	do 				"$code/03_tables.do"