---
layout: post
title: "Data Fusion - Advanced Raster mask issues - spatial extents"
date:   2016-06-10
authors: [Leah A. Wasser, Kyla Dahlin]
instructors: [Leah, Naupaka]
time:
contributors:
dateCreated:  2016-05-01
lastModified: 2016-05-18
packagesLibraries: [rhdf5]
categories: [self-paced-tutorial]
mainTag: institute-day2
tags: [R, HDF5]
tutorialSeries: [institute-day2]
description: "Work with masks using different data products. Extent issues."
code1: institute-materials/day2_tuesday/classify-raster-threshold.R
image:
  feature: 
  credit: 
  creditlink:
permalink: /R/masks-data-fusion-R/
comments: false
---

## About

In this tutorial, we will walk through how to classify a raster file using
defined value ranges in R. 

First, let's load the required libraries.


    # load libraries
    library(raster)
    library(rhdf5)
    library(rgdal)
    
    # set your working directory
    setwd("~/Documents/data/1_data-institute-2016")
    
    # import functions
    source("/Users/lwasser/Documents/GitHub/neon-aop-package/neonAOP/R/aop-data.R")

## Import LiDAR data

To begin, we will open the NEON LiDAR Digital Surface and Digital Terrain Models
(DSM and DTM) which are in Geotiff format.


    # read LiDAR data
    # dsm = digital surface model == top of canopy
    teak_nsAspect <- raster("outputs/Teak_nsAspect.tif")
    # dtm = digital terrain model = elevation

## Mask Data

Once we have created a threhold classified raster, we can use it for different things.
One application is to use it as an analysis mask for another dataset. 

Let's try to find all pixels that have an NDVI value >.6 and are north facing. 


    # w use dave's NDVI layer but for now...
    
    # Define the file name to be opened
    f <- "Teakettle/may1_subset/spectrometer/Subset3NIS1_20130614_100459_atmcor.h5"
    
    # define the CRS in EPGS format for the file
    epsg <- 32611
    # create a list of bands
    bands <- c(60,83)
    
    ndvi.stack <- create_stack(f, 
                               bands, 
                               epsg=32611)

    ## HDF5: unable to open file

    ## Error: Error in h5checktype(). Argument not of class H5IdComponent.

    # calculate NDVI
    ndvi <- (ndvi.stack[[2]]-ndvi.stack[[1]]) / (ndvi.stack[[2]]+ndvi.stack[[1]])

    ## Error in eval(expr, envir, enclos): object 'ndvi.stack' not found

    names(ndvi) <- "Teak_hsiNDVI"
    
    # let's test this out
    plot(ndvi)
    
    # let's create a mask
    ndvi[ndvi<.6] <- NA
    plot(ndvi)

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day2_tuesday/mask-raster-lidar-hyperspec-fusion-R/mask-data-1.png)

    # force the two to have the same CRS
    crs(ndvi) <- crs(asp.ns)
    # the two are different extents, crop both
    if(gIntersection(extent(ndvi), extent(asp.ns))){
      print("they overlap")
    }

    ## Error in eval(expr, envir, enclos): could not find function "gIntersection"

    # mask out only pixels that are north facing and NDVI >.6
    nFacing.ndvi <- mask(asp.ns,ndvi)

## Export Classified Raster


    # export geotiff 
    writeRaster(asp.ns,
                filename="Teakettle/outputs/Teak_nsAspect.tif",
                format="GTiff",
                options="COMPRESS=LZW",
                overwrite = TRUE,
                NAflag = -9999)
