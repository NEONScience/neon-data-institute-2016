---
layout: redirected
sitemap: false
permalink: /R/calculate-ndvi/
---

First, let's load the required libraries.


    # load libraries
    library(raster)
    library(rhdf5)
    library(rgdal)

## Load Functions

Once we have done the work to build our functions, we can perform routine tasks
over and over using those functions.

Note: if you have not yet loaded the `neonAOP` package, please see directions 
for how to do this at the top of the 
<a href="{{ site.basurl }}/R/plot-spectral-signature/" target="_blank"> *Plot a Spectral Signature from Hyperspectral Remote Sensing data in R - HDF5* tutorial</a>. 


    ## call function library
    library(neonAOP)

## Calculate NDVI

Next, we can use the `create_stack` function to create a raster stack of the
red and near-infrared bands that we need to calculate NDVI.


    # set working directory
    # setwd("~/Documents/data/NEONDI-2016")
    # setwd("~/data/NEONDI-2016")  # Windows
    
    # Define the file name to be opened
    f <- "NEONdata/D17-California/TEAK/2013/spectrometer/reflectance/Subset3NIS1_20130614_100459_atmcor.h5"
    
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

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day1_monday/calculate_ndvi_h5/create-NDVI-1.png)

## Export to GeoTIFF


    # export as a GeoTIFF
    writeRaster(ndvi_rast,
                file="outputs/TEAK/ndvi_2013.tif",
                format="GTiff",
                overwrite=TRUE)

## Plot NDVI


    DSM <- raster("NEONdata/D17-California/TEAK/2013/lidar/TEAK_lidarDSM.tif")  
    
    slope <- terrain(DSM, opt='slope')
    aspect <- terrain(DSM, opt='aspect')
    
    # create hillshade
    hill <- hillShade(slope, aspect, 40, 270)
    
    plot(hill,
         col=grey(1:100/100),
         main="NDVI for the Lower Teakettle Field site",
         legend=FALSE)
    
    plot(ndvi_rast,
         add=TRUE,
         alpha=.3
         )

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day1_monday/calculate_ndvi_h5/import-lidar-1.png)
