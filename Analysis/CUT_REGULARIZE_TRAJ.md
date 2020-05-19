
# Setting working space
```
rm(list=ls())
sessionInfo()

library(adehabitatLT) # I use this pkg, you could use others or write raw code
library(lubridate)
```




# Data exploration
Below the procedure I use to regularize and cut trajectories. I am sure you have used some of this code, but I try to keep it all so to increase reproducibility. Here's the [vignette](https://tinyurl.com/ycnj3v9v) for the adehabitatHR Package 


### First, convert the dataframe to ltraj
```
ltraj <- as.ltraj(xy = df[,c("x","y")], # make sure you are working with UTM coords!!
                  id = df[, c("id")],
                  date = df[, c("acquisition_time")],
                  infolocs = df[, c("dop","temp")]) # you can add anything on infolocs
```



### Next, data exploration
```
plotltr(ltraj, "dt/3600") # Time interval between GPS positions (in HOURS)
plotltr(ltraj, "dist") # Distance between successive relocations
plotltr(ltraj, "R2n") # Net Square Displacement
plotltr(ltraj, "dop") # DOP

plotNAltraj(ltraj) # plot NA over time
summaryNAltraj(ltraj) # summary statistics for NAs 
```





# Cut traj
Then, based on the ecology of your species and sampling protocol, traj can be prepared for later regularization. I think it is important to first cut the trajectories to avoid 'large' interpolations (the larger the gap between locs, the more points will be generated)


### 1. Remove gaps larger than (e.g.) 1 days in the monitoring
```
foo <- function(dt) { return(dt > (1 * 3600 * 24)) }
ltraj <- cutltraj(ltraj, "foo(dt)", nextr = TRUE)
```

### 2. discard monitoring (e.g.) < 50 locs
```
ltraj <- ltraj[which(summary(ltraj)$nb.reloc>100)]
```

### 3. discard monitoring (e.g.) < 14 days
```
ltraj <- ltraj[which(summary(ltraj)$date.end - summary(ltraj)$date.begin > 15)]
```





# Regularize traj
Now you can interpolate GPS locations linearly.  

As reported in the [vignette](https://tinyurl.com/ycnj3v9v): _"Such an interpolation may be of limited value when many relocations are missing (because it supposes implicitly that the animal is moving along a straight line)"_. For this reason you should prepare the trajectory beforehand

```
for (i in 1:length(ltraj) ) {
  
  ref_t <- round_date(ltraj[[i]]$date[1], unit = "hours") # reference date for regular t 
  
  ltraj[i] <- setNA( # set NAs in the trajectory at regular time 
    ltraj[i], ref_t, dt = 360, units = "min") # (e.g. 6 hours)
  
  ltraj[i] <- sett0( # Rounding timing to define a regular trajectory
    ltraj[i], ref_t, dt = 360, units = "min", correction.xy = "none") # (e.g. 6 hours)
  
  ltraj[i] <- redisltraj( # Rediscretizing the trajectory in time
    na.omit(ltraj[i]), u = 21600, type = "time") # (e.g. 6 hours, step duration in sec)
}
```
