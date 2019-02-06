img_in_plot <-function(img, x, y, size){
  dims<-dim(img)[1:2] #number of x-y pixels for the logo (aspect ratio)
  AR<-dims[1]/dims[2]
  par(usr=c(0, 1, 0, 1))
  rasterImage(img, x-(size/2), y-(AR*size/2), x+(size/2), y+(AR*size/2), interpolate=TRUE)

# img <- readPNG()
# img_in_plot(img, x=0.5, y=0.5, size=1.5) 
}
