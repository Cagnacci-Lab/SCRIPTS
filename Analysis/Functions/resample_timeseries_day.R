resample_timeseries <- function(data = SF, timestamp_column = 'acquisition_time', by = '8 DSTdays'){
  require(lubridate)
  # resample your dataset using one sample per x number of days 
  # data is your data set including the timestamps 
  # timestamp_column is the timestamp in your data set
  # by is the number of days for which you want to generate a time sequence 
  
  # NOTE that the timestamps are rounded using floor (corresponding to the actual 'date' of the timestamp)  
  
timeseq <- timeseq_day(data = data, timestamp_column = timestamp_column, by = by) # generate timeseries
timex <- data[,timestamp_column] # acquisition_time column in data set 
data$timestamps <- floor_date(timex, unit="day") # round date using floor as in the timesequence function and add column to data set
subs <- plyr::join(data, timeseq, type='inner', by ='timestamps') # extract only the relevant dates

do.call(rbind.data.frame,lapply(split(subs, subs$timestamps), function(x) sample_n(x,1))) # sample one timestamp per date

# EXAMPLE 
# sampled <- resample_timeseries(data = gpslocs_ani, timestamp_column = 'acquisition_time', by = '8 DSTdays')
}
