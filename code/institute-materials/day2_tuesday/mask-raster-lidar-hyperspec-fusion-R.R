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
f <- "NEONdata/D17-California/TEAK/2013/spectrometer/reflectance/Subset3NIS1_20130614_100459_atmcor.h5"

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

## ----create-stack--------------------------------------------------------

new.stack <- stack(asp.ns, ndvi)


## ----compare-extents-----------------------------------------------------
extent(ndvi)
extent(asp.ns)

## ----check-extents-------------------------------------------------------

# check the extents of the two layers -- if they are different
# crop both datasets
if (extent(ndvi) == extent(asp.ns)){
  print("Extents are the same, no need to crop")
  } else {
  # calculate overlap between the two datasets
  overlap <- intersect(extent(ndvi), extent(asp.ns))
  # now let's crop both datasets to the overlap region
  ndvi <- crop(ndvi, overlap)
  asp.ns <- crop(asp.ns, overlap)
  print("Extents are different, cropping data")
  }

# let's try to create a stack again.
new.stack <- stack(asp.ns,ndvi)


## ----create-mask---------------------------------------------------------

# mask out only pixels that are north facing and NDVI >.6
nsFacing.ndvi <- mask(new.stack[[1]], new.stack[[2]])
nsFacing.ndvi[nsFacing.ndvi==0] <- NA
# plot extent
plot.extent <- extent(nsFacing.ndvi)

# plot 
plot(nsFacing.ndvi,
     main="North & South Facing pixels, NDVI > .6",
     col=c("blue","green"),
     legend=F)

# allow legend to plot outside of bounds
par(xpd=TRUE)

legend((par()$usr[2] + 20), plot.extent@ymax-200, # set xy legend location
       legend = c("North", "South"),
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
## 

