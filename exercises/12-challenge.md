---
layout: exercise
topic: Difference-in-Differences
title: Challenge 12
language: Stata
---

This challenge combines Difference-in-Differences with a Monte Carlo (MC) simulation and ridgeline plots to explore how measurement error attenuates regression estimates. The data is also from the [Impact evaluations in data-scarce environments](https://doi.org/10.1016/j.jdeveco.2025.103648) paper though it is a different dataset. By the end of the exercise you will have replicated Figure 2 in that paper. First, you will estimate a baseline model, add simulated noise to a continuous variable, and visualize the loss of statistical significance using `joyplot`.

#### Part 1 — Baseline Regression and Coefplot

- Download the `mc_data.dta` dataset from the course webpage and then load it into Stata.
- Regress yield on:
  - the indicator variables for if the rice variety is swarna-sub1, is another modern variety, and is a traditional variety, 
  - the interactions between the three variety indicators and the flood indicators, 
  - the indicator for if the flood was greater than 12 days and that variable interacted with if the variety is swarna-sub1, 
  - fixed effects for group(block), 
  - and cluster standard errors at the village level.
- Store the results using `eststo baseline`.
- Use `coefplot` to visualize the coefficients. Keep only the flood variables and the flood-variety interaction terms. Format the plot cleanly, include a vertical reference line at $0$, export it, and import it into your Overleaf document.

#### Part 2 — Monte Carlo Simulation (Measurement Error)

Now, we will test how robust the `subfld` coefficient is if we assume the continuous outcome variable (`yield`) is measured with error. To do this, we are going to use Stata's custom program function. We will write a program that adds normally distributed noise to `yield` and then runs the same regression as in Part 12.1. We will then loop through different levels of noise and store the results. We've not dealt with programs before but it is covered in a [lecture in week 6]({{ site.baseurl }}/materials/06-programs). [Note that the entire Monte Carlo simulation takes about **20 minutes** to run on my machine.]

- Start by ensuring no other program is running using `capture program drop yld_reg`.
- Set up a `program` called `yld_reg` that is an `rclass` program. Close the program using `end`.
- Within the program (between `program` and `end`)
  - Create an argument (`args`) that accepts a noise parameter `np`.
  - Calculate the mean and standard deviation of `yield` using `sum` and save these as locals called `y_mean` and `y_sd`.
  Multiply these by `np` to get the error mean and standard deviation. Save these asl locals called `ymm` and `ysd`.
  - Replace `yield` with `yield` plus some random noise that is normally distributed (`rnormal()`) with mean 0 and standard deviation `ysd`.
  - Replace `yield` again but this time set `yield = 0` if `yield` is less than 0. This is to ensure values of yield do not fall below 0.
  - Run the exact same baseline regression from Part 12.1.
- Now we will run the Monte Carlo simulation using a single loop. This goes after you've used `end` to close the program.
  - Start by clearing memory and creating an empty temporary file (`building`) to collect our results in.
  - The simulation will loop through noise levels from 0% to 10% by increments of 1%. Within the loop:
    - Convert your loop index to a percentage (`local i = j/100`).
    - Load the raw dataset (`use "$data/mc_data", clear`) so `simulate` begins with a fresh copy of the data.
    - The `simulate` command acts as an inner loop. It will run the `yld_reg` program 5,000 times for the current noise level (`reps(5000)`), capturing the coefficients (`_b`), standard errors (`_se`), degrees of freedom (`dfr`), and returned mean (`mean`).
    - Because we purposefully don't supply a `saving()` option, `simulate` will just overwrite our memory with a database of its 5,000 runs! We simply mark these specific results with our current noise parameter (`gen noise = `i'`), append them into our empty `building` tempfile, and save over `building` with the newly augmented list. 

```stata
* prepare an empty file for results
	clear
	tempfile 		building
	save 			`building', emptyok

* run mc simulations
	set				seed 5762
	forvalues 		j = 0/10 {
		local 			i = `j'/100
		
		* load data and run simulation for current noise level
		use 			"$data/mc_data.dta", clear
		simulate 		_b _se dfr=(e(df_r)) mean=r(mean), ///
							reps(5000): yld_reg `i'
							
		* add noise indicator and append to master results file
		gen 			noise = `i'
		append 			using `building'
		save 			`"`building'"', replace
	}
```

- Now that we have a data set of all the results, let's clean it up a bit.
 - Rename `_eq2_dfr` as `dfr` and rename `_eq2_mean` as `mean`.
 - Create a variable (`t_subfld`) that holds the t-statistic for the `subfld` coefficient, calculated as `_b_subfld / _se_subfld`.
 - Create a variable (`p_subfld`) that holds the two-tailed p-value for the `subfld` coefficient, calculated as `2 * ttail(dfr, abs(t_subfld))`.
 - Create a variable (`sig`) that is equal to 1 if `p_subfld` is less than or equal to 0.05, is 0 otherwise, and is missing when `p_subfld` is missing.
 - To help with the visuals in the graphic, replace `noise` with 100 times itself.
 - Use the following loop to label the `noise` variable:

```stata
* label stuff for graph
	capture label drop noise
	forvalues i = 0/20 {
		if `i' < 10 {
        label define noise `i' "0.0`i'{&sigma}", add
		}
    else {
        label define noise `i' "0.`i'{&sigma}", add
		}
	}
	label values	noise noise
```

How many regressions did we just run in total?

#### Part 3 — Visualize P-Value Attenuation

- Use `joyplot` to visualize the distribution of `p_subfld` grouped by the `noise` level. Include the following options to match the example plot exactly:
  - Add horizontal lines for each group using `yline`.
  - Set the kernel density bandwidth to 0.01 using `bwid()` and normalize the density curves so each group has equal height using `norm(local)`.
  - Scale the density curves nicely using `rescale` and allow the density curves to overlap vertically up to 2 times using `overlap()`.
  - Set the transparency (alpha) of the curves to 60% using `alpha()`.
  - Set the x-axis labels from 0 to 1 in increments of 0.1 using `xlabel()`.
  - Set the x-axis title to "p-values" using `xtitle()`.
  - Use the 'crest' color palette using `palette()`.
  - Set the y-axis title to "Amount of Added Noise in Yield Measure" and add a right margin (`margin(r=4)`) after the title but within the `ytitle()` option.
  - Add a vertical line at 0.05 (`xline(0.05, lcolor(maroon))`) so that we can see what portion of the distribution falls outside significance.
  - Use the `white_tableau` scheme or similar to format the plot nicely.
- Export your ridgeline plot and import it into your Overleaf document.

Looking at your final ridgeline plot, as the amount of added noise to the yield measure increases, what happens to the distribution of p-values? At approximately what percentage of added noise do we entirely lose statistical significance at the 5% level?

---
