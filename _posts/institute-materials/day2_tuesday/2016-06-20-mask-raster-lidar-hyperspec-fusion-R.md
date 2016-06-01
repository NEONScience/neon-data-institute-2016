---
layout: post
title: "Dealing with Spatial Extents when working with Heterogeneous Data"
date:   2016-06-10
authors: [Leah A. Wasser, Kyla Dahlin]
instructors: [Leah, Naupaka]
time:
contributors:
dateCreated:  2016-05-01
lastModified: 2016-05-31
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
    teak_nsAspect <- raster("outputs/TEAK/Teak_nsAspect.tif")
    # dtm = digital terrain model = elevation

## Mask Data

Once we have created a threhold classified raster, we can use it for different things.
One application is to use it as an analysis mask for another dataset. 

Let's try to find all pixels that have an NDVI value >.6 and are north facing. 


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

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day2_tuesday/mask-raster-lidar-hyperspec-fusion-R/mask-data-1.png)

    # let's create a mask
    ndvi[ndvi<.6] <- NA
    plot(ndvi)

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day2_tuesday/mask-raster-lidar-hyperspec-fusion-R/mask-data-2.png)

    # force the two to have the same CRS
    crs(ndvi) <- crs(asp.ns)

# Create Raster Stack

Next, let's create a raster stack of ndvi and aspect.

    new.stack <- stack(asp.ns, ndvi)

    ## Error in compareRaster(x): different extent

Notice we get an error. Why?
Let's compare the extents of the two objects


    extent(ndvi)

    ## class       : Extent 
    ## xmin        : 325963 
    ## xmax        : 326507 
    ## ymin        : 4102904 
    ## ymax        : 4103482

    extent(asp.ns)

    ## class       : Extent 
    ## xmin        : 325963 
    ## xmax        : 326506 
    ## ymin        : 4102905 
    ## ymax        : 4103482

The extents are slightly different. They are one pixel apart in ymin and xmax.
Thus, when we try to create a stack, we get an error. All layers in a stack
need to be of the same extent.

We can create an if statement that checks the extent and crops both rasters to the 
overlap. Let's try it. 



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

    ## [1] "Extents are different, cropping data"

    # let's try to create a stack again.
    new.stack <- stack(asp.ns,ndvi)



    # mask out only pixels that are north facing and NDVI >.6
    nsFacing.ndvi <- mask(new.stack[[1]], new.stack[[2]])
    nsFacing.ndvi[nsFacing.ndvi==0] <- NA

## Create Final Plot


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

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day2_tuesday/mask-raster-lidar-hyperspec-fusion-R/plot-data-1.png)

## Export Classified Raster


    # export geotiff 
    writeRaster(asp.ns,
                filename="outputs/TEAK/Teak_nsAspect.tif",
                format="GTiff",
                options="COMPRESS=LZW",
                overwrite = TRUE,
                NAflag = -9999)
