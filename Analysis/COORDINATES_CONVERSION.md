# Trasform coordinates (geographic to metric, and the other way around)

```r
library(sp)


# Load data
df <- read.csv()


# Convert coordinates to number in case the decimal are separated by a "," istead of a "."
df$longitude <- as.numeric(gsub(",", ".", df$longitude))
df$latitude <- as.numeric(gsub(",", ".", df$latitude))
# In case you have x & y the procedure is the same


# Now you can transform it in Spatial* object
coordinates(df) <- ~longitude+latitude
# OR coordinates(df) <- ~x+y  in case you have x and y
# REMEMBER that first goes the longitude or x, THEN latitude or y


# You assign the reference system
proj4string(df) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs") # WGS84

# You can access the code via https://spatialreference.org/ref/epsg/4326/ 
# Opening the link 'Proj4' on the box on the left
# You can search for any code on the webpage

# OR you can assign the reference system in this way
proj4string(df) <- CRS("+init=epsg:4326") # WGS84


# Now you can convert the Spatial* object with your new reference system
df <- spTransform(df, CRS("+init=epsg:3857")) # or use the 'Proj4' code as above


# and transform it back to dataframe
df <- as.data.frame(df)
```





# Convert geographic coordinates (DD, DDM, DMS)

Here's a brief brief [overview](https://www.pgc.umn.edu/apps/convert/)
* Decimal Degrees (DD)
* Degrees Decimal Minutes (DDM)
* Degrees Minutes Seconds (DMS)

```r
library(biogeo)


# Load you data
df <- read.csv()

# Here I loaded this csv table, the coordinates are the same but in different formats

#    sito       coordN      coordE
#  Sito 1 41°24'12.2"N 2°10'26.5"E   ## DMS
#  Sito 2   41 24.2028   2 10.4418   ## DDM
#  Sito 3     41.40338     2.17403   ## DD


# Convert the data to character in case they are loaded as factors (default in R 3.0v) 
df[,1] <- as.character( df[,1] ) # In my case this it the "Sito"
df[,2] <- as.character( df[,2] ) # "coordN"
df[,3] <- as.character( df[,3] ) # "coordE"


# Via this function dmsparse() it reads ANY coordinates format (DMS, DMM or DD)
parsing <- dmsparse(df, x= 'coordE', y='coordN', id= 'sito')
# REMEMBER: x = longitude = 'E' 
#           y = latitude = 'N'


# It creates a long table with all the information you need in several columns
str(parsing)
# In fact, if data are okay you have the DD already under the columns x and y
# Otherwise, you can get them manually by the function dms2dd() 

longitude <- dms2dd(parsing$xdeg, # x degree 
                   parsing$xmin,  # x minute
                   parsing$xsec,  # x second
                   "E")           # East because is longitude

# same below but with y and North
latitude <- dms2dd(parsing$ydeg, parsing$ymin, parsing$ysec, "N")
```

