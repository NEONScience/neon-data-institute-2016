## ----load-libraries, warning=FALSE, results='hide', message=FALSE--------
# load libraries
library(raster)
library(rhdf5)
library(rgdal)

# be sure to set your working directory
# setwd("~/Documents/data/NEONDI-2016") # Mac
# setwd("~/data/NEONDI-2016")  # Windows

#source("/Users/lwasser/Documents/GitHub/neon-aop-package/neonAOP/R/aop-data.R")


## ----import-lidar--------------------------------------------------------

# read LiDAR canopy height model
chm <- raster("NEONdata/D17-California/TEAK/2013/lidar/TEAK_lidarCHM.tif")


## ----explore-chm---------------------------------------------------------
# assign chm values of 0 to NA
chm[chm==0] <- NA

# do the values in the data look reasonable?
plot(chm,
     main="Canopy Height \n LowerTeakettle, California")

hist(chm,
     main="Distribution of Canopy Height  \n Lower Teakettle, California",
     xlab="Tree Height (m)",
     col="springgreen")



## ----import-aspect-data--------------------------------------------------

# calculate aspect of cropped DTM
# aspect <- terrain(your-dem-or-terrain-data.tif, opt = "aspect", unit = "degrees", neighbors = 8)
# example code:
# aspect <- terrain(all.data[[3]], opt = "aspect", unit = "degrees", neighbors = 8)
# read in aspect .tif
aspect <- raster("NEONdata/D17-California/TEAK/2013/lidar/TEAK_lidarAspect.tif")

plot(aspect,
     main="Aspect for Lower Teakettle Field Site",
     axes=F)


## ----classify-raster-----------------------------------------------------

# first create a matrix of values that represent the classification ranges
# North facing = 1
# South facing = 2
class.m <- c(0, 45, 1,
             45, 135, NA,
             135, 225, 2,  
             225 , 315, NA,
             315, 360, 1)
class.m

# reshape the object into a matrix with columns and rows
rcl.m <- matrix(class.m, 
                ncol=3, 
                byrow=TRUE)
rcl.m

# reclassify the raster using the reclass object - rcl.m
asp.ns <- reclassify(aspect, 
                     rcl.m)

# plot outside of the plot region

# make room for a legend
par(xpd = FALSE, mar=c(5.1, 4.1, 4.1, 4.5))
# plot
plot(asp.ns,
     col=c("white","blue","green"), # hard code colors, unclassified (0)=white,
		 #N (1) =blue, S(2)=green
     main="North and South Facing Slopes \nLower Teakettle",
     legend=F)
# allow legend to plot outside of bounds
par(xpd=TRUE)
# create the legend
legend((par()$usr[2] + 20), 4103300,  # set x,y legend location
       legend = c("North", "South"),  # make sure the order matches the colors, next
       fill = c("blue", "green"),
       bty="n") # turn off border


## ----export-geotiff, eval=FALSE------------------------------------------
## 
## # export geotiff
## writeRaster(asp.ns,
##             filename="outputs/TEAK/Teak_nsAspect.tif",
##             format="GTiff",
##             options="COMPRESS=LZW",
##             overwrite = TRUE,
##             NAflag = -9999)
## 

