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
	set				seed	24601
	set				obs		30000

* unobserved confounder: ability ~ n(0,1)
	gen				ability	= rnormal(0, 1)

* training propensity increases in ability
	gen				p_train	= invlogit(-0.2 + 1.0 * ability)

* assign training via bernoulli draw
	gen				train	= (runiform() < p_train)

* noise term: eps ~ n(0,3)
	gen				eps		= rnormal(0, 3)

* latent wage equation: true effect of training = +2, ability = +4, intercept = 10
	gen				wage_lat = 10 + 2 * train + 4 * ability + eps

* enforce wage >= 0 (truncate at 0)
	gen				wage	= max(wage_lat, 0)

* label variables
	lab var			ability		"Unobserved ability (n(0,1))"
	lab var			p_train		"p(train=1) = invlogit(-0.2 + 1.0*ability)"
	lab var			train		"Assigned training (bernoulli draw)"
	lab var			eps			"Wage shock (n(0,3))"
	lab var			wage_lat	"Latent wage: 10 + 2*train + 4*ability + eps"
	lab var			wage		"Wage truncated at 0"

* define and apply value labels for train
	lab def			yesno	0 "no" 1 "yes", replace
	lab val			train	yesno
	
**## 1.1
	sum				wage if train == 0, meanonly
	scalar			w0 = r(mean)

* mean wage for train == 1
	sum				wage if train == 1, meanonly
	scalar			w1 = r(mean)

* display naive diff (w1 - w0)
	display	as 		text "naive diff in mean wage (train=1 minus train=0): " ///
			as 		result %9.3f (w1 - w0)

**## 1.2
	tabstat			ability, by(train) stat(mean sd n)

* option b: summarize with if (uncomment if you prefer)
*	sum		ability if train == 0
*	sum		ability if train == 1
 
 	
********************************************************************************
**# exercise 2
********************************************************************************

* create and label quartiles
	xtile           ability_q4 = ability, nq(4)
	
    lab def			abilityq4 1 "Lowest ability" 2 "Low" 3 "High" 4 "Highest ability"
    lab val			ability_q4 abilityq4
    lab var			ability_q4 "ability quartile"

 
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
 
 	
********************************************************************************
**# exercise 3
********************************************************************************

* confirm required variables exist (from exercises 1-2)
	foreach v in ability train eps wage {
		cap confirm variable `v'
		if _rc != 0 {
			di as error "required variable missing: `v'. re-run exercises 1-2 first."
			exit 198
		}
	}
	
* randomized training assignment
	egen			p_rct = mean(train)
	gen				u_rct = runiform()
	gen				train_rct = (u_rct < p_rct)

* labels
	lab var			u_rct "Random draw for rct assignment"
	lab var			train_rct "Randomized training assignment (rct)"

	lab def			trt_rct	0 "Control" 1 "Treatment", replace
	lab val			train_rct trt_rct

* generate rct outcomes using same structural model
	gen				wage_rct_lat = 10 + 2 * train_rct + 4 * ability + eps
	gen				wage_rct = max(wage_rct_lat, 0)

	lab var			wage_rct_lat "Latent wage under rct assignment"
	lab var			wage_rct "Wage under rct assignment (truncated at 0)"
	
**## 3.1

* true causal effect (built into dgp)
	scalar	tau_true = 2

* observational diff: e[wage|train=1] - e[wage|train=0]
	sum				wage if train == 0, meanonly
	scalar			w_obs0 = r(mean)

	sum				wage if train == 1, meanonly
	scalar			w_obs1 = r(mean)

	scalar			diff_obs = w_obs1 - w_obs0

* rct diff: e[wage_rct|train_rct=1] - e[wage_rct|train_rct=0]
	sum				wage_rct if train_rct == 0, meanonly
	scalar			w_rct0 = r(mean)

	sum				wage_rct if train_rct == 1, meanonly
	scalar			w_rct1 = r(mean)

	scalar			diff_rct = w_rct1 - w_rct0

* display
	display	as 		text "true causal effect (tau): " ///
			as 		result %9.3f tau_true

	display	as 		text "naive diff-in-means (observational train): " ///
			as 		result %9.3f diff_obs

	display	as 		text "naive diff-in-means (rct train_rct): " ///
			as 		result %9.3f diff_rct
			
**## 3.2

* observational selection: e[ability|train=1] - e[ability|train=0]
	sum				ability if train == 0, meanonly
	scalar			a_obs0 = r(mean)

	sum				ability if train == 1, meanonly
	scalar			a_obs1 = r(mean)

	scalar			diff_a_obs = a_obs1 - a_obs0

* rct balance: e[ability|train_rct=1] - e[ability|train_rct=0]
	sum				ability if train_rct == 0, meanonly
	scalar			a_rct0 = r(mean)

	sum				ability if train_rct == 1, meanonly
	scalar			a_rct1 = r(mean)

	scalar			diff_a_rct = a_rct1 - a_rct0

* display (formatted like q1)
	display	as 		text "mean ability (obs, train=0): " ///
			as 		result %9.3f a_obs0

	display	as 		text "mean ability (obs, train=1): " ///
			as 		result %9.3f a_obs1

	display	as 		text "diff in mean ability (obs, 1 - 0): " ///
			as 		result %9.3f diff_a_obs

	display	as 		text "mean ability (rct, train_rct=0): " ///
			as 		result %9.3f a_rct0

	display	as 		text "mean ability (rct, train_rct=1): " ///
			as 		result %9.3f a_rct1

	display	as 		text "diff in mean ability (rct, 1 - 0): " ///
			as 		result %9.3f diff_a_rct
	

********************************************************************************
**# exercise 4
********************************************************************************

**## 4.1
/*
* confounding story: ability confounds training -> wages

* 4.1.1 dag: training <- ability -> wages

* 4.1.2 confounders: ability; colliders: none; mediators: none

* 4.1.3 condition on ability to block its confounding effect
*/
**## 4.2
/*
* mediator story: productivity mediates training -> wages

* 4.2.1 dag: training -> productivity -> wages

* 4.2.2 confounders: none; colliders: none; mediators: productivity

* 4.2.3 for total effect: do not condition on productivity; for direct effect: condition on productivity
*/
**## 4.3
/*
collider story: conditioning on sample inclusion biases training -> wages

* 4.3.1 dag: training -> included <- wages

* 4.3.2 confounders: none; colliders: included; mediators: none

* 4.3.3 do not condition on included (and do not restrict to included==1)
*/


********************************************************************************
**# exercise 5
********************************************************************************

* simulate confounding dgp
	clear			all
	set				seed 314159
	set				obs 25000

* confounder
	gen				ability = rnormal(0, 1)

* training selection depends on ability (different rule than earlier exercise)
	gen				p_train = invlogit(-0.5 + 0.8*ability)
	gen				train = (runiform() < p_train)

* wage equation with noise (different levels and effect sizes than earlier exercise)
	gen				eps = rnormal(0, 4)
	gen				wage_lat = 20 + 3.5*train + 6*ability + eps
	gen				wage = max(wage_lat, 0)
	drop			wage_lat

* labels
	lab var			ability	"ability (confounder)"
	lab var			p_train	"p(train=1)"
	lab var			train	"training (selected, not randomized)"
	lab var			eps		"wage shock"
	lab var			wage	"wage"

	lab def			yesno 0 "no" 1 "yes", replace
	lab val			train yesno

**## 5.1
* true effect is 3.5
	
**## 5.2
* naive diff in means
	sum				wage if train == 0, meanonly
	scalar			w0 = r(mean)

	sum				wage if train == 1, meanonly
	scalar			w1 = r(mean)

	display as text "naive diff in mean wage (train=1 - train=0): " ///
		as result %9.3f (w1 - w0)

**## 5.3
* show selection: ability differs by train
	tabstat			ability, by(train) stat(mean sd n)

**## 5.4
* reduce bias by conditioning on ability bins
	xtile			ability_q4 = ability, nq(4)
	lab var			ability_q4 "ability quartile"

* optional: readable value labels
	lab def			abilityq4 1 "lowest" 2 "low" 3 "high" 4 "highest", replace
	lab val			ability_q4 abilityq4

* loop over quartiles and compute diff in means within each quartile
	forvalues		q = 1/4 {

		sum				wage if ability_q4 == `q' & train == 0, meanonly
		scalar			w0_q`q' = r(mean)

		sum				wage if ability_q4 == `q' & train == 1, meanonly
		scalar			w1_q`q' = r(mean)

		scalar			diff_q`q' = w1_q`q' - w0_q`q'

		display as text "ability_q4 == `q' (" ///
			"`: label (abilityq4) `q''" ///
			")  diff (train=1 - train=0): " ///
			as result %9.3f diff_q`q'
	}
	
	
********************************************************************************
**# exercise 6
********************************************************************************

* simulate collider dgp
	clear			all
	set				seed 24684
	set				obs 50000

* train and wage are independent in the population
	gen				train = (runiform() < 0.5)
	gen				wage  = rnormal(0, 1)

* collider: inclusion depends on both train and wage
	gen				emp_lat = -0.3 + 0.7*train + 0.7*wage + rnormal(0, 1)
	gen				employed     = (emp_lat > 0)

* labels
	lab var			train		"training (randomized)"
	lab var			wage		"wage (independent of training in population)"
	lab var			employed	"observed in sample (collider)"

	lab def			yesno 0 "no" 1 "yes", replace
	lab val			train yesno
	lab val			employed yesno

**## 6.1
* true effect is 0
	
**## 6.2
* naive diff in means
	sum				wage if employed == 1 & train == 0, meanonly
	scalar			w0_emp = r(mean)

	sum				wage if employed == 1 & train == 1, meanonly
	scalar			w1_emp = r(mean)

	scalar			diff_emp = w1_emp - w0_emp

	display as text "diff in mean wage among employed (train=1 - train=0): " ///
		as result %9.3f diff_emp
		
**## 6.3
* show selection: employed differs by train
	tabstat			employed, by(train) stat(mean sd n)
		
**## 6.4
* unconditional difference in means
	sum				wage if train == 0, meanonly
	scalar			w0_all = r(mean)

	sum				wage if train == 1, meanonly
	scalar			w1_all = r(mean)

	scalar			diff_all = w1_all - w0_all

	display as text "diff in mean wage in full sample (train=1 - train=0): " ///
		as result %9.3f diff_all
		
	
********************************************************************************
**# exercise 7
********************************************************************************

* simulate mediation dgp
	clear			all
	set				seed 13579
	set				obs 50000

* randomized training
	gen				train = (runiform() < 0.5)

* mediator: productivity increases with training
	gen				u_p = rnormal(0, 2)
	gen				productivity = 5 + 1.2*train + u_p

* outcome: wage depends on training directly and indirectly via productivity
	gen				u_w = rnormal(0, 5)
	gen				wage_lat = 25 + 1.0*train + 2.5*productivity + u_w
	gen				wage = max(wage_lat, 0)
	drop			wage_lat

* labels
	lab var			train			"training (randomized)"
	lab var			productivity	"productivity (mediator)"
	lab var			wage			"wage"

	lab def			yesno 0 "no" 1 "yes", replace
	lab val			train yesno
	

**## 7.1
	scalar			direct_true = 1.0

	display as text "q1: true direct effect of training on wages: " ///
		as result %9.3f direct_true
	
**## 7.2
* naive diff in means (total effect)
	sum				wage if train == 0, meanonly
	scalar			w0 = r(mean)

	sum				wage if train == 1, meanonly
	scalar			w1 = r(mean)

	scalar			total_hat = w1 - w0

	display as text "total effect (diff in mean wage, train=1 - train=0): " ///
		as result %9.3f total_hat
		
**## 7.3
* indirect effect via productivity

* step 1: effect of training on productivity (diff in means)
	sum				productivity if train == 0, meanonly
	scalar			p0 = r(mean)

	sum				productivity if train == 1, meanonly
	scalar			p1 = r(mean)

	scalar			delta_p = p1 - p0

* step 2: multiply by effect of productivity on wage (2.5)
	scalar			beta_p = 2.5
	scalar			indirect_hat = beta_p * delta_p

	display as text "q3: indirect effect (2.5 * diff in mean productivity): " ///
		as result %9.3f indirect_hat
		
**## 7.4
* direct and indirect effect
	scalar			direct_hat = total_hat - indirect_hat

	display as text "q4: implied direct effect (total - indirect): " ///
		as result %9.3f direct_hat


********************************************************************************
**# challenge 8
********************************************************************************
