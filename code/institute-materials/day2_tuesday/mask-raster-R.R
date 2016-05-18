## ----load-libraries, warning=FALSE, results='hide', message=FALSE--------
# load libraries
library(raster)
library(rhdf5)
library(rgdal)

# set your working directory
setwd("~/Documents/data/1_data-institute-2016")

# import functions
source("/Users/lwasser/Documents/GitHub/neon-aop-package/neonAOP/R/aop-data.R")


## ----import-lidar--------------------------------------------------------

# import aspect data from previous lesson
teak_nsAspect <- raster("outputs/Teak_nsAspect.tif")

# North face = 1
# South face = 2
# plot outside of the plot region
# make room for a legend
par(xpd = FALSE, mar=c(5.1, 4.1, 4.1, 4.5))

plot(teak_nsAspect, 
     col=c("white","blue","green"),
     main="North and South Facing Slopes \nTeakettle",
     legend=F)

# allow legend to plot outside of bounds
par(xpd=TRUE)

legend((par()$usr[2] + 20), 4103300, # set xy legend location
       legend = c("North", "South"),
       fill = c("blue", "green"), 
       bty="n") # turn off border


## ----mask-data-ndvi------------------------------------------------------

# open NEON NDVI data
ndvi <- raster("NEONdata/TEAK/2013/spectrometer/veg_index/NEON.D17.TEAK.DP2.20130614_100459_NDVI.tif")
ndvi

hist(ndvi,
     main="NDVI for Teakettle Field Site")

# let's create a mask
ndvi[ndvi<.6] <- NA
plot(ndvi,
     main="NDVI > .6")


## ----mask-data-----------------------------------------------------------

n.face.aspect <- teak_nsAspect==1

# mask out only pixels that are north facing and NDVI >.6
nFacing.ndvi <- mask(n.face.aspect, ndvi)

plot(nFacing.ndvi,
     main="North Facing locations \n NDVI > .6",
     legend=F)


## ----export-geotiff, eval=FALSE------------------------------------------
## 
## # export geotiff
## writeRaster(nFacing.ndvi,
##             filename="Teakettle/outputs/Teak_n_ndvi6.tif",
##             format="GTiff",
##             options="COMPRESS=LZW",
##             overwrite = TRUE,
##             NAflag = -9999)
## 
## 

