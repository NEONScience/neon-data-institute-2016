## ----call-libraries, results="hide"--------------------------------------

#first call required libraries
library(rhdf5)
library(raster)
library(plyr)
library(rgeos)
library(rgdal)
library(ggplot2)

# be sure to set your working directory
setwd("~/Documents/data/1_data-institute-2016")


## ----import-h5-functions-------------------------------------------------

# your file will be in your working directory! This one happens to be in a diff dir
# than our data

# source("/Users/lwasser/Documents/GitHub/neon-data-institute-2016/_posts/institute-materials/day1_monday/import-HSIH5-functions.R")

source("/Users/lwasser/Documents/GitHub/neon-aop-package/neonAOP/R/aop-data.R")



## ----open-H5-file, results='hide'----------------------------------------

# Define the file name to be opened
f <- "Teakettle/may1_subset/spectrometer/Subset3NIS1_20130614_100459_atmcor.h5"

# Look at the HDF5 file structure 
h5ls(f, all=T) 

# define the CRS in EPGS format for the file
epsg <- 32611


## ----read-band-wavelengths-----------------------------------------------

#read in the wavelength information from the HDF5 file
wavelengths<- h5read(f,"wavelength")
# convert wavelength to nanometers (nm)
# NOTE: this is optional!
wavelengths <- wavelengths*1000


## ----subset-h5-file------------------------------------------------------

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


## ----import-tif----------------------------------------------------------
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

# let's create a mask
ndvi[ndvi<.6] <- NA
plot(ndvi)


## ----function-extract-spectra--------------------------------------------

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

## ----plot-spectra-unmasked-----------------------------------------------


# if you run get_spectra on it's own, it returns a min, max or mean value for a raster
get_spectra(f, bandNum=1, 
            epsg=32611, 
            subset=TRUE,
            dims=index.bounds, 
            mask=ndvi, fun=mean)

# provide a list of bands that you wish to extract summary values for
bands <- (1:426)

spectra_unmasked <- lapply(bands, FUN = get_spectra,
              fileName=f, epsg=32611,
              subset=TRUE,
              dims=index.bounds, 
              fun=mean)


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


# run get_spectra for each band to get an average spectral signature
# because we've specified a mask, it will only return values for pixels that are not
# in masked areas
spectra_masked <- lapply(bands, FUN = get_spectra,
              fileName=f, epsg=32611,
              subset=TRUE,
              dims=index.bounds, 
              mask=ndvi, fun=mean)

spectra_masked <- clean_spectra(spectra_masked, wavelengths)


# plot spectra
qplot(spectra_masked$wavelength,
      y=spectra_masked$reflectance,
      xlab="Wavelength (nm)",
      ylab="Reflectance",
      main="Spectra for just green pixels")


