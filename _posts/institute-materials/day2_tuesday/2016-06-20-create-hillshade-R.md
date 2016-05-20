---
layout: post
title: "Create a Hillshade From a Terrain raster in R"
date:   2016-06-18
authors: [Leah A. Wasser, Kyla Dahlin]
instructors: [Leah, Naupaka]
time:
contributors:
dateCreated:  2016-05-01
lastModified: 2016-05-19
packagesLibraries: [rhdf5]
categories: [self-paced-tutorial]
mainTag: institute-day2
tags: [R, HDF5]
tutorialSeries: [institute-day2]
description: "Create a hillshade from a raster object in R."
code1: institute-materials/day2_tuesday/create-hillshade-R.R
image:
  feature: 
  credit: 
  creditlink:
permalink: /R/create-hillshade-R/
comments: false
---

## About

In this tutorial, we will walk through how to create a hillshade from terrain
rasters in R.

First, let's load the required libraries.


    # load libraries
    library(raster)
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
    dsm <- raster("NEONdata/TEAK/2013/lidar/Teak_lidarDSM.tif")
    # dtm = digital terrain model = elevation
    dtm <- raster("NEONdata/TEAK/2013/lidar/Teak_lidarDTM.tif") 
    
    # lets also import the canopy height model (CHM).
    chm <- raster("NEONdata/TEAK/2013/lidar/Teak_lidarCHM.tif")



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

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day2_tuesday/create-hillshade-R/create-hillshade-1.png)


## Export Classified Raster


    # export geotiff 
    writeRaster(dsm.hill,
                filename="Teakettle/outputs/Teak_dsm_hill.tif",
                format="GTiff",
                options="COMPRESS=LZW",
                overwrite = TRUE,
                NAflag = -9999)