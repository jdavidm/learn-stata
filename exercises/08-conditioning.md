---
layout: exercise
topic: Causal Effects
title: Conditioning on a Confounder
language: Stata
---

Continuing with the DGP that you created in exercise 1, we will explore different ways of conditioning to reduce bias. To do this, we need to start by making quartiles based on ability.
- Create quartiles based on ability using `xtile` and call the variable `ability_q4`
- Add value labels so output is easy to read:

```stata
    label           define abilityq4 1 "lowest ability" 2 "low" ///
                        3 "high" 4 "highest ability"
    label           values ability_q4 abilityq4
    label           var ability_q4 "ability quartile"
```

1\. Compare wages within quartiles using `sum`. What is mean wages for each quartile?
2\. Using quartile 2 and conditioning on `train`, what is the conditional mean? How does it compare in size to the true causal effect?
3\. Create a simple bar chart of conditional means in that quartile.

---