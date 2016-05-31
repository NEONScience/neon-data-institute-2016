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

# read LiDAR data
# dsm = digital surface model == top of canopy
dsm <- raster("NEONdata/D17-California/TEAK/2013/lidar/Teak_lidarDSM.tif")
# dtm = digital terrain model = elevation
dtm <- raster("NEONdata/D17-California/TEAK/2013/lidar/Teak_lidarDTM.tif") 

# lets also import the canopy height model (CHM).
chm <- raster("NEONdata/D17-California/TEAK/2013/lidar/Teak_lidarCHM.tif")


## ----explore-chm---------------------------------------------------------
# assign chm values of 0 to NA
chm[chm==0] <- NA

# do the numbers look reasonable? 60 m is tall for a tree, but
# this is Ponderosa pine territory (I think), so not out of the question.
plot(chm,
     main="Canopy Height - Teakettle \nCalifornia") 

hist(chm,
     main="Distribution of Canopy Height - Teakettle \nCalifornia",
     xlab="Tree Height (m)", 
     col="springgreen")



## ----import-aspect-data--------------------------------------------------

# (1) calculate aspect of cropped DTM
# aspect <- terrain(all.data[[3]], opt = "aspect", unit = "degrees", neighbors = 8)
aspect <- raster("NEONdata/D17-California/TEAK/2013/lidar/Teak_lidarAspect.tif")

plot(aspect,
     main="Aspect for Teakettle Field Site",
     axes=F)


## ----classify-raster-----------------------------------------------------

# first create a matrix of values that represent the classification ranges
# North face = 1
# South face = 2
class.m <- c(0, 45, 1, 
             45, 135, NA, 
             135, 225, 2,  
             225 , 315, NA, 
             315, 360, 1)
class.m

# shape the object into a matrix with columns and rows
rcl.m <- matrix(class.m, ncol=3, byrow=TRUE)
rcl.m

# reclassify the raster using the reclass object - rcl.m
asp.ns <- reclassify(aspect, rcl.m)

# plot outside of the plot region
# make room for a legend
par(xpd = FALSE, mar=c(5.1, 4.1, 4.1, 4.5))

plot(asp.ns, 
     col=c("white","blue","green"),
     main="North and South Facing Slopes \nTeakettle",
     legend=F)

# allow legend to plot outside of bounds
par(xpd=TRUE)

legend((par()$usr[2] + 20), 4103300, # set xy legend location
       legend = c("North", "South"),
       fill = c("blue", "green"), 
       bty="n") # turn off border


## ----export-geotiff, eval=FALSE------------------------------------------
## 
## # export geotiff
## writeRaster(asp.ns,
##             filename="Teakettle/outputs/Teak_nsAspect.tif",
##             format="GTiff",
##             options="COMPRESS=LZW",
##             overwrite = TRUE,
##             NAflag = -9999)
## 

