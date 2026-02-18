* course: AAE 497A/597A
* assignment: 6.3
* created on: feb 26
* created by: jdm
* edited on: 18 feb 26
* edited by: jdm
* Stata v.19.5

* define the cutoff (in hectares) and construct the indicator
	global 			plot_cutoff_ha 1

	use				"$data/eth_allrounds_final.dta", clear

* create large plot cut off
	gen 			large_plot = plot_area_GPS > $plot_cutoff_ha
	lab var 		large_plot "Plot > $plot_cutoff_ha ha"
