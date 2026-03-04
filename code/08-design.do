 * course: AAE 497A/597A
* assignment: 8
* created on: mar 26
* created by: jdm
* edited on: 4 mar 26
* edited by: jdm
* Stata v.19.5
	
* open log
	cap log 		close
	log using		"$logout/08-design", append
	
	
********************************************************************************
**# exercise 1
********************************************************************************

	clear all

* set seed and number of observations
	set		seed	24601
	set		obs		30000

* unobserved confounder: ability ~ n(0,1)
	gen		ability	= rnormal(0, 1)

* training propensity increases in ability
	gen		p_train	= invlogit(-0.2 + 1.0 * ability)

* assign training via bernoulli draw
	gen		train	= (runiform() < p_train)

* noise term: eps ~ n(0,3)
	gen		eps		= rnormal(0, 3)

* latent wage equation: true effect of training = +2, ability = +4, intercept = 10
	gen		wage_lat = 10 + 2 * train + 4 * ability + eps

* enforce wage >= 0 (truncate at 0)
	gen		wage	= max(wage_lat, 0)

* label variables
	lab var		ability		"unobserved ability (n(0,1))"
	lab var		p_train		"p(train=1) = invlogit(-0.2 + 1.0*ability)"
	lab var		train		"assigned training (bernoulli draw)"
	lab var		eps			"wage shock (n(0,3))"
	lab var		wage_lat	"latent wage: 10 + 2*train + 4*ability + eps"
	lab var		wage		"wage truncated at 0"

* define and apply value labels for train
	lab def		yesno	0 "no" 1 "yes", replace
	lab val		train	yesno
	
**## 1.1

* mean wage for train == 0
	sum		wage if train == 0, meanonly
	scalar	w0 = r(mean)

* mean wage for train == 1
	sum		wage if train == 1, meanonly
	scalar	w1 = r(mean)

* display naive diff (w1 - w0)
	display	as text "naive diff in mean wage (train=1 minus train=0): " ///
			as result %9.3f (w1 - w0)

**## 1.2

* option a: tabstat table
	tabstat	ability, by(train) stat(mean sd n)

* option b: summarize with if (uncomment if you prefer)
*	sum		ability if train == 0
*	sum		ability if train == 1
 
 	
********************************************************************************
**# exercise 2
********************************************************************************

* create and label quartiles
	xtile           ability_q4 = ability, nq(4)
	
    label           define abilityq4 1 "lowest ability" 2 "low" 3 "high" 4 "highest ability"
    label           values ability_q4 abilityq4
    label           var ability_q4 "ability quartile"

 
 **## 2.1
 
	forvalues q = 1/4 {
		sum				wage if ability_q4 == `q', meanonly
		display	as 		text "mean wage, ability quartile `q' (" ///
							"`: label (abilityq4) `q''" ///
							"): " as result %9.3f r(mean)
	}
	
 **## 2.2
 
	sum				wage if ability_q4 == 2 & train == 0, meanonly
	scalar			w20 = r(mean)

	sum				wage if ability_q4 == 2 & train == 1, meanonly
	scalar			w21 = r(mean)

	display	as 		text "quartile 2 conditional means:" 
	display	as 		text "  mean wage (train=0): " as result %9.3f w20
	display	as 		text "  mean wage (train=1): " as result %9.3f w21
	display	as 		text "  diff (train=1 - train=0): " as result %9.3f (w21 - w20)
 
 **## 2.3
 
	graph bar       (mean) wage if ability_q4 == 2, over(train) ///
						ytitle("Mean wage") ///
						title("Training vs no training within ability quartile 2")
						
	graph export	"$answ/08-conditioning-2.png", replace