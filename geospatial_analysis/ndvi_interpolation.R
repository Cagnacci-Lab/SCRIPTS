
# # # # # # # # # # # # # # # # NDVI interpolation # # # # # # # # # # # # # # #
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
dir_ndvi <- 'F:/4_UngulAlps/high_resolution_ndvi/' 

# Time difference
timediff <- 
  tibble(file_name = c(list.files(dir_ndvi, pattern = ".tif"))) %>%
  mutate(date = str_sub(list.files(dir_ndvi, pattern = ".tif"),
                        start = 8, end = 17) %>% ymd())

timediff2 <- 
  tibble(file_name = c(list.files(dir_ndvi, pattern = ".tif"))) %>%
  mutate(date = str_sub(list.files(dir_ndvi, pattern = ".tif"),
                        start = 8, end = 17) %>% ymd()) %>%
  pad() %>%
  filter(is.na(file_name))
  

for (i in c(9:(nrow(timediff2) - 3))){ # remove first and last layers

  tic()
  
  # create table with target raster, day differences, and weights
  # target raster has a weight of 10, and for each day (before and after)
  # the weight decrease of a unit, with the 9th day with a w = 1 
  sub <- 
    timediff %>%
    dplyr::filter(date > timediff2[i, 2] - 8 & date < timediff2[i, 2] + 8) %>%
    pad() %>%
    filter(date == timediff2[i, 2] | !is.na(file_name)) %>%
    mutate(start = timediff2[i, 2] - 8) %>%
    mutate(day = as.numeric(date - start$date))
  
  # create raster stack with target tiles
  tile <- stack(
    paste0(dir_ndvi, "interpolated/inter_", sub$file_name[!is.na(sub$file_name)]))
  names(tile) <- str_sub(sub$file_name[!is.na(sub$file_name)], 14, 23)

  # create empty raster where to place output values
  empty <- tile[[1]]
  values(empty) <- NA
  names(empty) <- as.character(c(timediff2[i, 2])$date)
  
  # information for the for loop (to check the status)
  print(timediff2[i, 2]$date)
  
  days <- sub$day[sub$day != 8]
  vals <- values(tile)
  

  # for loop approach ----
  new_vals2 <- vector("numeric", nrow(vals))
  for (v in 1:nrow(vals)) {

    new_vals2[v] <- ifelse(
      test = sum(!is.na(c(vals[v, 1:ncol(vals)]))) >= 2,
      yes = approx(days,
                   c(vals[v, 1:ncol(vals)]),
                   xout = 8,
                   rule = 2)$y,
      no = NA
    )
  }
  # ----
  
  values(empty) <- new_vals2

  writeRaster(empty,
              paste0("F:/4_UngulAlps/high_resolution_ndvi/interpolated/", 
                     "inter_openEO_", timediff2[i, 2]$date, "Z.tif"),
              overwrite = TRUE)
  
  toc()
  gc()
}
