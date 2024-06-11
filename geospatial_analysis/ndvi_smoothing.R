
# # # # # # # # # # # # # # # # NDVI smoothing # # # # # # # # # # # # # # # # #
sessionInfo(); getwd()
rm(list = ls()); gc()

library(terra)
library(tidyterra)
library(stringr)
library(raster)
library(dplyr)
library(tidyr)
library(sf)
library(mapview)
library(tictoc)
library(ggplot2)
library(lubridate)
library(parallel)
library(rsat)


# Data loading ----
# set as a directory the folder where the raw NDVI data is stored 
dir_ndvi <- 'C:/Downloads/folder_ndvi' 


# table with summary information
timediff <-
  tibble(file_name = c(list.files(dir_ndvi, pattern = ".tif"))) %>%
  mutate(date = str_sub(list.files(dir_ndvi, pattern = ".tif"),
                        start = 8, end = 17) %>% ymd())
# could give an error if tiles are opened in QGIS and a ".tif.aux" file is generated
# make sure no such files ".tif.aux" are in the folder!

# Smoothing ----
tot_length <- length(list.files(dir_ndvi, pattern = ".tif"))

for (i in c(9:(tot_length - 3))){ # remove the last three tiles becasue smoothing will be unbalanced
  
  # create table with target raster, day differences, and weights
  # target raster has a weight of 10, and for each day (before and after)
  # the weight decrease of a unit, with the 9th day with a w = 1
  sub <-
    timediff %>%
    dplyr::filter(date > timediff[i, 2] - 9 & date < timediff[i, 2] + 9) %>%
    mutate(center = timediff[i, 2]) %>%
    mutate(diff = as.numeric(center$date - date)) %>%
    mutate(w = if_else(date == timediff[i, 2], 10, NA)) %>%
    mutate(w = 10 - abs(diff))

  # create a raster stack with the selected rasters
  tile <- rast(paste0(dir_ndvi, sub$file_name))
  print(timediff[i, 1]); print(i)

  tic()
  
  # smooth the central raster
  mid_layer <- app(
    tile,
    fun = function(x)
      weighted.mean(x, sub$w, na.rm = T))
  
  # write the raster output in the external hard disk 
  raster::writeRaster(mid_layer,
                      paste0(dir_ndvi, "smooth/smooth_", timediff[i, 1]),
                      overwrite = TRUE)
  
  toc()
  gc() # clean RAM
}
