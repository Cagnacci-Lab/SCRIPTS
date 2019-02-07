 maxdistpoly <-  function(geom_poly, lonlat=FALSE, calc ='within'){
    # maximum distance within polygons
    geom_poly$maxdist <- NA
    maxdist <- NA
    geom_point <-as.data.frame(st_coordinates(st_as_sf(geom_poly)))
    coordinates(geom_point) <- ~X+Y
    proj4string(geom_point)<- geom_poly@proj4string
    
    # MAX DISTANCE WITHIN POLYGONS IN THE DATASET
    if(calc == 'within'){
      geom_point_l <- split(geom_point, f=geom_point@data$L2)
      for(i in 1:length(geom_point_l)){
        x <- geom_point_l[[i]]
        if(lonlat == FALSE){
          pd <-  pointDistance(x, x, lonlat=FALSE, allpairs=TRUE)
          maxdist <-max(pd)
          geom_poly@data$maxdist[i] <- maxdist
        }
        if(lonlat == TRUE){
          pd <-  pointDistance(x, x, allpairs=TRUE)
          maxdist <-max(pd) 
          geom_poly@data$maxdist[i] <- maxdist
          
        }
      }
      
      maxdist <- geom_poly@data$maxdist
      return(list(geom_poly,maxdist))
    }
    # MAX DISTANCE BETWEEN ALL POLYGONS IN THE DATASET
    if(calc == 'between'){
      x <- geom_point 
      if(lonlat == FALSE){
        pd <-  pointDistance(x, x, lonlat=FALSE, allpairs=TRUE)
        maxdist <-max(pd)
      }
      if(lonlat == TRUE){
        pd <-  pointDistance(x, x, allpairs=TRUE)
        maxdist <-max(pd) 
      }
      return(maxdist)
    }

  }
  
