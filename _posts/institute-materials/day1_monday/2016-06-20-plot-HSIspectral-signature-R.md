---
layout: post
title: "Plot a Spectral Signature from Hyperspectral Remote Sensing data in R -  HDF5"
date:   2016-06-18
authors: [Leah A. Wasser, Kyla Dahlin]
instructors: [Leah A. Wasser]
contributors: []
time: "1:30 pm"
dateCreated:  2016-05-01
lastModified: 2016-05-11
packagesLibraries: [rhdf5]
categories: [self-paced-tutorial]
mainTag: institute-day1
tags: [R, HDF5]
tutorialSeries: [institute-day1]
description: "Learn how to plot a spectral signature from a NEON HDF5 file in R."
code1: plot-HSIspectral-signature-R.R
image:
  feature: 
  credit: 
  creditlink:
permalink: /R/plot-spectral-signature/
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


In this tutorial, we will extract a single-pixel's worth of reflectance values to
plot a spectral profile for that pixel.


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
open and read from an H5 file. Rather than code out each step to open the H5 file,
let's open that file first using the `source` function which reads the functions into 
our working environment. We can then use the funtions to quickly and efficiently
open the H5 data. 


    # your file will be in your working directory! This one happens to be in a diff dir
    # than our data
    
    source("/Users/lwasser/Documents/GitHub/neon-data-institute-2016/_posts/institute-materials/day1_monday/import-HSIH5-functions.R")

First, we need to access the H5 file.


    # Define the file name to be opened
    f <- "Teakettle/may1_subset/spectrometer/Subset3NIS1_20130614_100459_atmcor.h5"
    
    # Look at the HDF5 file structure 
    h5ls(f,all=T) 

    ##    group                                 name         ltype corder_valid
    ## 0      /                     ATCOR_Input_File H5L_TYPE_HARD        FALSE
    ## 1      /                 ATCOR_Processing_Log H5L_TYPE_HARD        FALSE
    ## 2      /                Aerosol Optical Depth H5L_TYPE_HARD        FALSE
    ## 3      /                               Aspect H5L_TYPE_HARD        FALSE
    ## 4      /                          Cast Shadow H5L_TYPE_HARD        FALSE
    ## 5      / Dark Dense Vegetation Classification H5L_TYPE_HARD        FALSE
    ## 6      /                 Haze-Cloud-Water Map H5L_TYPE_HARD        FALSE
    ## 7      /                  Illumination Factor H5L_TYPE_HARD        FALSE
    ## 8      /                          Path Length H5L_TYPE_HARD        FALSE
    ## 9      /                   Processing Version H5L_TYPE_HARD        FALSE
    ## 10     /                          Reflectance H5L_TYPE_HARD        FALSE
    ## 11     /                Shadow_Processing_Log H5L_TYPE_HARD        FALSE
    ## 12     /                      Sky View Factor H5L_TYPE_HARD        FALSE
    ## 13     /               Skyview_Processing_Log H5L_TYPE_HARD        FALSE
    ## 14     /                                Slope H5L_TYPE_HARD        FALSE
    ## 15     /          Slope_Aspect_Processing_Log H5L_TYPE_HARD        FALSE
    ## 16     /                  Solar Azimuth Angle H5L_TYPE_HARD        FALSE
    ## 17     /                   Solar Zenith Angle H5L_TYPE_HARD        FALSE
    ## 18     /                    Surface Elevation H5L_TYPE_HARD        FALSE
    ## 19     /                 Visibility Index Map H5L_TYPE_HARD        FALSE
    ## 20     /                   Water Vapor Column H5L_TYPE_HARD        FALSE
    ## 21     /             coordinate system string H5L_TYPE_HARD        FALSE
    ## 22     /                       flightAltitude H5L_TYPE_HARD        FALSE
    ## 23     /                        flightHeading H5L_TYPE_HARD        FALSE
    ## 24     /                           flightTime H5L_TYPE_HARD        FALSE
    ## 25     /                                 fwhm H5L_TYPE_HARD        FALSE
    ## 26     /                             map info H5L_TYPE_HARD        FALSE
    ## 27     /              to-sensor azimuth angle H5L_TYPE_HARD        FALSE
    ## 28     /               to-sensor zenith angle H5L_TYPE_HARD        FALSE
    ## 29     /                           wavelength H5L_TYPE_HARD        FALSE
    ##    corder cset       otype num_attrs  dclass          dtype  stype rank
    ## 0       0    0 H5I_DATASET         1  STRING     HST_STRING SIMPLE    1
    ## 1       0    0 H5I_DATASET         1  STRING     HST_STRING SIMPLE    1
    ## 2       0    0 H5I_DATASET         5 INTEGER  H5T_STD_I16LE SIMPLE    3
    ## 3       0    0 H5I_DATASET         5   FLOAT H5T_IEEE_F32LE SIMPLE    3
    ## 4       0    0 H5I_DATASET         5 INTEGER   H5T_STD_I8LE SIMPLE    3
    ## 5       0    0 H5I_DATASET         6 INTEGER   H5T_STD_I8LE SIMPLE    3
    ## 6       0    0 H5I_DATASET         6 INTEGER   H5T_STD_I8LE SIMPLE    3
    ## 7       0    0 H5I_DATASET         5 INTEGER   H5T_STD_I8LE SIMPLE    3
    ## 8       0    0 H5I_DATASET         5   FLOAT H5T_IEEE_F32LE SIMPLE    3
    ## 9       0    0 H5I_DATASET         0  STRING     HST_STRING SIMPLE    1
    ## 10      0    0 H5I_DATASET         5 INTEGER  H5T_STD_I16LE SIMPLE    3
    ## 11      0    0 H5I_DATASET         1  STRING     HST_STRING SIMPLE    1
    ## 12      0    0 H5I_DATASET         5 INTEGER   H5T_STD_I8LE SIMPLE    3
    ## 13      0    0 H5I_DATASET         1  STRING     HST_STRING SIMPLE    1
    ## 14      0    0 H5I_DATASET         5   FLOAT H5T_IEEE_F32LE SIMPLE    3
    ## 15      0    0 H5I_DATASET         1  STRING     HST_STRING SIMPLE    1
    ## 16      0    0 H5I_DATASET         2   FLOAT H5T_IEEE_F32LE SIMPLE    2
    ## 17      0    0 H5I_DATASET         2   FLOAT H5T_IEEE_F32LE SIMPLE    2
    ## 18      0    0 H5I_DATASET         5   FLOAT H5T_IEEE_F32LE SIMPLE    3
    ## 19      0    0 H5I_DATASET         5 INTEGER   H5T_STD_I8LE SIMPLE    3
    ## 20      0    0 H5I_DATASET         5 INTEGER  H5T_STD_I16LE SIMPLE    3
    ## 21      0    0 H5I_DATASET         1  STRING     HST_STRING SIMPLE    1
    ## 22      0    0 H5I_DATASET         3   FLOAT H5T_IEEE_F32LE SIMPLE    1
    ## 23      0    0 H5I_DATASET         3   FLOAT H5T_IEEE_F32LE SIMPLE    1
    ## 24      0    0 H5I_DATASET         3   FLOAT H5T_IEEE_F32LE SIMPLE    1
    ## 25      0    0 H5I_DATASET         2   FLOAT H5T_IEEE_F32LE SIMPLE    2
    ## 26      0    0 H5I_DATASET         1  STRING     HST_STRING SIMPLE    1
    ## 27      0    0 H5I_DATASET         5   FLOAT H5T_IEEE_F32LE SIMPLE    3
    ## 28      0    0 H5I_DATASET         5   FLOAT H5T_IEEE_F32LE SIMPLE    3
    ## 29      0    0 H5I_DATASET         2   FLOAT H5T_IEEE_F32LE SIMPLE    2
    ##                dim          maxdim
    ## 0                1               1
    ## 1                1               1
    ## 2    544 x 578 x 1   544 x 578 x 1
    ## 3    544 x 578 x 1   544 x 578 x 1
    ## 4    544 x 578 x 1   544 x 578 x 1
    ## 5    544 x 578 x 1   544 x 578 x 1
    ## 6    544 x 578 x 1   544 x 578 x 1
    ## 7    544 x 578 x 1   544 x 578 x 1
    ## 8    544 x 578 x 1   544 x 578 x 1
    ## 9                1               1
    ## 10 544 x 578 x 426 544 x 578 x 426
    ## 11               1               1
    ## 12   544 x 578 x 1   544 x 578 x 1
    ## 13               1               1
    ## 14   544 x 578 x 1   544 x 578 x 1
    ## 15               1               1
    ## 16           1 x 1           1 x 1
    ## 17           1 x 1           1 x 1
    ## 18   544 x 578 x 1   544 x 578 x 1
    ## 19   544 x 578 x 1   544 x 578 x 1
    ## 20   544 x 578 x 1   544 x 578 x 1
    ## 21               1               1
    ## 22         5732053         5732053
    ## 23         5732053         5732053
    ## 24         5732053         5732053
    ## 25         426 x 1         426 x 1
    ## 26               1               1
    ## 27   544 x 578 x 1   544 x 578 x 1
    ## 28   544 x 578 x 1   544 x 578 x 1
    ## 29         426 x 1         426 x 1

## Open a Band

Next, we can use the `open_band` function to quickly open up a band. 
Let's open bands 56.


    epsg <- 32611
    
    band <- open_band(fileName=f, 
                      bandNum = 56, 
                      epsg=epsg,
                      subsetData=FALSE)
    
    plot(band,
         main="Band 56")

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day1_monday/plot-HSIspectral-signature-R/read-spatial-attributes-1.png)

## Read Wavelength Values

Next, let's read in the wavelength center associated with each band in the HDF5 
file. 



    #read in the wavelength information from the HDF5 file
    wavelengths<- h5read(f,"wavelength")
    # convert wavelength to nanometers (nm)
    # NOTE: this is optional!
    wavelengths <- wavelengths*1000

## Extract Z-dimension data slice

Next, we will extract all reflectance values for one pixel. This makes up the 
spectral signature or profile of the pixel. To do that, we'll use the `h5read` 
function.

We will use the `adply` function to convert the data in array format, into a 
dataframe for easy plotting.



    # extract Spectra from a single "pixel:
    # keep in mind that the first value is your columns and the second is rows
    # "null" tells the function to return ALL values in the matrix (n=426 bands)
    aPixel<- h5read(f,  # the file
                    "Reflectance",  # the dataset in the file
                    index=list(54, 36, NULL)) # the column, row and band(s)
    
    # reshape the data and turn into dataframe
    # c()
    aPixeldf <- adply(aPixel, 3) # split the data by the 3rd dimension
    
    # we only need the second row of the df, the first row is a duplicate
    aPixeldf <- aPixeldf[2]
    names(aPixeldf) <- c("reflectance")
    
    
    # add wavelength data to matrix
    aPixeldf$wavelength <- wavelengths
    
    head(aPixeldf)

    ##   reflectance wavelength
    ## 1         503     382.27
    ## 2         623     387.28
    ## 3         720     392.29
    ## 4         692     397.30
    ## 5         550     402.31
    ## 6         563     407.32

## Scale Factor

Then, we can pull the spatial attributes that we'll need to adjust the reflectance 
values. Often, large raster data contain floating point (values with decimals) information.
However, floating point data consume more space (yield a larger file size) compared
to integer values. Thus, to keep the file sizes smaller, the data will be scaled
by a factor of 10, 100, 10000, etc. This `scale factor` will be noted in the data attributes.


    # r get attributes for the Reflectance dataset
    reflInfo <- h5readAttributes(f,"Reflectance")
    
    # grab scale factor
    scale.factor <- reflInfo$`Scale Factor`
    
    # add scaled data column to DF
    aPixeldf$reflectance <- aPixeldf$reflectance/scale.factor
    
    head(aPixeldf)

    ##   reflectance wavelength
    ## 1      0.0503     382.27
    ## 2      0.0623     387.28
    ## 3      0.0720     392.29
    ## 4      0.0692     397.30
    ## 5      0.0550     402.31
    ## 6      0.0563     407.32

## Plot Spectral Profile

Now we're ready to plot our spectral profile!


    qplot(x=aPixeldf$wavelength, 
          y=aPixeldf$reflectance,
          xlab="Wavelength (nm)",
          ylab="Reflectance",
          main="Spectral Signature for A Pixel")

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day1_monday/plot-HSIspectral-signature-R/plot-spectra-1.png)



