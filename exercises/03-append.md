---
layout: exercise
topic: Data Management
title: Append Data
language: Stata
---

Using the World Bank's LSMS data, we are going to simulate the common case where survey data arrive as separate files by wave. In fact, this is how the LSMS data comes, I've just given you a data set in which all the waves and all the countries have already been appended into a single data set. You will create wave-specific datasets and then append them.

1. **Create wave-specific files**

   a. Open the original dataset:

   ```stata
   use "hh_survey.dta", clear
   ```

   b. Keep only **wave 1** and save as `hh_wave1.dta`:

   ```stata
   keep if wave == 1
   save "hh_wave1.dta", replace
   ```

   c. Re-open the full dataset and keep only **wave 2** and save as `hh_wave2.dta`:

   ```stata
   use "hh_survey.dta", clear
   keep if wave == 2
   save "hh_wave2.dta", replace
   ```

2. **Check consistency across waves**

   - Open `hh_wave1.dta` and run `describe`.  
   - Open `hh_wave2.dta` and run `describe`.  

   Confirm that key variables (e.g., `hhid`, `eaid`, `urban`, `totcons_USD`, etc.) have the **same names and types** in both files.

3. **Append the datasets**

   a. Open the wave 1 data:

   ```stata
   use "hh_wave1.dta", clear
   ```

   b. Append wave 2 data:

   ```stata
   append using "hh_wave2.dta"
   ```

4. **Verify the result**

   - Check that the number of observations equals the sum of the observations in `hh_wave1.dta` and `hh_wave2.dta`.
   - Tabulate the `wave` variable:

     ```stata
     tab wave
     ```

   Confirm that both waves are present.

5. **Save the appended dataset**

   Save the combined file as `hh_allwaves.dta`:

   ```stata
   save "hh_allwaves.dta", replace
   ```

6. **Brief reflection**

   In a comment in your `.do` file, answer briefly (1–2 sentences each):

   - What does `append` do?  
   - How is `append` different from `merge` (which you will use in Part 3)?