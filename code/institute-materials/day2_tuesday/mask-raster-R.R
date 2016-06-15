## ----load-libraries, warning=FALSE, results='hide', message=FALSE--------
# load libraries
library(raster)
library(rhdf5)
library(rgdal)

# be sure to set your working directory
# setwd("~/Documents/data/NEONDI-2016") # Mac
# setwd("~/data/NEONDI-2016")  # Windows

## import functions
# install devtools (only if you have not previously intalled it)
#install.packages("devtools")
# call devtools library
#library(devtools)

# install from github
#install_github("lwasser/neon-aop-package/neonAOP")
# call library
library(neonAOP)


#source("/Users/lwasser/Documents/GitHub/neon-aop-package/neonAOP/R/aop-data.R")



## ----import-lidar--------------------------------------------------------

# import aspect data from previous lesson
teak_nsAspect <- raster("outputs/TEAK/TEAK_nsAspect.tif")

# North facing slope = 1
# South facing slope = 2

# legend outside of the plot region
# make room for a legend
par(xpd = FALSE, mar=c(5.1, 4.1, 4.1, 4.5))

plot(teak_nsAspect, 
     col=c("white","blue","green"),
     main="North and South Facing Slopes \n Lower Teakettle",
     legend=F)

# allow legend to plot outside of bounds
par(xpd=TRUE)

legend((par()$usr[2] + 20), 4103300, # set xy legend location
       legend = c("North", "South"),
       fill = c("blue", "green"), 
       bty="n") # turn off border


## ----mask-data-ndvi------------------------------------------------------

# open NEON NDVI data
ndvi <- raster("NEONdata/D17-California/TEAK/2013/spectrometer/veg_index/TEAK_NDVI.tif")
ndvi

hist(ndvi,
     main="NDVI for Lower Teakettle Field Site")

# let's create a mask
ndvi[ndvi<.6] <- NA
plot(ndvi,
     main="NDVI > .6")


## ----mask-data-----------------------------------------------------------

n.face.aspect <- teak_nsAspect==1

# mask out only pixels that are north facing and NDVI >.6
nFacing.ndvi <- mask(n.face.aspect, ndvi)

plot(nFacing.ndvi,
     main="North Facing Locations \n NDVI > .6",
     legend=F)


## ----export-geotiff, eval=FALSE------------------------------------------
## 
## # export geotiff
## writeRaster(nFacing.ndvi,
##             filename="outputs/TEAK/TEAK_n_ndvi6.tif",
##             format="GTiff",
##             options="COMPRESS=LZW",
##             overwrite = TRUE,
##             NAflag = -9999)
## 
## 

