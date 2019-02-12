centroiddistpoly <-  function(geom_poly, lonlat=FALSE, cols=c('red','blue')){
  
  # element 1 in the list are the MCPS including the distance from the population centroid for each individual
  # element 2 in the list is the matrix of distances between all pairs of individuals. 
  # element 3 in the list gives the spatial lines of the maximum distance between population centroid and individuals and between all pairs of individuals 
  # element 4 in the list gives the centroid of the population
  
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
  dist_between_animals[which(dist_between_animals==max_dist_between_animals)]
  max_dist_from_popcentroid <- max(dist_from_popcentroid)

  # line between centroid individuals
  colnames(dist_between_animals) <- centroid_per_animal@data$id
  rownames(dist_between_animals) <- centroid_per_animal@data$id
  pair <- subset(as.data.frame(as.table(dist_between_animals)),Freq == max_dist_between_animals)[1,]
  pointpair <- centroid_per_animal[which(centroid_per_animal@data$id %in% unlist(as.vector(pair[,c('Var1','Var2')]))),]
  
  pointpair_to_line <- rbind(pointpair[1,], pointpair[2,])
  #sp_lines_pointpair  <- SpatialLines(list(Lines(list(Line(pointpair_to_line[[1]])), "line1")))
  sp_lines_pointpair  <-points_to_line(as.data.frame(pointpair_to_line@coords), long='coords.x1',lat='coords.x2')
  proj4string(sp_lines_pointpair) <- geom_poly@proj4string  
    
  # line between centroid individual and centroid population
  points_centroid_dist_from_popcentroid <- rbind(as(st_centroid(st_as_sf(geom_poly[which(geom_poly@data$dist_from_popcentroid == max_dist_from_popcentroid),])),'Spatial')[,c(1,2)], centroid_population)
  sp_lines <-points_to_line(as.data.frame(points_centroid_dist_from_popcentroid@coords), long='coords.x1',lat='coords.x2')
  #sp_lines  <- SpatialLines(list(Lines(list(Line(points_centroid_dist_from_popcentroid[[1]])), "line1")))
  proj4string(sp_lines) <- geom_poly@proj4string
  
  
  # merge two lines 
  max_distance_lines <- rbind(sp_lines_pointpair, sp_lines)
  # summary info of both lines representing the maximum distance 
  max_distance <- data.frame(
    measure=c('maximum distance from population centroid','maximum distance between individual centroids'),
    max=c(max_dist_from_popcentroid,max_dist_between_animals), col=c('red','blue'), stringsAsFactors = FALSE)
  max_distance_lines_sf <- st_as_sf(max_distance_lines)
  max_distance_lines_sf$measure <- max_distance$measure  
  max_distance_lines_sf$max <- max_distance$max  
  max_distance_lines_sf$col <- max_distance$col
  max_distance_lines_sp <- as(max_distance_lines_sf,'Spatial')
  geom_poly@data$dist_from_popcentroid_round <- round(geom_poly@data$dist_from_popcentroid)
  
  colll = data.frame(dist_from_popcentroid_round=c(min(geom_poly@data$dist_from_popcentroid_round):max(geom_poly@data$dist_from_popcentroid_round)), col=NA)
  colll$col <- colorRampPalette(cols)(nrow(colll))
  geom_poly@data <- plyr::join(geom_poly@data, colll, type='left', by = 'dist_from_popcentroid_round')
  geom_poly@data$dist_from_popcentroid_round <- NULL 
  
  return(list(geom_poly,dist_between_animals,max_distance_lines_sp, centroid_population))
  
  # calculate distance from population centroid and distance between centroids of individuals 
  # res <- centroiddistpoly(geom_poly, cols=c('red','orange','yellow'))
  
  # element 1 in the list are the MCPS including the distance from the population centroid for each individual
  # mcps <- res[[1]]
  # element 2 in the list is the matrix of distances between all pairs of individuals. 
  # ind_dist_matrix <- res[[2]]
  # element 3 in the list gives the spatial lines of the maximum distance between population centroid and individuals and between all pairs of individuals 
  # maxdist_lines <- res[[3]]
  # element 4 in the list gives the centroid of the population
  # population_centroid <- res[[4]]
}
