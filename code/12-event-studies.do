* course: 597a
* assignment: 12
* created on: 1 apr 26
* created by: jdm
* edited on: 1 apr 26
* edited by: jdm
* stata v.18.0

**********************************************************************
**# 0 - setup
**********************************************************************

* open log
	cap             log close
	log             using "12-event-studies.log", append

**********************************************************************
**# 1 - load data and define controls
**********************************************************************

* load castle doctrine data
	use             "https://github.com/scunning1975/mixtape/raw/master/castle.dta", clear

* define global macros for controls
	global          demo blackm_15_24 whitem_15_24 ///
	                    blackm_25_44 whitem_25_44
	global          spending l_exp_subsidy l_exp_pubwelfare
	global          xvar l_police unemployrt poverty l_income ///
	                    l_prisoner l_lagprisoner $demo $spending
	global          lintrend trend_1-trend_51
	global          region r20001-r20104

* set panel structure
	xtset           sid year

**********************************************************************
**# 2 - event study regression
**********************************************************************

* the data already has pre-built lead/lag dummies
* lead9-lead1: years before treatment
* lag1-lag5: years after treatment
* lag0 (year of treatment) is the omitted reference category

* event study regression
	xtreg           l_homicide i.year $region ///
	                    lead9 lead8 lead7 lead6 lead5 ///
	                    lead4 lead3 lead2 lead1 ///
	                    lag1 lag2 lag3 lag4 lag5 ///
	                    [aweight=popwt], fe vce(cluster sid)
	*** leads 1-6 are close to zero — consistent with parallel trends
	*** lags are positive, suggesting homicides rose after castle doctrine

**********************************************************************
**# 3 - event study plot
**********************************************************************

* plot coefficients with coefplot
	coefplot,       keep(lead9 lead8 lead7 lead6 lead5 ///
	                    lead4 lead3 lead2 lead1 ///
	                    lag1 lag2 lag3 lag4 lag5) ///
	                    vertical ///
	                    yline(0, lcolor(black) lpattern(dash)) ///
	                    xline(9.5, lcolor(maroon) lpattern(dash)) ///
	                    title("Event Study: Castle Doctrine on Homicides") ///
	                    xtitle("Periods Relative to Treatment") ///
	                    ytitle("Log Homicide Rate") ///
	                    msymbol(D) mfcolor(white) ///
	                    recast(connected) ///
	                    ciopts(recast(rcap)) ///
	                    graphregion(color(white))

**********************************************************************
**# 4 - bacon decomposition
**********************************************************************

* simple twfe for decomposition (bacondecomp requires minimal spec)
	areg            l_homicide post i.year, absorb(sid) robust

* run bacon decomposition
	bacondecomp     l_homicide post, ddetail
	*** the scatterplot shows each 2x2 sub-estimate and its weight
	*** check whether "later vs already-treated" comparisons pull the
	*** overall estimate in a different direction than "treated vs never"

**********************************************************************
**# 5 - end matter
**********************************************************************

* close log
	cap             log close

/* end */
