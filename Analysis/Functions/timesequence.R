timesequence <- function(data, timestamp_column = 'acquisition_time', by = "8 DSTdays"){
  require(lubridate)
  # generates time sequence based on minimum date in timeseries 

  # data is your data set including the timestamps 
  # timestamp_column is the timestamp in your data set
  # by is the number of days for which you want to generate a time sequence 

  # NOTE that the timestamps are rounded using floor (corresponding to the actual 'date' of the timestamp)  

  # original timestamps 
  timex <- data[,timestamp_column]
  # number of timestamps based on start and end date of the dataset 
  nr_vals <- ceiling(as.numeric(difftime(max(timex), min(timex), units = c("secs")))/60/60/24/as.numeric(gsub(' DSTdays','',by)))
  # generate sequence 
  data.frame(timestamps = seq(floor_date(min(timex), unit="day"), by = by, length.out = nr_vals))  
}
