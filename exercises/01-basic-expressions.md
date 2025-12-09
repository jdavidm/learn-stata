---
layout: exercise
topic: Expressions and Variables
title: Basic Expressions
language: Stata
---

Display the following calculations in the text editor.

1. 2 - 10
2. 3 \* 5
3. 9 / 2
4. 5 - 3 \* 2
5. (5 - 3) \* 2
6. 4 ^ 2
7. 8 / 2 ^ 2

Run them by either clicking the `Execute` arrow button of the editor or press `Ctrl+D` (for do) (Windows) or `Cmd+D` (Mac) to run code and print the results in the console.

If no code is highlighted/selected this will run the entire file. If you highlighted/selected a block of code it will run that entire group of lines.

To tell someone reading the code what this section of the code is about, add a comment line that says 'Exercise 1' before the code that answers the exercise.
* Comments in Stata are added by adding the `*#*` sign. Anything after a `*` sign on the same line is ignored when the program is run.
* You can also create multiple lines of comments by starting the comment with `/*` and closing the comment with `*/`. 
* You can also create bookmarks using `**#` for the first level and `**##` for the second level.

So, the start of your program should look something like:

```stata
**# exercise 1

**## 1.1
display 2 - 10

**## 1.2
display 3 * 5
```