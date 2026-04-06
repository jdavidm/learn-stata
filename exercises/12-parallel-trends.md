---
layout: exercise
topic: Difference-in-Differences
title: Parallel Trends in Interventions
language: Stata
---

The credibility of a DiD design depends on parallel trends. Even with a continuous policy scaling up, we want to know if places adopting the seed faster were already growing their yield anyway. We can do a basic check by dividing the districts into "Early/High Adopters" vs "Late/Low Adopters".

- Define "early" or "high" seed adoption districts vs "never/low" adoption.
    - Use `bys district_id: egen max_seed = max(seed)` to create a variable that captures the maximum level of seed adoption in each district over the entire period.
    - Use `sum max_seed, detail` to get the median value of `max_seed` and then `r(p50)` to store it in a local macro.
    - Use the sorted median value to create a dummy variable equal to `1` if the district's `max_seed` is greater than the median value of `max_seed`, and `0` otherwise.
- Use `collapse` to calculate the mean `evi_med` by year for both the `HighAdopt` districts and the remaining districts. 
- Plot the trend using `twoway connected` and put an `xline` at the year of the first seed introduction (2011).

1. Save the figure and input it into your Overleaf document.
2. Visually inspect the pre-adoption period. Do the two groups appear to have parallel trends? State your finding in comments.

---
