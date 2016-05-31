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
teak_nsAspect <- raster("outputs/TEAK/Teak_nsAspect.tif")
# dtm = digital terrain model = elevation



## ----mask-data-----------------------------------------------------------
# Define the file name to be opened
f <- "/NEONdata/D17-California/TEAK/2013/spectrometer/Subset3NIS1_20130614_100459_atmcor.h5"

# define the CRS in EPGS format for the file
epsg <- 32611
# create a list of bands
bands <- c(60,83)

ndvi.stack <- create_stack(f, 
                           bands, 
                           epsg=32611)

# calculate NDVI
ndvi <- (ndvi.stack[[2]]-ndvi.stack[[1]]) / (ndvi.stack[[2]]+ndvi.stack[[1]])
names(ndvi) <- "Teak_hsiNDVI"

# let's test this out
plot(ndvi)

# let's create a mask
ndvi[ndvi<.6] <- NA
plot(ndvi)

# force the two to have the same CRS
crs(ndvi) <- crs(asp.ns)
# the two are different extents, crop both
if(gIntersection(extent(ndvi), extent(asp.ns))){
  print("they overlap")
}

# mask out only pixels that are north facing and NDVI >.6
nFacing.ndvi <- mask(asp.ns,ndvi)


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
## 

