---
layout: page
title: House Style
---

When writing code, ensure you use *headings* and *subheadings*, *bookmarks*, *documentation*, *tabs*, and *comments* in a way that is consistent with template .do files.

* Headings open large sections of code and are numbered. For assignments, headings should correspond with an exercise. Headings are bookmarked with `**# 1`. Subheadings are numbered following the heading but with a decimal point followed by a number. For assignments, subheadings should correspond with a sub-questions within an exercise. Subheadings are bookmarketed at one level down with `**## 1.1`.

* Documentation precedes smaller code blocks and start with a single *. Documentation should be concise but clear and focus on design and purpose, not mechanics.

* Tabs should be used to create white space for easy reading. Commands should immediately follow a documentation and be one tab in. The data or object that the command operates on should be tabbed several spaces over, so that one can, at a glance, determine the command and the object of that command. If you need to break the line, then tab in three times.

* Comments follow code blocks and report on the result/output of that code block. Not all code blocks need comments but they can be useful, especially in when dropping or merging data or if the codeblock is particularly complicated. Comments are tabbed so they are directly below the command they comment on and start with three ***.

All code should be written in lowercase lettering except in extraordinary cases when an uppercase letter is necessary to convey information that lowercase lettering cannot get across.

## Example of house style

Every `.do` file that you turn in must have a preamble that contains the following information and is in the following "house syle".

```stata
* course: 597A
* assignment: 1
* created on: dec 25
* created by: jdm
* edited on: 9 dec 25
* edited by: jdm
* Stata v.19.5
```

After the preamble, if the assignment uses data, define the paths using relative pathways. Then open a log file. The name of log files should correspond with the name of the `.do` file.

```stata
**# 0 - setup

* define paths
	global	root 	"$data/assignments/data"
	global	export 	"$data/assignments/answers"
	global	logout 	"$data/assignments/logs"

* open log
	log 	using 	"$logout/assignment_1", append
```

Exercises and sub-exercises should be labelled with bookmarks in the following style

```stata
**# exercise 1

**## 1.1
```

Finally, the code should be documented and aligned using tabs. Long lines of code should be broken with `///` and then the code following the line break should be tabbed in once. If you are writing a loop, whatever is inside the loop should be in one more tab than the start of the loop so that the contents of the loop are obvious.

```stata
* load data
	use             "$root/SEC_2A", clear

* generate unique ob id
	gen             plot_id = hhid + " " + plotnum
	lab var         plot_id "unique plot identifier"
	isid            plot_id
    *** there are 5,203 unqiue plots
    
* summarize plot size	
    sum             plotsize_self_ac plotsize_gps_ac
    *** mean values are 1.5 (gps) and 1.7 (self-reported)

* loop to rename variables    
    local           change chown chmgmt
	
    foreach v of varlist `change' {
		replace         `v' = 0 if `v' == 2
		label           values `v' yesno
    } 	
		
* keep essential variables
 	keep            zone state lga sector ea hhid plotid own* ///
                        chown chmgmt mgmt* collat cert*
```

Finally, each `.do` file should close with the same end matter.

```stata
**# 2 - end matter, clean up to save

* prepare for export
	qui:            compress
	isid            hhid plotid
	save            "$export/secta1_harvestw1", replace
	
* close the log
	log             close

/* END */
```

Code not following the house style will be returned un-graded. Students will then have a chance to re-submit the assignment in the correct style. If assignments are re-submitted the same day, they will be graded without penalty. If they are submitted late, the earned grade will be reduced 10%. If the assignment is never re-submitted, it will be graded a 0.