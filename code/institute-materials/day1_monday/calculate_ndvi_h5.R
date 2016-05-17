## ----load-libraries, warning=FALSE, results='hide', message=FALSE--------

# load libraries
library(raster)
library(rhdf5)
library(rgdal)


## ----load-functions------------------------------------------------------

source("/Users/lwasser/Documents/GitHub/neon-aop-package/neonAOP/R/aop-data.R")


## ----create-NDVI---------------------------------------------------------

# set working directory
setwd("~/Documents/data/1_data-institute-2016")
# Define the file name to be opened
f <- "Teakettle/may1_subset/spectrometer/Subset3NIS1_20130614_100459_atmcor.h5"

# define CRS
epsg=32611

# Calculate NDVI
# select bands to use in calculation (red, NIR)
ndvi_bands <- c(58, 90)

#create raster list and then a stack using those two bands
ndvi_stack <-  create_stack(ndvi_bands,
                            file = f,
                            epsg = epsg)

# calculate NDVI
NDVI <- function(x) {
	  (x[,2]-x[,1])/(x[,2]+x[,1])
}

ndvi_rast <- calc(ndvi_stack, NDVI)

# clear out plots
# dev.off(dev.list()["RStudioGD"])

plot(ndvi_rast, 
     main="NDVI for the NEON TEAK Field Site")



## ----export-ndvi, eval=FALSE---------------------------------------------
## 
## # export as a gtif
## writeRaster(ndvi_rast,
##             file="ndvi_TEAK.tif",
##             format="GTiff",
##             overwrite=TRUE)
## 

## ----import-lidar--------------------------------------------------------

DSM <- raster("Teakettle/may1_subset/lidar/Teak_lidarDSM.tif")  

slope <- terrain(DSM, opt='slope')
aspect <- terrain(DSM, opt='aspect')

# create hillshade
hill <- hillShade(slope, aspect, 40, 270)

plot(hill,
     col=grey(1:100/100),
     main="NDVI for the Teakettle Field site",
     legend=FALSE)

plot(ndvi_rast, 
     add=TRUE,
     alpha=.3
     )

