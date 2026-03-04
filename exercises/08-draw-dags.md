---
layout: exercise
topic: Research design
title: Drawing DAGs for Simple DGPs
language: Stata
---

For each of the following stories add a comment-only section in your `.do` file.

1\. You want the causal effect of training on wages. Higher-ability workers are more likely to enroll in training, and ability also raises wages. So trained workers earn more partly because of training and partly because they have higher ability. What is the causal effect of training on wages?
   1. Draw DAGs using `<-` `->`.
   2. Identify confounders (if any), colliders (if any), and mediators (if any).  
   3. State which variable(s) you would condition on to identify the a causal effect.

2\. You want the causal effect of training on wages. Training increases productivity, and productivity increases wages. So training can raise wages directly and also indirectly by raising productivity. What is the causal effect of training on wages?
   1. Draw DAGs using `<-` `->`.
   2. Identify confounders (if any), colliders (if any), and mediators (if any).  
   3. State which variable(s) you would condition on to identify the a causal effect.

3\. You want the causal effect of training on wages. Training and ability both increase the chance you’re included in the sample (e.g., employed or surveyed), and wages also affect inclusion. So conditioning on being included creates a spurious link between training and ability. What is the causal effect of training on wages?
   1. Draw DAGs using `<-` `->`.
   2. Identify confounders (if any), colliders (if any), and mediators (if any).  
   3. State which variable(s) you would condition on to identify the a causal effect.
   
---
