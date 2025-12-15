---
layout: page
title: Assignment Submission Checklist
---

- All assignments should be submitted through the course [Github](https://github.com/jdavidm/semester26) page.

- What files to submit: 
    - **Weeks 1-10** - the code you wrote for the assignment in `.do` format plus a `.txt` file with your solutions
    - **Weeks 10+** - the code you wrote for the assignment in `.do` format plus a `.tex` file with your solutions in [Overleaf](https://www.overleaf.com/5595112223xhspvdgjjqpt#e3fb94)


## Code Checklist

### Make sure your assignment has a preamble in the house style

Every `.do` file that you turn in must have a preamble that contains the following information and is in this course's [house style]({{ site.baseurl }}/materials/house-style).

```stata
* course: 597A
* assignment: 1
* created on: dec 25
* created by: jdm
* edited on: 9 dec 25
* edited by: jdm
* Stata v.19.5
```

Exercises and sub-exercises should be labelled with bookmarks in the following style

```stata
**# exercise 1

**## 1.1
```

### Make sure you have a log file of your work

After the preamble, open a `.log` file to track your work.

```stata
* open log
	cap log 		close
	log using		"$logout/assignment_1", append
```

Here, `cap log close` ensures any open `.log` files are closed before openning a new one. The `$logout` is a global referring to the relative path where you saving your `.log` files. And `append` ensures you keep adding to the `.log` file instead of overwriting the file. Make sure to close the `.log` file at the end of the assignment and clarify that the assignment is complete using `/* END */`.

```stata

* close the log
	log	close

/* END */		
```

### Make sure your code matches the provided answers

- At the bottom of each exercise a set of answers are provided. For full credit
  your answers should match those provided. For example, if there are three
  separate plots your code should produce three separate plots.
- Some errors can lead to only subtle differences so check carefully
- Sometimes small differences result from changes in packages and versions. If you see a
  difference but you think your answer is right, let us know and we can check.

### Make sure your code follows the instructions

- It is possible to get the right output even when doing something the wrong way
- To get full credit on assignments you need to both follow the instructions and
  get the right output

### Clean up your code

Code should be easy to read and understand.

- Code must follow this course's [house style]({{ site.baseurl }}/materials/house-style).
- Only include code and comments necessary for the assignment. Remove anything else (e.g., notes taken during class, commented code that isn't needed anymore).
- Remove extra/duplicate files. Only turn in what is necessary for the assignment.
- Clearly label problems using comments.

### Make sure your code runs like you think it does

Code should run from the start of the file to the end of the file without problems. To make sure this is true:

- Clear the Stata environment by typing `clear all`.
- Run the entire file by either clicking the `Execute` button or using the `Ctrl+D` keyboard shortcut (`Cmd+Shift+D` on macOS).

### Work with data files appropriately

Code should run the same way regardless of which computer it is run on. In order to grade your code someone will need to run it on another computer. To make sure your code will work on another computer:

- Use you `project.do` file to set the development environment
- Use relative paths, not absolute paths. E.g., use `$data/mydata.csv` instead of `C:\Users\Batman\DataCarp\data\mydata.csv`.
- Make filenames in the code match the actual filenames exactly
