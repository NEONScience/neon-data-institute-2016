## ----load-libraries, warning=FALSE, results='hide', message=FALSE--------
# load libraries
library(raster)
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

# read LiDAR data
# dsm = digital surface model == top of canopy
dsm <- raster("NEONdata/D17-California/TEAK/2013/lidar/TEAK_lidarDSM.tif")
# dtm = digital terrain model = elevation
dtm <- raster("NEONdata/D17-California/TEAK/2013/lidar/TEAK_lidarDTM.tif") 

# lets also import the canopy height model (CHM).
chm <- raster("NEONdata/D17-California/TEAK/2013/lidar/TEAK_lidarCHM.tif")


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
##             filename="outputs/TEAK/TEAK_dsm_hill.tif",
##             format="GTiff",
##             options="COMPRESS=LZW",
##             overwrite = TRUE,
##             NAflag = -9999)
## 
## 

