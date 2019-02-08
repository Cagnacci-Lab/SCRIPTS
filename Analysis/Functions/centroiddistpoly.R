
centroiddistpoly <-  function(geom_poly, lonlat=FALSE){
    # maximum distance within polygons
    geom_poly$dist_from_popcentroid <- NA
    geom_point <-as.data.frame(st_coordinates(st_as_sf(geom_poly)))
    coordinates(geom_point) <- ~X+Y
    proj4string(geom_point)<- geom_poly@proj4string
    geom_point$L1 <- 1
    centroid_per_animal <- as(st_centroid(st_as_sf(geom_poly)),'Spatial')
    centroid_population <- as(st_centroid(st_as_sf(mcp(geom_point, percent=100, unin='m'))),'Spatial')
    
          # distance between centroids of individual mcps
          dist_between_animals <-  pointDistance(centroid_per_animal, centroid_per_animal, lonlat=FALSE, allpairs=TRUE)
          # maximum distance between centroids

          # distance between population centroid (mcp) and individual centroids of mcps
          dist_from_popcentroid <-  pointDistance(centroid_per_animal, centroid_population, lonlat=FALSE, allpairs=TRUE)
          geom_poly@data$dist_from_popcentroid <- dist_from_popcentroid

          # maximum distance between individual centroid, maximum distance between individuals and population centroid
          max_dist_between_animals <- max(dist_between_animals)
          max_dist_from_popcentroid <- max(dist_from_popcentroid)
          
          # line between centroid individual and centroid population
          points_centroid_dist_from_popcentroid <- list(as(st_centroid(st_as_sf(geom_poly[which(geom_poly@data$dist_from_popcentroid == max_dist_from_popcentroid),])),'Spatial')[,c(1,2)], centroid_population)
          sp_lines  <- SpatialLines(list(Lines(list(Line(points_centroid_dist_from_popcentroid[[1]])), "line1")))
          proj4string(sp_lines) <- geom_poly@proj4string
          # line between centroid individuals
          
          
          max_distance <- data.frame(
            measure=c('maximum distance between individual centroids','maximum distance from population centroid'),
            max=c(max_dist_between_animals,max_dist_from_popcentroid))

         return(list(geom_poly,dist_between_animals,max_distance))
    }
