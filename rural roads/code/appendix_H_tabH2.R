# script to replicate Table H2

workingdir = "~/roads_fires_repo" #set directory path
setwd(workingdir) 

install.packages("pacman")
library(pacman)
p_load(tidyverse, fixest, haven, collapse)
options(collapse_mask = "manip")

df <- read_dta("data/appH_matched_data.dta")

#Table H.2.

fs  = feols(receivedroad ~ t + left + right  + primary_school+ med_center+ elect+ tdist+ irr_share+ 
                  ln_land+ pc01_lit_share+ pc01_sc_share+ bpl_landed_share+ bpl_inc_source_sub_share+
                  bpl_inc_250plus | dist_thresh_id + year,
                df , cluster = ~village_id, weights = ~kernel_tri_ik)

ivfc = feols(fires10km ~ left + right + fires2001_10km + primary_school+ med_center+ elect+ tdist+ irr_share+ 
               ln_land+ pc01_lit_share+ pc01_sc_share+ bpl_landed_share+ bpl_inc_source_sub_share+
               bpl_inc_250plus | dist_thresh_id + year | receivedroad ~ t,
             df , cluster = ~village_id, weights = ~kernel_tri_ik)

ivpm = feols(pm25_ ~ left + right + pm25_bl2001 + primary_school+ med_center+ elect+ tdist+ irr_share+
                 ln_land+ pc01_lit_share+ pc01_sc_share+ bpl_landed_share+ bpl_inc_source_sub_share+
                 bpl_inc_250plus | dist_thresh_id + year | receivedroad ~ t,
             df , cluster = ~village_id, weights = ~kernel_tri_ik)


depmeans <-  na_rm(df) %>% 
  fsubset(t == 0) %>% fselect(receivedroad, fires10km, pm25_ ) %>% 
  fmean()

depmeans <- unname(depmeans)

dictvill = c(receivedroad = "Road built", t = "Above threshold pop.",
             fires10km = "Annual fire activity", pm25_ = "Annual average PM 2.5" )

etable(fs, ivfc, ivpm,
       dict = dictvill, 
       keep= c("Road", "Above") ,
       fitstat = ~ n, drop.section = c("fixef"),
       digits = "r3", digits.stats = "r2",
       extralines = list("_^Control group mean" = depmeans),
       headers = list("_:_:" = c("$1^{st}$ stage", "IV", "IV")),
       style.tex = style.tex("aer", stats.title= "\\midrule"),
       file = "outputs/tableH2.tex", replace = TRUE)
