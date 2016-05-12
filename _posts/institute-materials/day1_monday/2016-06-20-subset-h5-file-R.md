---
layout: post
title: "Subset HDF5 file in R"
date:   2016-06-17
authors: [Leah A. Wasser]
instructors: []
contributors: []
time: "3:30 pm"
dateCreated:  2016-05-10
lastModified: 2016-05-12
packagesLibraries: [rhdf5]
categories: [self-paced-tutorial]
mainTag: institute-day1
tags: [R, HDF5]
tutorialSeries: [institute-day1]
description: "Learn how to subset an H5 file in R."
code1: subset-h5-file-R.R
image:
  feature: 
  credit: 
  creditlink:
permalink: /R/subset-hdf5-R/
comments: false
---


<div id="objectives">
<strong>R Skill Level:</strong> Intermediate

<h3>Goals / Objectives</h3>
After completing this activity, you will:
<ol>
<li>Understand how to extract and plot spectra from an HDF5 file.</li>
<li>Know how to work with groups and datasets within an HDF5 file.</li>
</ol>

</div> 

## Getting Started

In this tutorial, we will extract a single-pixel's worth of reflectance values 
from an HDF5 file and plot a spectral profile for that pixel.


    #first call required libraries
    library(rhdf5)
    library(raster)
    library(plyr)
    library(rgeos)
    library(rgdal)
    library(ggplot2)
    
    # be sure to set your working directory
    setwd("~/Documents/data/1_data-institute-2016")

## Import H5 Functions

In this scenario, we have built a suite of FUNCTIONS that will allow us to quickly
open and read NEON hyperspectral imagery data from an `hdf5` file. We can import
a suite of functions from an `.R` file using the `source` function. 


    # your file will be in your working directory! This one happens to be in a diff dir
    # than our data
    
    source("/Users/lwasser/Documents/GitHub/neon-data-institute-2016/_posts/institute-materials/day1_monday/import-HSIH5-functions.R")

## Open H5 File

Next, let's define a few variables, that we will need to access the H5 file.


    # Define the file name to be opened
    f <- "Teakettle/may1_subset/spectrometer/Subset3NIS1_20130614_100459_atmcor.h5"
    
    # Look at the HDF5 file structure 
    h5ls(f,all=T) 
    
    # define the CRS in EPGS format for the file
    epsg <- 32611

## Read Wavelength Values

Next, let's read in the wavelength center associated with each band in the HDF5 
file. 



    #read in the wavelength information from the HDF5 file
    wavelengths<- h5read(f,"wavelength")
    # convert wavelength to nanometers (nm)
    # NOTE: this is optional!
    wavelengths <- wavelengths*1000




## Get Subset
Next, we might want to extract just a subset of our data to pull a spectral
signature. For example a plot boundary.


    # get of H5 file map tie point
    h5.ext <- create_extent(f)
    
    # turn the H5 extent into a polygon to check overlap
    h5.ext.poly <- as(extent(h5.ext), "SpatialPolygons")
    
    # open file clipping extent
    clip.extent <- readOGR("Teakettle", "teak_plot")

    ## OGR data source with driver: ESRI Shapefile 
    ## Source: "Teakettle", layer: "teak_plot"
    ## with 1 features
    ## It has 1 fields

    # assign crs to h5 extent
    # paste0("+init=epsg:", epsg) -- so it will be better to use the proj string here
    
    crs(h5.ext.poly) <- CRS("+proj=utm +zone=11 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
      
    
    # ensure the two extents overlap
    gIntersects(h5.ext.poly, clip.extent)

    ## [1] TRUE

    # if they overlap, then calculate the extent
    # this doesn't currently account for pixel size at all
    # also these values need to be ROUNDED
    
    yscale <- 1
    xscale <- 1
    
    # define index extent
    # xmin.index, xmax.index, ymin.index,ymax.index
    # all units will be rounded which means the pixel must occupy a majority (.5 or greater) 
    # within the clipping extent
    index.bounds <- calculate_index_extent(extent(clip.extent), 
                                           h5.ext)
    
    # open a band that is subsetted using the clipping extent
    b58_clipped <- open_band(fileName=f,
              bandNum=58,
              epsg=32611,
              subsetData = TRUE,
              dims=index.bounds)
    
    # plot clipped bands
    plot(b58_clipped,
         main="Band 58 Clipped")

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day1_monday/subset-h5-file-R/extract-subset-1.png)

## Run subset over many bands


    # create  alist of the bands
    bands <- list(19,34,58)
    # within the clipping extent
    index.bounds <- calculate_index_extent(extent(clip.extent), 
                                                h5.ext)
    rgbRast.clip <- create_stack(file=f,
                             bands=bands,
                             epsg=epsg,
                             subset=TRUE,
                             dims=index.bounds)
    
    plotRGB(rgbRast.clip,
            stretch="lin")

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day1_monday/subset-h5-file-R/open-many-bands-1.png)

## Unclipped Data
And here are the same data not subsetted but with the subset region overlayed
on top.


    rgbRast <- create_stack(file=f,
                             bands=bands,
                             epsg=epsg,
                             subset=FALSE)
    
    plotRGB(rgbRast,
            stretch="lin")
    plot(clip.extent, 
         add=T,
         border="yellow",
         lwd=3)

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day1_monday/subset-h5-file-R/unnamed-chunk-1-1.png)

## View Spectra Within Clipped Raster


    # array containing the index dimensions to slice
    H5close()
    subset.h5 <- h5read(f, "Reflectance",
                        index=list(index.bounds[1]:index.bounds[2], index.bounds[3]:index.bounds[4], 1:426)) # the column, row 
    
    final.spectra <- data.frame(apply(subset.h5,
                  MARGIN = c(3), # take the mean value for each z value 
                  mean)) # grab the mean value in the z dimension
    final.spectra$wavelength <- wavelengths
    
    # scale the data
    names(final.spectra) <- c("reflectance","wavelength")
    final.spectra$reflectance <- final.spectra$reflectance / 10000
    
    
    # plot the data
    qplot(x=final.spectra$wavelength,
          y=final.spectra$reflectance,
          xlab="Wavelength (nm)",
          ylab="Reflectance",
          main="Mean Spectral Signature for Clip Region")

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day1_monday/subset-h5-file-R/subset-h5-file-1.png)


Now we've plotted a spectral signature. However, the values are averaged over all pixels in our
AOI. We may just want to explore the spectral of particular, thresholded object.

to do this

* i need to find the new tie point which will be a result of any averageing done above
* then i can spatially located this and turn it into a raster potentially?
* then i can create a MASK of just pixels with a particular raster value.

Let's give it a go


    # create a list of bands
    bands <- c(60,83)
    index.bounds <- calculate_index_extent(extent(clip.extent), 
                                                h5.ext)
    
    
    ndvi.stack <- create_stack(f, 
                               bands, 
                               epsg=32611,
                               subset=TRUE,
                               dims=index.bounds)
    
    # calculate NDVI
    ndvi <- (ndvi.stack[[2]]-ndvi.stack[[1]]) / (ndvi.stack[[2]]+ndvi.stack[[1]])
    names(ndvi) <- "Teak_hsiNDVI"
    
    # let's test this out
    plot(ndvi)

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day1_monday/subset-h5-file-R/import-tif-1.png)

    # let's create a mask
    ndvi[ndvi<.6] <- NA
    plot(ndvi)

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day1_monday/subset-h5-file-R/import-tif-2.png)




    ## FUNCTION - Extract Average Reflectance
    #'
    #' This function calculates an index based subset to slice out data from an H5 file
    #' using an input spatial extent. It returns a rasterStack object of bands. 
    #' @param aRaster REQUIRED. a raster within an H5 file that you wish to get an mean, max, min value from
    #' @param aMask REQUIRED. a raster of the same extent with NA values for areas that you don't 
    #' want to calculate the mean, min or max values from. 
    #' @param aFun REQUIRED. the function that you wish to use on the raster, mean, max, min etc
    #' @keywords hdf5, extent
    #' @export
    #' @examples
    #' extract_av_refl(aRaster, aMask, aFun=mean)
    #' 
    extract_av_refl <- function(aRaster, aMask=NULL, aFun=mean){
      # mask band
      if(!is.null(aMask)){
      aRaster <- mask(aRaster, aMask) }
      # geat mean
      a.band.mean <- cellStats(aRaster, 
                             aFun, 
                             na.rm=TRUE)
      return(a.band.mean)
    } 
    
    ## FUNCTION - Extract Average Reflectance
    #'
    #' This function calculates an index based subset to slice out data from an H5 file
    #' using an input spatial extent. It returns a rasterStack object of bands. 
    #' @param fileName REQUIRED. The path to the h5 file that you want to open.
    #' @param bandNum REQUIRED. The band number that you wish to open, default = 1 
    #' @param epsg the epsg code for the CRS that the data are in.
    #' @param subsetData, a boolean object. default is FALSE. If set to true, then
    #' ... subset a slice out from the h5 file. otherwise take the entire xy extent.
    #' @param dims, an optional object used if subsetData = TRUE that specifies the 
    #' index extent to slice from the h5 file
    #' @param mask a raster containg NA values for areas that should not be included in the 
    #' output summary statistic. 
    #' @param fun the summary statistic that you wish to run on the data  (e.g. mean, max, min)
    #' default = mean
    #' @keywords hdf5, extent
    #' @export
    #' @examples
    #' get_spectra(fileName, bandNum)
    
    get_spectra <- function(fileName, bandNum=1, 
                               epsg=32611, subset=TRUE,
                               dims=NULL, mask=NULL, fun=mean){
      # open a band
      a.raster <- open_band(fileName, bandNum, 
                               epsg, subset,
                               dims)
      # extract a particular spectral value (min, max, mean from the raster)
      refl <- extract_av_refl(a.raster, mask, aFun = fun)
      return(refl)
    }

## Plot Spectra


    # if you run get_spectra on it's own, it returns a min, max or mean value for a raster
    get_spectra(f, bandNum=1, epsg=32611, subset=TRUE,
                               dims=index.bounds, mask=ndvi, fun=mean)

    ## [1] 0.02485

    # provide a list of bands that you wish to extract summary values for
    bands <- (1:426)
    
    
    spectra_unmasked <- lapply(bands, FUN = get_spectra,
                  fileName=f, epsg=32611,
                  subset=TRUE,
                  dims=index.bounds, fun=mean)
    
    
    # reformat the output list
    spectra_unmasked <- unlist(spectra_unmasked)
    
    # plot spectra
    plot(spectra_unmasked,
         main="Spectra for all pixels",
         xlab="Band",
         ylab="Reflectance")

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day1_monday/subset-h5-file-R/plot-spectra-unmasked-1.png)

    # run get_spectra for each band to get an average spectral signature
    # because we've specified a mask, it will only return values for pixels that are not
    # in masked areas
    spectra <- lapply(bands, FUN = get_spectra,
                  fileName=f, epsg=32611,
                  subset=TRUE,
                  dims=index.bounds, 
                  mask=ndvi, fun=mean)
    
    # reformat the output list
    spectra <- unlist(spectra)
    
    # plot spectra
    plot(spectra,
         main="Spectra for just green pixels",
         xlab="Band",
         ylab="Reflectance")

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day1_monday/subset-h5-file-R/plot-spectra-unmasked-2.png)


