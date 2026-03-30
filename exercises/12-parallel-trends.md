---
layout: exercise
topic: Difference-in-Differences
title: Parallel Trends in Interventions
language: Stata
---

The credibility of a DiD design depends on parallel trends. Even with a continuous policy scaling up, we want to know if places adopting the seed faster were already growing their yield anyway. We can do a basic check by dividing the districts into "Early/High Adopters" vs "Late/Low Adopters".

### Tasks

1. In your do-file, define "early" or "high" seed adoption districts vs "never/low" adoption. Create a dummy variable equal to `1` if the district ever experienced high levels of `seed` in any year (e.g. `seed > 0` or higher than median), and `0` otherwise. You may use `bysort district_id: egen max_seed = max(seed)`.
2. Generate an indicator `HighAdopt = (max_seed > X)` (pick a reasonable threshold X for your data, such as `0` for any adoption or the median).
3. Use `collapse` to calculate the mean `evi_med` by year for both the `HighAdopt` districts and the remaining districts. 
4. Plot the trend using `twoway connected`.
5. Visually inspect the pre-adoption period (pick an arbitrary policy start year if it's generalized). Do the two groups appear to have parallel trends? State your finding in comments.
