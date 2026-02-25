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

Copy and paste the following code into your `.do` file. 

```stata
* load data
	use             "$data/plot_dataset.dta", clear

* keep maize only (main_crop is string)
	keep            if main_crop == MAIZE

* base restrictions
	keep            if plot_area_GPS > 0
	keep            if harvest_kg < .
	drop            if harvest_kg <= 0

* get list of countries
	levelsof        country, local(countries)

* make sure grc1leg2 is available
	cap which       grc1leg2
	if              _rc != 0 {
		net         install grc1leg2, ///
					from("https://fmwww.bc.edu/RePEc/bocode/g") ///
					replace
	}

* locals to store graph names (separate lists)
	local           glist_rf ""
	local           glist_ir ""

	local           leg_rf   ""
	local           leg_ir   ""

* loop over countries and irrigation status (0/1)
foreach `c' of local countries {

	foreach irr in 0 1 {

		preserve

		* restrict to this country + irrigation group
			keep if 		country == `c' & ///
								irrigated = `irr'

		* skip empty groups
			count
			if              r(N) = 0 {
				restore
				continue
			}

		* winsorize harvest (p1-p90 within group)
			_pctile         harvest_kg p(1 90)
			local           p1  = r(r1)
			local           p90 = r(r2)

			gen             harvest_kg_g = harvest_kg
			replace         harvest_kg_g = `p1'  ///
								if harvest_kg_g < p1
			replace         harvest_kg_g = `p90' ///
								if harvest_kg_g > `p90'
			lab var         harvest_kg_g "harvest winsorized (p1-p90)"

		* labels + short graph name
			local           irr_lbl "rainfed"
			if              `irr' == 1 local irr_lbl irrigated

			local           gname "g_ma_`c'_`irr"

		* color schemes by irrigation status
			local           mcol ""
			local           lcol1 ""
			local           lcol2 ""

			if              `irr' == 0 {
				local       mcol  "navy%25"
				local       lcol1 "midblue"
				local       lcol2 "eltblue"
			}
			if              `irr' == 1 {
				local       mcol  "dkgreen%25"
				local       lcol1 "forest_green"
				local       lcol2 "lime"
			}

		* create graph (do not export individual files)
			twoway         (scatter harvest_kg_g plot_area_GPS ///
								msize(tiny) mcolor(`mcol') ) ///
							(lfit harvest_kg_g plot_area_GPS, ///
								lcolor(`lcol1') lw(medthick) ) ///
							(lowess harvest_kg_g plot_area_GPS, ///
								lcolor(`lcol2') lw(medthick) ///
								bwidth(.8)), ///
							title("Harvest vs. plot area: `c' (`irr_lbl')", ///
								size(small))
							xtitle("plot area (gps)", ///
								size(small)) ///
							ytitle("harvest (kg)", ///
								size(small) margin(small)) ///
							xlabel(, labsize(small)) ///
							ylabel(, labsize(small)) ///
							legend(order(1 "plots" 2 "linear fit" ///
								3 "lowess") ///
								rows(1) position(3) ring(0) ///
								region(lstyle(none)) ) ///
							name(`gname' replace)

		* add graph to the appropriate combine list
			if              `irr' == 0 {
				if          "`glist_rf'" == "" local leg_rf "`gname'"
				local       glist_rf `"`glist_rf' `gname'"'
			}
			if              `irr' == 1 {
				if          "`glist_ir'" == "" local leg_ir "`gname'"
				local       glist_ir `"`glist_ir' `gname'"'
			}

		restore
	}
}

* combine rainfed graphs
	grc1leg2        `glist_rf', ///
						col(2) row(`rows_rf') ///
						xcommon ycommon ///
						imargin(tiny) ///
						graphregion(margin(zero)) ///
						legendfrom(`leg_rf')

	graph           export "$answ/07-llm-help-2.pdf" replace

* combine irrigated graphs
	grc1leg2        `glist_ir', ///
						col(2) row(`rows_ir') ///
						xcommon ycommon ///
						imargin(tiny) ///
						graphregion(margin(zero)) ///
						legendfrom(`leg_ir')

	graph           export "$answ/07-llm-help-3.pdf" replace
```

1\. Run this block and confirm that it fails or produces unexpected output. What is the first error message do you get?

2\. Outside of Stata, open an LLM (e.g., ChatGPT, Copilot) and:
- Explain briefly what you are trying to do.
- Paste your short code snippet.
- Include the exact error message or describe the unexpected result.

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

3\. Write a corrected version of your code, using the LLM’s suggestion (possibly with your own modifications)