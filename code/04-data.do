* course: AAE 497A/597A
* assignment: 4
* created on: jan 25
* created by: jdm
* edited on: 27 jan 26
* edited by: jdm
* Stata v.19.5
	
* open log
	cap log 		close
	log using		"$logout/04-data", append
	
	
********************************************************************************
**# exercise 1
********************************************************************************

* load national longitudinal survey of young women
    sysuse			nlsw88, clear
	
**## 1.1.1 & 1.1.2 & 1.1.3
	tab				race
	
**## 1.2.1 & 1.2.2
	tab				union, missing
	
	
********************************************************************************
**# exercise 2
********************************************************************************

**## 1.1.1 & 1.1.2 & 1.1.3
	sum				wage
	
**## 1.2.1 & 1.2.2
	sum				wage, detail
	
**## 1.3.1 & 1.3.2
	sum				wage if collgrad == 1
						
						
********************************************************************************
**# exercise 3
********************************************************************************

**## 3.1
	sum				hours
	display			r(max) - r(min)

**##3.2
	sum				hours, detail
	display			r(p75) - r(p25)
	
		
********************************************************************************
**# exercise 4
********************************************************************************

**## 4.1
	hist			hours, percent
	graph export	"$answ/04-hist-1.png", replace
	
**## 4.2
	hist			hours, bin(10) percent
	graph export	"$answ/04-hist-2.png", replace
				
**## 4.3
	hist			hours, start(0) width(5) percent
	graph export	"$answ/04-hist-3.png", replace
	
**## 4.4
	hist			grade, frequency
	
	hist			grade, discrete frequency
	graph export	"$answ/04-hist-4.png", replace


********************************************************************************
**# exercise 5
********************************************************************************

**## 5.1
    kdensity 		ttl_exp
	graph export	"$answ/04-dens-1.png", replace
	
**## 5.2
    kdensity 		ttl_exp, bwidth(1)
	graph export	"$answ/04-dens-2.png", replace

**## 5.3
    kdensity 		ttl_exp, bwidth(3)
	graph export	"$answ/04-dens-3.png", replace

**## 5.4
    kdensity 		ttl_exp, normal
	graph export	"$answ/04-dens-4.png", replace

**## 5.5	
	twoway 			(histogram ttl_exp, bin(20) percent color(%60)) || ///
						(kdensity ttl_exp), ///
						title("Distribution of total work experience") ///
						xtitle("Total work experience (years)") ///
						ytitle("Percent of workers")  ///
						legend(order(1 "Histogram" 2 "Kernel density") ///
						pos(6) col(2))
	graph export	"$answ/04-dens-5.png", replace
	
		
********************************************************************************
**# exercise 6
********************************************************************************

* create scalars of mean and sd of wage
	summ			wage
	scalar 			m_wage = r(mean)
	scalar 			v_wage = r(Var)

	di 				m_wage
	di 				v_wage

* create scalars for mean and sd for new distribution
	scalar 			sig2 = ln(1 + v_wage/(m_wage^2))
	scalar 			sig  = sqrt(sig2)
	scalar 			mu   = ln(m_wage) - 0.5*sig2

	di 				"mu = " mu
	di 				"sigma = " sig

* simulate from the matched log-normal
	set 			seed 8675309
	gen 			wage_logn = exp(rnormal(mu, sig))

**## 6.1	
	twoway 			(kdensity wage_logn) 
	graph export	"$answ/04-rando-1.png", replace
	
	
**## 6.2
	twoway 			(kdensity wage_logn) || ///
						(kdensity wage), ///
						legend(order(1 "Simulated log-normal" ///
						2 "Observed wage") ///
						col(2) pos(6))
	graph export	"$answ/04-rando-2.png", replace
	

********************************************************************************
**# exercise 7
********************************************************************************

**## 7.1
	
* summarize data
	sum             wage, detail

* store values as locals
	local           p5  = r(p5)
	local           p95 = r(p95)
	
* display output
	display        "5th percentile of wage:  " `p5'
    display        "95th percentile of wage: " `p95'

**## 7.2

* create cumulative distribution
	cumul           wage, gen(F_wage)

* graph the CDF
	twoway          (line F_wage wage, sort), ///
                        title("Cumulative distribution of wage") ///
                        xtitle("Hourly wage (1988 dollars)") ///
                        ytitle("Cumulative probability")
	graph export	"$answ/04-percentile-2.png", replace
	
**## 7.3
	twoway              (line F_wage wage, sort), ///
							yline(0.05, lpattern(dash) lcolor(maroon)) ///
							title("CDF of wage with 5% cutoff") ///
							xtitle("Hourly wage (1988 dollars)") ///
							ytitle("Cumulative probability")
	graph export	"$answ/04-percentile-3.png", replace

						
********************************************************************************
**# exercise 8
********************************************************************************

**## 8.1
	sum				hours

* hypothesis test
* $H_0: \mu = 40$
* $H_1: \mu \neq 40$

	ttest			hours == 40

**## 8.2
	sum				wage if collgrad == 1

* hypothesis test
* $H_0: \mu = 10$
* $H_1: \mu \neq 10$

	ttest			wage == 10 if collgrad == 1
	
	
********************************************************************************
**# challenge 4
********************************************************************************

* load data
    sysuse      	nlsw88, clear
	
* get summary stats from wage
	qui sum			ttl_exp, detail
	
* store values as locals
	local			mu  = r(mean)
	local           p5  = r(p5)
	local           p95 = r(p95)
	
* compute kernel density and save the grid + density
    kdensity    	ttl_exp, gen(x_ttl d_ttl) nograph

* create left and right tail densities for shading
    gen        		d_left  = d_ttl if x_ttl <= `p5'
    gen         	d_right = d_ttl if x_ttl >= `p95'

* create locals for right and left cutoff
	qui sum			x_ttl if !missing(d_left), meanonly
	local			lcut = r(max)
	
	qui sum			x_ttl if !missing(d_right), meanonly
	local			rcut = r(min)
	
* a zero line for rarea (needed for shading)
    gen         	zero = 0
	
*create nicely formatted labels for tick marks
    local       	p5lbl  : display %5.2f `p5'
    local       	mulbl  : display %5.2f `mu'
    local       	p95lbl : display %5.2f `p95'

* left tail center & height
    qui sum         x_ttl if !missing(d_left), meanonly
    local           lx = (r(min) + r(max))/2

    qui sum         d_ttl if !missing(d_left), meanonly
    local           ly = 0.6*r(max)

* right tail center & height
    qui sum         x_ttl if !missing(d_right), meanonly
    local           rx = (r(min) + r(max))/2

    qui sum         d_ttl if !missing(d_right), meanonly
    local           ry = 0.6*r(max)

* final graph
	twoway 				(kdensity ttl_exp) ///
							(rarea d_left  zero x_ttl, sort color(navy%60)) ///
							(rarea d_right zero x_ttl, sort color(navy%60)), ///
							xline(`lcut' `mu' `rcut', lpattern(dash) lcolor(maroon)) ///
							xlabel(`mu' "`mulbl'", add) ///
							text(`ly' `lx' "5%",  place(c)) ///
							text(`ry' `rx' "95%", place(c)) ///
							title("PDF of total work experience with tails") ///
							xtitle("Total work experience (years)") ///
							ytitle("Density") ///
							legend(off)
	graph export	"$answ/04-challenge.png", replace
		

* close the log
	log	close

/* END */

	