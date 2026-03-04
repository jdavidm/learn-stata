---
layout: exercise
topic: Causal Effects
title: Conditioning on a Confounder
language: Stata
---

Continuing with the DGP that you created in exercise 1, we will explore different ways of conditioning to reduce bias. 

### 1) Make ability quartiles with clear labels

1. Create quartiles:

```stata
    xtile           ability_q4 = ability, nq(4)
```

2. Add value labels so output is easy to read:

```stata
    label           define abilityq4 1 "lowest ability" 2 "low" 3 "high" 4 "highest ability"
    label           values ability_q4 abilityq4
    label           var ability_q4 "ability quartile"
```

### 2) Compare wages within quartiles (conditioning)

Use a grouped summary so you can see mean `wage` by training status *within* each ability quartile:

```stata
    bysort          ability_q4 train: ///
        summarize   wage
```

### 3) A “single-quartile” check (like in the lecture)

Pick one quartile (use quartile 2) and do two quick checks.

1. Conditional means in that quartile:

```stata
    tabstat         wage if ability_q4 == 2, by(train) stat(mean n)
```

2. A simple bar chart of conditional means in that quartile:

```stata
    graph bar       (mean) wage if ability_q4 == 2, over(train) ///
        ytitle("Mean wage") ///
        title("Training vs no training within ability quartile 2")
```

### 4) Short interpretation (write as comments in your .do file)

In 2–4 sentences, answer:

1. Compared to the naive training vs no-training gap from Exercise 1, does the within-quartile gap look **smaller** (less confounded)? fileciteturn2file0  
2. Why does comparing within an ability quartile reduce confounding in this DGP?
