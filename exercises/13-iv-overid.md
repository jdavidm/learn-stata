---
layout: exercise
topic: Instrumental Variables
title: Overidentification Tests
language: Stata
---

If you have *more* instruments than endogenous variables, your model is "overidentified". In our `Mroz.dta` example, we have 1 endogenous variable (`educ`) but 2 instruments (`motheduc`, `fatheduc`), meaning we are overidentified.

This is highly desirable because it allows us to formally test whether our instruments are valid (i.e. uncorrelated with the error term). We can do this using the Sargan-Basmann test of overidentifying restrictions, which Stata runs via the `estat overid` post-estimation command.

1. Ensure you have loaded `Mroz.dta`. Run the standard, non-robust `ivregress` (the overidentification test requires homoskedastic standard errors):
   ```stata
   ivregress 2sls lwage exper expersq (educ = motheduc fatheduc)
   ```
2. Run the command `estat overid`. 
3. This runs a Sargan test to check if your instruments are uncorrelated with the error term. If the $p$-value is $>0.05$, we fail to reject the null that our instruments are valid. 
4. Based on the output, did our instruments pass the exogeneity test?

---
