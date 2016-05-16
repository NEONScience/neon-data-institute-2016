---
layout: post
title: "Classify a raster by threshold values in R"
date:   2016-06-19
authors: [Leah A. Wasser, Kyla Dahlin]
instructors: [Leah A. Wasser]
time: "10:15 am"
contributors: [Edmund Hart]
dateCreated:  2016-05-01
lastModified: 2016-05-06
packagesLibraries: [rhdf5]
categories: [self-paced-tutorial]
mainTag: institute-day2
tags: [R, HDF5]
tutorialSeries: [institute-day2]
description: "Classify raster data using ranges of values (thresholds)."
code1: .R
image:
  feature: 
  credit: 
  creditlink:
permalink: /R/classify-by-threshold-R/
comments: false
---

First, let's load the required libraries.


    # load libraries
    library(raster)
    library(rhdf5)
    library(rgdal)
    
    setwd("~/Documents/data/1_data-institute-2016")

## Import LiDAR data


    # note: plotting to look at things as you go is always recommmended!
      
    # first we read in the LiDAR data
    
    # dsm = digital surface model == top of canopy
    dsm <- raster("Teakettle/may1_subset/lidar/Teak_lidarDSM.tif")
    # dtm = digital terrain model = elevation
    dtm <- raster("Teakettle/may1_subset/lidar/Teak_lidarDTM.tif") 
    
    # rename to CHM
    # chm <- dsm - dtm
    chm <- raster("Teakettle/may1_subset/lidar/Teak_lidarCHM.tif")
    # assign chm values of 0 to NA
    chm[chm==0] <- NA
    
    # do the numbers look reasonable? 60 m is tall for a tree, but
    # this is Ponderosa pine territory (I think), so not out of the question.
    plot(chm,
         main="Canopy Height - Teakettle \nCalifornia") 

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day2_tuesday/classify-raster-threshold-R/import-lidar-1.png)

    hist(chm,
         main="Distribution of Canopy Height - Teakettle \nCalifornia",
         xlab="Tree Height (m)", 
         col="springgreen")

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day2_tuesday/classify-raster-threshold-R/import-lidar-2.png)




    # (1) calculate aspect of cropped DTM
    # aspect <- terrain(all.data[[3]], opt = "aspect", unit = "degrees", neighbors = 8)
    aspect <- raster("Teakettle/may1_subset/lidar/Teak_lidarAspect.tif")
    # crop the data to the extent of the other rasters we are working with!
    aspect <- crop(aspect, overlap)

    ## Error in .local(x, y, ...): Cannot get an Extent object from argument y

    # Create a classified intermediate product 
    # create mask -- 
    # (2) make 'dummy' (1s and 0s) layers for north facing (315 deg to 45 deg) and
    # south facing (135 deg to 225 deg) slopes
    
    # the other option is to create a CLASSIFIED RASTER
    # if that is classified than you can have a nice intermediate raster
    
    # first create a matrix of values that represent the classification ranges
    # North face = 1
    # South face = 2
    class.m <- c(0, 45, 1, 45, 135, NA, 135, 225, 2,  225 , 315, NA, 315, 360, 1)
    rcl.m <- matrix(class.m, ncol=3, byrow=TRUE)
    asp.ns <- reclassify(aspect, rcl.m)
    
    plot(asp.ns, 
         col=c("white","blue","green"),
         axes=F,
         main="North and South Facing Slopes \nTeakettle")

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day2_tuesday/classify-raster-threshold-R/import-aspect-1.png)

    # all values larger than 315 and less than 45 are north facing
    # north.facing <- aspect >= 315 | aspect <= 45
    # all values bewteen 135 and 225 are south facing
    # south.facing <- aspect >= 135 & aspect <= 225
    north.facing <- asp.ns==1
    south.facing <- asp.ns==2
    
    north.facing[north.facing == 0] <- NA
    south.facing[south.facing == 0] <- NA
    
    # export geotiff 
    writeRaster(asp.ns,
                filename="Teakettle/outputs/Teak_nsAspect.tif",
                format="GTiff",
                options="COMPRESS=LZW",
                overwrite = TRUE,
                NAflag = -9999)
