---
layout: page
element: notes
title: Tidy Data
language: Stata
---

### Types of data in Stata

* Essentially two types of data
    * Numeric - numbers on which the computer can do math
    * Strings - all non-numerica data on which computers cannot do math

* Stata has five ways to store numeric data, each with a different property and storage requirement

|         |                        |                       |   Closest to |       |
| Storage |                        |                       |   0 without  |       |
| type    |                Minimum |               Maximum |   being 0    | bytes |
|---------|------------------------|-----------------------|--------------|-------|
|  byte   |                   -127 |                   100 |   +/-1       |   1   |
|  int    |                -32,767 |                32,740 |   +/-1       |   2   |
|  long   |         -2,147,483,647 |         2,147,483,620 |   +/-1       |   4   |
|  float  | -1.70141173319 x 10^38 | 1.70141173319 x 10^38 |   +/-10^-38  |   4   |
|  double | -8.9884656743 x 10^307 | 8.9884656743 x 10^307 |   +/-10^-323 |   8   |
|---------|------------------------|-----------------------|--------------|-------|

* Data types `byte`, `int`, and `long` are all integers - they can only store whole numbers.
    * Given storage and memory capacity on modern computers, the difference between `byte`, `int`, and `long` do not really matter any more. There is no reason to store something as `byte` or `int` when one can store it as `long`.
    * The only real exception to this is when one has very large (*big*) data with multiple millions of observations. Then storage capacity can start to matter.
* Storing data as `float` (Stata's default) versus `double` can matter.
    * `floats` have about 7 digits of accuracy; the magnitude of the number does not matter.  Thus, 1234567 can be stored perfectly as a `float`, as can 1234567e+20.  The number 123456789, however, would be rounded
    * In general, this rounding does not matter. Few people have data that is accurate to 1 part in 10 to the 7th
    * Among the exceptions are banks, who keep records accurate to the penny on amounts of billions of dollars. If you are dealing with such financial data, store your dollar amounts as doubles.
    * Another exception is if you are storing identification numbers, the rounding could matter. If the identification numbers are integers and take 9 digits or less, store them as `long`; otherwise, store them as `double` since `double` has 16 digits of accuracy.

* The other type of data that Stata can hand are strings.
    * As with numerics, strings have different levels of accuracy or length denoted by `str#`, with longer strings taking up more storage.
    * `str1` is a string of length 1, `str2` is of length 2, etc.
    * `str5` can hold the word **male** but could only hold **femal** of **female**.
    * A string can be defined up to `str2045` though in more recent versions of Stata there is `strL` which can hold 2,000,000,000 characters.
    * Numbers can be stored as strings and any time there is a non-numeric character in a variable, that variable will of necessity be a string.

### Making data tidy

* Tidy data is data that is well designed for working with using computers
* Creating tidy data as you collect it will make it much easier to analyze it later
* Let's start by looking at some messy data and thinking about what makes it
messy and what we could do to improve it.

> Do the exercise on [Improving Messy Data]({{ site.baseurl }}/exercises/03-tidy-data-improving-messy-data).
>
> * Put the data up on the screen
> * Ask the class for things they would improve and how to fix them
> * Talk through anything that can be improved about their answers


### Make it a rectangle

* Only rows and columns, no additional structure
* One column for each type of information
* One row for each observation (i.e., data point)

#### Bad:

| Plot | CropA | CropB |
|------|-------|-------|
| 1    | 3     | 1     |
| 2    | 2     | 4     |

#### Good:

| plot | crop | yield |
|------|------|-------|
| 1    | A    | 3     |
| 1    | B    | 1     |
| 2    | A    | 2     |
| 2    | B    | 4     |


### One cell one value

* Every cell contains one piece of information

#### Bad:

| Yield |
|-------|
| 2600g |
| 2.6kg |

#### Good:

| yield | unit |
|-------|------|
| 2600  | g    |
| 2.6   | kg   |


### Don't confuse the computer

* Don't use colors, fonts, italics, or anything visual as data. It's hard to tell the computer to treat yellow cells or bolded numbers differently.
* Avoid spaces in names. Computers use spaces to separate commands. Use `_` to include multiple words.
* Avoid special characters like @ * and ^. These often mean special things to computers, which can make data harder to work with.

#### Bad:

| GPS Accuracy |
|--------------|
| 0.5          |
| 2.2          |
| **10.3**     |

| GPS Accuracy |
|--------------|
| 0.5          |
| 2.2          |
| 10.3*        |

#### Good:

| accurate | calib_error |
|----------|-------------|
| 0.5      | 0           |
| 2.2      | 0           |
| 10.3     | 1           |


### Be clear and consistent

* Use short meaningful names. 
* Use consistent names, abbreviations, and capitalizations
* Use good null values (not -999, which is common in older data).
* Stata has its own null values. For a string, it is just a blank or empty cell. For numerics it is a sysmis (.) AKA a period.
* Write dates as YYYY-MM-DD or have separate Year, Month, and Day columns

#### Bad:

| d              | s       |    a      |
|----------------|---------|-----------|
| 02/26/2020     |  dior   |     3     |
| 02/26/2020     |  disp   |     1     |
| March 24, 2020 |  DIor   |   -999    |
| March 24, 2020 |  DISP   | Missing   |

#### Good:

| Date       | Species | Abundance |
|------------|---------|-----------|
| 2020-02-26 |  dior   |     3     |
| 2020-02-26 |  disp   |     1     |
| 2020-03-24 |  dior   |     NA    |
| 2020-03-24 |  disp   |     NA    |


### Use one table for each category of data

* Avoid duplicated chunks of data using multiple tables
* Use one table for each category of data

#### Bad:

| Family       | Genus     | Species     | Plot | Abundance |
|--------------|-----------|-------------|------|-----------|
| Heteromyidae | Dipodomys | Spectabilis | 1    | 2         |
| Heteromyidae | Dipodomys | Spectabilis | 2    | 7         |
| Heteromyidae | Dipodomys | Spectabilis | 3    | 5         |
| Heteromyidae | Dipodomys | Spectabilis | 4    | 3         |
| Heteromyidae | Dipodomys | Ordii       | 1    | 5         |
| Heteromyidae | Dipodomys | Ordii       | 2    | 9         |
| Heteromyidae | Dipodomys | Ordii       | 3    | 12        |
| Heteromyidae | Dipodomys | Ordii       | 4    | 11        |

* Difficult to update (e.g., if taxonomy updates)
* More error prone
* Takes up more space

#### Good:

| SpeciesID | Plot | Abundance |
|-----------|------|-----------|
| disp      | 1    | 2         |
| disp      | 2    | 7         |
| disp      | 3    | 5         |
| disp      | 4    | 3         |
| dior      | 1    | 5         |
| dior      | 2    | 9         |
| dior      | 3    | 12        |
| dior      | 4    | 11        |

| SpeciesID | Family       | Genus     | Species     |
|-----------|--------------|-----------|-------------|
| disp      | Heteromyidae | Dipodomys | Spectabilis |
| dior      | Heteromyidae | Dipodomys | Ordii       |

* Only need to make changes in a single location
* Less repetative typing


### Export data into easy to read formats

* Save data in plain text files.
* Files -> Export -> Select 'Download this sheet as CSV (.csv)
