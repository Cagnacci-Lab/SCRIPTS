
# # # # # # # # # # # # # # # # NDVI gap filling # # # # # # # # # # # # # # #
sessionInfo(); getwd()
rm(list = ls()); gc()

library(terra)
library(stringr)
library(raster)
library(dplyr)
library(tidyr)
library(sf)
library(tictoc)
library(ggplot2)
library(lubridate)
library(rsat)
library(padr)


# Data loading ----
dir_ndvi_root <- 'C:/Downloads/folder_ndvi/' # where the downloaded data is stored
dir.create(paste0(dir_ndvi_root, 'interpolated')) # create a folder where to put the interpolated tiles

dir_ndvi <- 'F:/4_UngulAlps/high_resolution_ndvi/smooth' # link to the folder with smoothed NDVI
# from this folder data is used for the gap filling function


# table with summary information
timediff <-
  tibble(file_name = c(list.files(dir_ndvi, pattern = ".tif"))) %>%
  mutate(date = str_sub(list.files(dir_ndvi, pattern = ".tif"),
                        start = 15, end = 24) %>% ymd())


# Interpolation gaps ----
tot_length <- length(list.files("F:/4_UngulAlps/high_resolution_ndvi", pattern = ".tif"))

for (i in c(3:(tot_length - 3))){ # c(3:(tot_length - 3)) ##

  tic()
  gc()

  # create table with target raster, day differences, and weights
  # target raster has a weight of 10, and for each day (before and after)
  # the weight decrease of a unit, with the 9th day with a w = 1
  sub <-
    timediff %>%
    dplyr::filter(date > timediff[i, 2] - 8 & date < timediff[i, 2] + 8) %>%
    mutate(start = timediff[i, 2] -8) %>%
    mutate(day = as.numeric(date - start$date))

  # create raster stack with target tiles
  tile <- stack(paste0(dir_ndvi, "/", sub$file_name))
  tile <- setZ(tile, sub$date, "date")
  # names(tile) <- c("tile_1", "tile_2","tile_3","tile_4","tile_5")

  # set to NA all values < -1 OR > 1
  for (n in 1:nlayers(tile)){ # nlyr
    values(tile[[n]])[values(tile[[n]]) < -1 | values(tile[[n]]) > 1] <- NA
  }

  whichone <- which(sub$date == timediff[i, 2])
  print(sub$file_name[whichone])

  tile_filled <- approxNA(tile, rule = 2, z = sub$day) # approximate

  writeRaster(tile_filled[[whichone]],
              paste0(paste0(dir_ndvi_root, 'interpolated/',
                     "inter_",
                     str_sub(sub$file_name[whichone], 8, 33)),
              overwrite = TRUE)

  toc()
}
