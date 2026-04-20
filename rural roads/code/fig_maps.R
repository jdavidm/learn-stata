# R script to replicate Fig 1 and Fig F.1
install.packages("pacman")
library(pacman)
p_load(tidyverse, collapse, sf, tmap, tmaptools,  classInt)
options(collapse_mask = "manip")

workingdir = "~/roads_fires_repo" #set directory path
setwd(workingdir) 


# Fig. 1 ------------------------------------------------------------------

dist.sf <- read_rds("data/maps/fig1_distlayer.rds")

states.sf <- read_rds("data/maps/fig1_states.rds")


distfiresmap <-
  tm_shape(dist.sf) + tm_fill(
    col = "meanfires",
    alpha = 0.8,
    style = "cont",
    palette = "-inferno",
    title = "Fire counts",
    breaks = c(0, 5, 8.2, 20, 31.7, 70, 93.7 , 238.8, 2000),
    legend.size.is.portrait = FALSE ,
    labels = c("0", " ", "8", " ", "32", " ", "94" , " ", ">239")
  ) +
  tm_layout(
    frame = FALSE,
    legend.outside = FALSE,
    legend.position  = c("0.6", "0.15"),
    legend.outside.size = 0.3,
    legend.text.size = 0.7
  ) +
  tm_borders(col = "black", lwd = 0.2) +
  tm_shape(states.sf[states.sf$insample == 1 , ]) + tm_borders("white", lwd = 3)

tmap_save(tm=distfiresmap, filename = "outputs/fig1.pdf")

tmap_save(tm=distfiresmap, filename = "outputs/figF1_a.pdf")


# Fig F.1. data  --------------------------------------------------------------

distcrop.sf <- read_rds("data/maps/figF1_distlayer.rds")

samp.states.sf <- read_rds("data/maps/figF1_states.rds")


# Fig F.1.b ---------------------------------------------------------------

distfiresmap.samp <-
  tm_shape(distcrop.sf) + tm_fill(
    col = "meanfires.map",
    textNA = "Not in sample",
    showNA = TRUE,
    style = "cont",
    palette = "-plasma",
    title = "Fire counts",
    breaks = c(0, 3.5, 9, 33.4, 42, 70.2, 96.2 , 152, 600),
    labels = c("0", " ", "9", " ", "42", " ", "96" , " ", ">152"),
  ) +
  tm_layout(
    frame = FALSE,
    legend.outside = FALSE,
    legend.outside.size = 0.3,
    legend.text.size = 0.7
  ) +
  tm_borders(col = "black", lwd = 0.6) +
  tm_shape(samp.states.sf) + tm_borders("white", lwd = 2)


tmap_save(distfiresmap.samp,filename = "outputs/figF1_b.pdf" )


# Fig F.1.c ---------------------------------------------------------------

ricehi <-
  tm_shape(distcrop.sf) + tm_fill(
    col = "rice_hi",
    textNA = "Not in sample",
    showNA = TRUE,
    style = "cat",
    title = "Rice area share",
    labels = c("Below median", "Above median"),
    palette = "-plasma"
  ) +
  tm_layout(
    frame = FALSE,
    legend.outside = FALSE,
    legend.outside.size = 0.3,
    legend.text.size = 0.7
  ) +
  tm_borders(col = "black", lwd = 0.6) +
  tm_shape(samp.states.sf) + tm_borders("white", lwd = 2)


tmap_save(ricehi, filename = "outputs/figF1_c.pdf")


# Fig F.1.d ---------------------------------------------------------------

sugarhi <-
  tm_shape(distcrop.sf) + tm_fill(
    col = "sugar_hi",
    textNA = "Not in sample",
    showNA = TRUE,
    style = "cat",
    title = "Sugarcane area share",
    labels = c("Below median", "Above median"),
    palette = "-plasma"
  ) +
  tm_layout(
    frame = FALSE,
    legend.outside = FALSE,
    legend.outside.size = 0.3,
    legend.text.size = 0.7
  ) +
  tm_borders(col = "white", lwd = 0.6) +
  tm_shape(samp.states.sf) + tm_borders("white", lwd = 2)

tmap_save(sugarhi, filename = "outputs/figF1_d.pdf")
