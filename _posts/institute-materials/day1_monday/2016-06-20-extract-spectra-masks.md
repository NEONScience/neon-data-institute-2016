---
layout: redirected
sitemap: false
permalink: /R/extract-spectra-masks-R/
---


<div id="objectives">
<strong>R Skill Level:</strong> Intermediate

<h3>Goals / Objectives</h3>
After completing this activity, you will be able to:
<ol>
<li>Extract spectra from an HDF5 file using masks.</li>
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
    # setwd("~/Documents/data/NEONDI-2016") # Mac
    # setwd("~/data/NEONDI-2016")  # Windows

## Import H5 Functions

We have built a suite of **functions** that allow us to quickly open and read 
NEON hyperspectral imagery data from an `hdf5` file. 


    # install devtools (only if you have not previously intalled it)
    # install.packages("devtools")
    # call devtools library
    #library(devtools)
    
    ## install from github
    # install_github("lwasser/neon-aop-package/neonAOP")
    ## call library
    library(neonAOP)
    
    # your file will be in your working directory! This one happens to be in a diff dir
    # than our data
    # source("/Users/lwasser/Documents/GitHub/neon-aop-package/neonAOP/R/aop-data.R")
    # be sure to close any open connection
    H5close()

## Open H5 File

First, let's define the variables needed to access the H5 file.


    # Define the file name to be opened
    f <- "NEONdata/D17-California/TEAK/2013/spectrometer/reflectance/Subset3NIS1_20130614_100459_atmcor.h5"
    
    # Look at the HDF5 file structure
    h5ls(f, all=T)
    
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

## Create a boundary object

We can use the create_extent function to create a spatial extent object for the 
h5 file. Currently however, this extent does not consider the rotation that the 
file may have. 

This rotation will be considered in future iterations of the code!


    # open file clipping extent
    clip.extent <- readOGR("NEONdata/D17-California/TEAK/vector_data", 
                           "TEAK_plot")

    ## OGR data source with driver: ESRI Shapefile 
    ## Source: "NEONdata/D17-California/TEAK/vector_data", layer: "TEAK_plot"
    ## with 1 features
    ## It has 1 fields

    # create a spatial extent from the h5 file
    # NOTE: this currently doesn't work properly if the file is rotated
    h5.ext <- create_extent(f)
    
    # calculate the index subset dims to extract data from the H5 file
    subset.dims <- calculate_index_extent(clip.extent, 
                           h5.ext, 
                           xscale = 1, yscale = 1)
    
    # turn the H5 extent into a polygon to check overlap
    h5.ext.poly <- as(extent(h5.ext), "SpatialPolygons")
    
    # assign crs to new polygon
    crs(h5.ext.poly) <- CRS("+proj=utm +zone=11 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
    
    # ensure the two extents overlap
    gIntersects(h5.ext.poly, clip.extent)

    ## [1] TRUE

    # finally determine the subset to extract from the h5 file
    index.bounds <- calculate_index_extent(extent(clip.extent), h5.ext)


## View Spectra Within Clipped Raster


    # array containing the index dimensions to slice
    # H5close()
    subset.h5 <- h5read(f, "Reflectance",
                        index=list(index.bounds[1]:index.bounds[2],
                        					 index.bounds[3]:index.bounds[4], 1:426)) # the column, row
    
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

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day1_monday/extract-spectra-masks/subset-h5-file-1.png)


Now we've plotted a spectral signature. However, the values are averaged over 
all pixels in our AOI. We may just want to explore the spectral of particular, 
thresholded object.

To do this:

* We need to find the new tie point which will be a result of any averageing 
done above,
* then we can spatially located this and turn it into a raster.
* Then we can create a **mask** of just pixels with a particular raster value.

Let's give it a go!


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
    names(ndvi) <- "TEAK_hsiNDVI"
    
    # let's test this out
    plot(ndvi)

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day1_monday/extract-spectra-masks/import-tif-1.png)

    # let's create a mask
    ndvi[ndvi<.6] <- NA
    plot(ndvi)

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day1_monday/extract-spectra-masks/import-tif-2.png)




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
    
    ## FUNCTION - Extract Average Reflectance
    #'
    #' This function calculates an index based subset to slice out data from an H5 file
    #' using an input spatial extent. It returns a rasterStack object of bands.
    #' @param spectra REQUIRED. a LIST of spectra returned from Lapply.
    #' @param wavelengths REQUIRED. The vector of wavelength values of the same length as
    #' the spectra object
    #' @keywords hdf5, extent
    #' @export
    #' @examples
    #' clean_spectra(fileName, bandNum)
    
    clean_spectra <- function(spectra, wavelengths){
    # reformat the output list
      spectra<- data.frame(unlist(spectra))
      spectra$wavelength <- wavelengths
      names(spectra)[1] <- "reflectance"
      return(spectra)
    }

## Plot Spectra


    index.bounds <- calculate_index_extent(extent(clip.extent),
                                                h5.ext)
    
    # check to see if the mask and the clip extent are the same
    # if this returns false, the function won't work.
    extent(clip.extent)==extent(ndvi)

    ## [1] FALSE

    # crop mask to clip extent
    ndvi.clip <- crop(ndvi, clip.extent)
    
    # if you run get_spectra on it's own, it returns a min, max or mean value for a raster
    neonAOP::get_spectra(f, bandNum=1,
                epsg=32611,
                subset=TRUE,
                dims=index.bounds,
                mask=ndvi.clip, fun=mean)

    ## [1] 0.02524

    # provide a list of bands that you wish to extract summary values for
    bands <- (1:426)
    
    spectra_unmasked <- lapply(bands, FUN = neonAOP::get_spectra,
                  fileName=f, epsg=32611,
                  subset=TRUE,
                  dims=index.bounds,
                  fun=mean)
    
    head(spectra_unmasked)

    ## [[1]]
    ## [1] 0.04723
    ## 
    ## [[2]]
    ## [1] 0.05474
    ## 
    ## [[3]]
    ## [1] 0.06643
    ## 
    ## [[4]]
    ## [1] 0.06576
    ## 
    ## [[5]]
    ## [1] 0.05321
    ## 
    ## [[6]]
    ## [1] 0.0556

    # reformat the output list
    spectra_unmasked <- data.frame(unlist(spectra_unmasked))
    spectra_unmasked$wavelength <- wavelengths
    names(spectra_unmasked)[1] <- "reflectance"
    
    # plot spectra
    qplot(spectra_unmasked$wavelength,
          y=spectra_unmasked$reflectance,
          xlab="Wavelength (nm)",
          ylab="Reflectance",
          main="Spectra for all pixels")

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day1_monday/extract-spectra-masks/plot-spectra-unmasked-1.png)

    # run get_spectra for each band to get an average spectral signature
    # because we've specified a mask, it will only return values for pixels that are not
    # in masked areas
    spectra_masked <- lapply(bands, FUN = neonAOP::get_spectra,
                  fileName=f, epsg=32611,
                  subset=TRUE,
                  dims=index.bounds,
                  mask=ndvi.clip, fun=mean)
    
    spectra_masked <- clean_spectra(spectra_masked, wavelengths)
    
    
    # plot spectra
    qplot(spectra_masked$wavelength,
          y=spectra_masked$reflectance,
          xlab="Wavelength (nm)",
          ylab="Reflectance",
          main="Spectra for just green pixels")

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day1_monday/extract-spectra-masks/plot-spectra-unmasked-2.png)
