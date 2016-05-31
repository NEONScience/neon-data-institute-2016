## ----load-libraries, warning=FALSE, results='hide', message=FALSE--------
# load libraries
library(raster)
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


## ----create-hillshade----------------------------------------------------
slope <- terrain(dsm, opt='slope')
aspect <- terrain(dsm, opt='aspect')
# create hillshade
# numbers 
dsm.hill <- hillShade(slope, aspect, 
                      angle=40, 
                      direction=270)

plot(dsm.hill,
     col=grey.colors(100, start=0, end=1),
     legend=F)
# overlay CHM on top of hillshade
plot(chm,
     add=T,
     alpha=.4)


## ----export-geotiff, eval=FALSE------------------------------------------
## 
## # export geotiff
## writeRaster(dsm.hill,
##             filename="outputs/TEAK/Teak_dsm_hill.tif",
##             format="GTiff",
##             options="COMPRESS=LZW",
##             overwrite = TRUE,
##             NAflag = -9999)
## 
## 

