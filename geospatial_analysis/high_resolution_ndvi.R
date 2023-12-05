
# # # # # # # # # # # # # # # # OpenEO NDVI # # # # # # # # # # # # # # # # # #
sessionInfo(); getwd()
rm(list = ls())

library(openeo)
library(tidyverse)
library(sf)
library(janitor)
library(fs)

# useful URL
# https://documentation.dataspace.copernicus.eu/APIs/openEO/R_Client/R.html
# https://r.iresmi.net/posts/2023/copernicus_openeo_ndvi_time_series/index.html
# https://docs.openeo.cloud/getting-started/r/
# https://r.geocompx.org/gis#openeo


# setting work space ----
con <- openeo::connect(host = "https://openeo.dataspace.copernicus.eu")
openeo::login() # an account is needed


# initialize ----
openeo::list_collections() # list of available satellite data
openeo::describe_collection("SENTINEL2_L2A") # check details sentinel2_l2a

# get the process collection for using the predefined processes of the back-end
p <- openeo::processes()
formats <- openeo::list_file_formats() # save format types into an object

# formulas ----

# to remove pixel not classified as vegetation (4) or non-vegetation (5), 
# i.e.: water, shadows, clouds, unclassified...
filter_unusable <- function(data, context) {
  scl <- data[3]
  !(scl == 4 | scl == 5) # https://tinyurl.com/959zwx5u pag.48 for specifics
}

# to compute NDVI
ndvi <- function(data, context) {
  red <- data[1]
  nir <- data[2]
  (nir - red) / (nir + red) 
}

# check processing status
status_job <- function(job) {
  while (TRUE) {
    if (!exists("started_at")) {
      started_at <- ymd_hms(job$created, tz = "UTC")
      message(capabilities()$title, "\n",
              "Job « ", job$description, " », ",
              "started on ", 
              format(started_at, tz = Sys.timezone(), usetz = TRUE), "\n")
    }
    
    current_status <- status(job)
    if (current_status == "finished") {
      message(current_status)
      break
    }
    
    current_duration <- seconds_to_period(difftime(Sys.time(),
                                                   started_at, 
                                                   units = "secs"))
    message(sprintf("%02d:%02d:%02d", 
                    current_duration@hour, 
                    minute(current_duration),
                    floor(second(current_duration))), " ",
            current_status, "...")
    Sys.sleep(30)
  }
}


# data retrieval ----

# set time and space range
## date_span <- c("2021-01-01", "2023-11-30") ## too big to process; use smaller spans instead 

date_span <- c("2023-09-01", "2023-11-30") # 3-month extraction
prj_bbox <- list(west = 10.36, south = 46.21, east = 11.22, north = 46.57)

# load collection of tiles
data <- 
  p$load_collection(
    id = "SENTINEL2_L2A",
    spatial_extent = prj_bbox,
    temporal_extent = date_span, 
    bands = c("B04", "B08", "SCL")
  )

# mask function (to remove clouds, water, etc.)
mask <- p$reduce_dimension(data, 
                           dimension = "bands",
                           reducer = filter_unusable)

# derive ndvi
result <- data |> 
  p$mask(mask) |> 
  p$reduce_dimension(dimension = "bands",
                     reducer = ndvi) |> 
  p$save_result(format = formats$output$GTiff)


# launch job ----
list_jobs(con) # list all jobs launched in the back-end

# create job, start, and check status 
job <- create_job(graph = result, title = "high_res_ndvi")
start_job(job); status_job(job)

list_results(job) # list result of launched job

# download clean tiles into external harddisk
download_results(job = job, folder = "F:/4_UngulAlps/high_resolution_ndvi")

# remove jobs
# list_jobs(con)[[1]]$id
# delete_job(list_jobs(con)[[1]]$id)

