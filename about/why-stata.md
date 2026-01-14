---
layout: page
title: Why Stata?
---

I chose to add teach this course in Stata for a handful of reasons including:

1. **It is the de facto standard in empirical economics.** Data and code submitted to the AEA Data Editor show that Stata is used in the clear majority of packages for AEA journal articles, year after year, far more than Matlab, R, Python, or other software. Learning Stata lets you open, understand, and extend the vast bulk of existing empirical work in economics.

   ![Software use by papers submitted to AEA journals]({{ site.baseurl }}/images/econ_software.png)
   Figure presents bar graphs of the number of papers submitted to the Data Editor of the AEA journals that used a specific software package. Reprinted from Vilhuber et al. (2020) under CC BY 4.0.

2. **Designed around the kinds of data economists actually use.** Stata’s core data model is built for rectangular microdata: individuals, firms, households, experiments, panel data, and large administrative files. Tasks like creating variables, reshaping panels, collapsing to aggregates, or merging complex survey files are all first-class, well-documented operations.

3. **A huge ecosystem of econometrics tools, especially for microeconometrics.** Stata ships with (and extends via user-written packages) most methods you will see in applied papers: IV, panel data models, limited dependent variables, treatment effects, event studies, difference-in-differences, synthetic controls, regression discontinuity, and more. You can usually go from "I saw this in a paper" to "here’s the command that does it" very quickly.

4. **Low startup cost with a consistent, readable syntax.** Commands follow a predictable structure and share common options (for example, how you specify weights, clustering, or robust standard errors). This consistency makes Stata easier for new coders to learn and for collaborators and referees to read.

5. **Strong support for reproducible research workflows.** Stata encourages scripting through do-files and logs, making it straightforward to rerun an entire project from raw data to final tables and figures. This is increasingly expected by journals, data editors, and policy organizations.

6. **Deep integration with the economics research community.** Central banks, government agencies, international organizations, and many academic departments use Stata as their primary statistics package. Knowing Stata increases your ability to work with colleagues, use shared code, and step into RA or analyst roles without needing to change tools.

7. **Plays well with other tools economists use.** Stata exports clean tables and figures to LaTeX, Word, and Excel, and can call out to Mata, Python, and R when needed. This lets you keep most of your workflow in a single, stable environment while still taking advantage of specialized tools from other languages.
