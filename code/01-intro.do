* course: 597A
* assignment: 1
* created on: dec 25
* created by: jdm
* edited on: 9 dec 25
* edited by: jdm
* Stata v.19.5


**# exercise 1

**## 1.1
	display			2 - 10
	
**## 1.2
	display			3 * 5
	
**## 1.3
	display			9 / 2
	
**## 1.4
	display			5 - 3 * 2
	
**## 1.5
	display			(5 - 3) * 2
	
**## 1.6
	display			4^2
	
**## 1.7
	display			8 / 2^2
	
	
**# exercise 2
	 set 			obs 1
	 gen			p_euro = 5.87
	 gen			p_gbp = 5.09
	 display		p_gbp / p_euro
	 
	 
**# exercise 3
	clear			all
	 set 			obs 1
	 gen			gdp = 30490000000000
	 gen			pop = 342900000
	 gen			gdp_pc = gdp / pop
	 gen			gdp_pc_euro = gdp_pc * 0.86
	
	
**# exercise 4

**## 4.1
	display			abs(-15.5)

**## 4.2
	display			round(4.483847,0.1)
	
**## 4.3
	display			round(3.8)

**## 4.4
	display			strupper("unemployment")

**## 4.5
	display			strlower("INFLATION")

**## 4.6
	display			round(sqrt(2.6),0.01)
	
**# exercise 5
	clear			all
	sysuse			nlsw88.dta, clear
    sum				wage hours
    tab				married race, row
    bys 			married race:  ///
						sum wage hours
						
**## 4.1

* 4.1.1 & 4.1.2
	bys				union: ///
						sum wage hours
* 4.1.3 & 4.1.4
	bys				collgrad: ///
						sum wage hours

	