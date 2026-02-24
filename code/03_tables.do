* course: AAE 497A/597A
* assignment: 6.3
* created on: feb 26
* created by: jdm
* edited on: 18 feb 26
* edited by: jdm
* Stata v.19.5


* print cut off value
	di 				"=== TABLES FOR CUTOFF = $plot_cutoff_ha ha ==="

* tabulate data
	tab 			large_plot

	describe 		large_plot
	
