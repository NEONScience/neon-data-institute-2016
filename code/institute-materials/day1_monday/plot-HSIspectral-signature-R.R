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

source("/Users/lwasser/Documents/GitHub/neon-data-institute-2016/_posts/institute-materials/day1_monday/import-HSIH5-functions.R")


## ----open-H5-file--------------------------------------------------------

# Define the file name to be opened
f <- "Teakettle/may1_subset/spectrometer/Subset3NIS1_20130614_100459_atmcor.h5"

# Look at the HDF5 file structure 
h5ls(f,all=T) 


## ----read-spatial-attributes---------------------------------------------
epsg <- 32611

band <- open_band(fileName=f, 
                  bandNum = 56, 
                  epsg=epsg,
                  subsetData=FALSE)

plot(band,
     main="Band 56")


## ----read-band-wavelengths-----------------------------------------------

#read in the wavelength information from the HDF5 file
wavelengths<- h5read(f,"wavelength")
# convert wavelength to nanometers (nm)
# NOTE: this is optional!
wavelengths <- wavelengths*1000


## ----extract-spectra-----------------------------------------------------

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



## ----pull-scale-factor---------------------------------------------------

# r get attributes for the Reflectance dataset
reflInfo <- h5readAttributes(f,"Reflectance")

# grab scale factor
scale.factor <- reflInfo$`Scale Factor`

# add scaled data column to DF
aPixeldf$reflectance <- aPixeldf$reflectance/scale.factor

head(aPixeldf)


## ----plot-spectra--------------------------------------------------------

qplot(x=aPixeldf$wavelength, 
      y=aPixeldf$reflectance,
      xlab="Wavelength (nm)",
      ylab="Reflectance",
      main="Spectral Signature for A Pixel")


