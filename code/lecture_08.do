* simulate a DGP with confounding
    clear all
    set             seed 12345
    set             obs 200000

* unobserved soil quality (higher is better)
    gen             soil_q = rnormal(0, 1)

* fertilizer adoption: more likely on better plots
    gen             fert_latent = 0.5*soil_q + rnormal(0, 1)
    gen             fert = (fert_latent > 0)
    label           define fertlbl 0 "no fertilizer" 1 "fertilizer"
    label           values fert fertlbl

* true causal effect of fertilizer on yield is 0.5 tons/ha
* soil quality also matters
    gen             eps = rnormal(0, 1)
    gen             yield_lat = 2 + 0.5*fert + 1*soil_q + eps
    gen             yield = max(yield_lat, 0)
    drop            yield_lat
    label           var yield "yield (tons/ha)"

* peek at the data
    sum             soil_q fert yield
	
* naive difference in means
    tabstat         yield, by(fert) stat(mean n)

* compute difference in means manually using stored results
	qui sum         yield if fert == 0, meanonly
    scalar          y0 = r(mean)

    qui sum         yield if fert == 1, meanonly
    scalar          y1 = r(mean)

    display         "Naive diff-in-means (fert - no fert): " %9.3f (y1 - y0)
	
* create soil quality quartiles
    xtile           soil_q4 = soil_q, nq(4)
    label           define soilq4 1 "worst soil" 2 "low" 3 "high" 4 "best soil"
    label           values soil_q4 soilq4

* mean yield by fert within each soil quartile
	bysort 			soil_q4 fert: ///
						summarize yield
						
* conditional difference in means in a soil group
    tabstat         yield if soil_q4 == 2, by(fert) stat(mean n)

* graph (put if BEFORE the comma)
    graph bar       (mean) yield if soil_q4 == 2, over(fert) ///
                        ytitle("Mean yield") ///
                        title("Fertilizer vs no fertilizer (soil group 2)")
						
* randomized treatment: fert independent of soil_q
    clear all
    set             seed 9876
    set             obs 200000

    gen             soil_q = rnormal(0, 1)

* randomized fertilizer: 50% treated
    gen             u = runiform()
    gen             fert = (u < 0.5)
    label           define fertlbl 0 "control" 1 "treatment"
    label           values fert fertlbl

* same causal effect and same soil effect (truncate at 0)
    gen             eps = rnormal(0, 1)
    gen             yield_lat = 2 + 0.5*fert + 1*soil_q + eps
    gen             yield = max(yield_lat, 0)
    drop            yield_lat

* naive diff-in-means is now a valid causal estimate
    tabstat         yield, by(fert) stat(mean n)