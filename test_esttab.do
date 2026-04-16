sysuse auto, clear
reg price mpg
est sto ols
gen mpg_hat = mpg + 1
reg price mpg_hat
est sto manual

esttab ols manual, nomtitles nodepvars keep(mpg mpg_hat) rename(mpg_hat mpg)
esttab ols manual, nomtitles nodepvars keep(mpg) rename(mpg_hat mpg)
