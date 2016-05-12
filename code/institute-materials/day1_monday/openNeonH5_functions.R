## ----load-libraries, warning=FALSE, results='hide', message=FALSE--------
# load libraries
library(raster)
library(rhdf5)
library(rgdal)

## ----define-data-wd------------------------------------------------------
# set wd
# setwd("~/Documents/data/1_data-institute-2016/Teakettle/may1_subset/")
# define the CRS definition by EPSG code
epsg <- 32611

# define the file you want to work with
#f <- "Subset1NIS1_20130614_095740_atmcor.h5"
f <- "Teakettle/may1_subset/spectrometer/Subset3NIS1_20130614_100459_atmcor.h5"


## ----get-data-dims-------------------------------------------------------

get_data_dims <- function(fileName){
  # make sure everything is closed
  H5close()
  # open the file for viewing
  fid <- H5Fopen(fileName)
  # open the reflectance dataset
  did <- H5Dopen(fid, "Reflectance")
  # grab the dimensions of the object
  sid <- H5Dget_space(did)
  dims <- H5Sget_simple_extent_dims(sid)$size
  
  # close everything
  H5Sclose(sid)
  H5Dclose(did)
  H5Fclose(fid)
  return(dims)
}



## ----create-function-attrs-----------------------------------------------

# Create a function that grabs corner coordinates and data res
# and returns an extent object.

create_extent <- function(fileName){
  # Grab upper LEFT corner coordinate from map info dataset 
  mapInfo <- h5read(fileName, "map info")
  # create object with each value in the map info dataset
  mapInfo<-unlist(strsplit(mapInfo, ","))
  # grab the XY left corner coordinate (xmin,ymax)
  xMin <- as.numeric(mapInfo[4])
  yMax <- as.numeric(mapInfo[5])
  # get the x and y resolution
  res <- as.numeric(c(mapInfo[2], mapInfo[3]))
  # get dims to use to cal xMax, YMin
  dims <- get_data_dims(f)
  # calculate the xMAX value and the YMIN value
  xMax <- xMin + (dims[1]*res[1])
  yMin <- yMax - (dims[2]*res[2])
  
  # create extent object (left, right, top, bottom)
  rasExt <- extent(xMin, xMax, yMin, yMax)
  # return object of class extent
  return(rasExt)
}



## ----import-wavelength---------------------------------------------------
# import the center wavelength in um of each "band"
wavelengths<- h5read(f,"wavelength")


## ----clean-refl-data-fun-------------------------------------------------
# this function returns a RASTER with no data values
# assigned to NA as required by R and a scale factor applied
# and a shiny new and correct extent / CRS!

clean_refl_data <- function(fileName, reflMatrix, epsg){
  # r  get attributes for the Reflectance dataset
  reflInfo <- h5readAttributes(fileName, "Reflectance")
  # grab noData value
  noData <- as.numeric(reflInfo$`data ignore value`)
  # set all values = 15,000 to NA
  reflMatrix[reflMatrix == noData] <- NA
  
  # apply the scale factor
  reflMatrix <- reflMatrix/(as.numeric(reflInfo$`Scale Factor`))
  
  # now we can create a raster and assign its spatial extent
  reflRast <- raster(reflMatrix,
               crs=CRS(paste0("+init=epsg:", epsg)))
  # finally apply extent to raster, using extent function 
  extent(reflRast) <- create_extent(fileName)
  # return a scaled and "cleaned" raster object
  return(reflRast)
}



## ----read-refl-data------------------------------------------------------

open_band <- function(fileName, bandNum, epsg, dims){
  # make sure any open connections are closed
  H5close()
  # you don't necessarily need to get the dims but it's useful
  dims <- get_data_dims(fileName)
  # Extract or "slice" data for band 34 from the HDF5 file
  aBand<- h5read(f, "Reflectance", index=list(1:dims[1],1:dims[2], bandNum))
  # Convert from array to matrix so we can plot and convert to a raster
  aBand <- aBand[,,1]
  # transpose the data to account for columns being read in first
  # but R wants rows first.
  aBand<-t(aBand)
  # clean data
  aBand <- clean_refl_data(fileName, aBand, epsg)
  # return matrix object
  return(aBand)
}
  


## ----open-plot-band------------------------------------------------------

### final Code ####
H5close()
# find the dimensions of the data to help determine the slice range
# returns cols, rows, wavelengths
dims <- get_data_dims(fileName = f)

# note this won't slicer properly yet as you'd need to create a new tie point if
# you adjust the dims.
# open band, return cleaned and scaled raster
band <- open_band(fileName=f, bandNum = 56, epsg=epsg, dims=dims)
# NOTE: might consider grabbing the dimensions of the data first and then
# creating a slice object if you want to grab less than the full extent of the data.

# plot data
plot(band, 
     main="Raster for Teakettle - B56")


## ----extract-many-bands--------------------------------------------------

# extract 3 bands
# create  alist of the bands
bands <- list(58,34,19)

# use lapply to run the band function across all three of the bands
rgb_rast <- lapply(bands, open_band,
                   fileName=f,
                   epsg=epsg, 
                   dims=dims)

# create a raster stack from the output
rgb_rast <- stack(rgb_rast)

# plot the output, use a linear stretch to make it look nice
plotRGB(rgb_rast,
        stretch='lin')


## ----create-CIR-stack----------------------------------------------------

# create a function to plot RGB data
# inputs bands (list)
# 
create_stack <- function(bands){
  
  # use lapply to run the band function across all three of the bands
  rgb_rast <- lapply(bands, open_band,
                     fileName=f,
                     epsg=epsg, 
                     dims=dims)
  
  # create a raster stack from the output
  rgb_rast <- stack(rgb_rast)
  return(rgb_rast)
  
} 


plot_stack <- function(aStack, title="3 band RGB Composite", theStretch='lin'){
  # takes a stack and plots it with a title
  # tricker to force the plot title to appear nicely
  # original_par <-par() #original par
  par(col.axis="white", col.lab="white", tck=0)
  # plot the output, use a linear stretch to make it look nice
  plotRGB(aStack,
          stretch=theStretch,
          axes=TRUE, 
          main=title)
  box(col="white")
  # par(original_par) # go back to original par
}


## ----plot-band-combos----------------------------------------------------

# CIR create  alist of the bands
bands <- list(90,34,19)
CIRStack <- create_stack(bands)
plot_stack(CIRStack,
           title="Color Infrared (CIR) Image")

# create  alist of the bands
bands <- list(152,90,58)
aStack <- create_stack(bands)
plot_stack(aStack,
           title="another combo")

# FALSE COLOR create  alist of the bands
bands <- list(363, 246, 58)
falseStack <- create_stack(bands)
plot_stack(falseStack,
              title="False Color Image")


aStack



## ----write-raster, eval=FALSE--------------------------------------------
## 
## # export as a gtif
## writeRaster(aStackStack,
##             file="rgbImage.tif",
##             format="GTiff",
##             overwrite=TRUE)

## ----create-NDVI---------------------------------------------------------

#Calculate NDVI
#select bands to use in calculation (red, NIR)
ndvi_bands <- c(58,90)

#create raster list and then a stack using those two bands
ndvi_stack <-  create_stack(ndvi_bands)

# calculate NDVI
NDVI <- function(x) {
	  (x[,2]-x[,1])/(x[,2]+x[,1])
}

ndvi_rast <- calc(ndvi_stack, NDVI)

# clear out plots
# dev.off(dev.list()["RStudioGD"])

plot(ndvi_rast, 
     main="NDVI for the NEON TEAK Field Site")



## ----export-ndvi, eval=FALSE---------------------------------------------
## 
## # export as a gtif
## writeRaster(ndvi_rast,
##             file="ndvi_TEAK.tif",
##             format="GTiff",
##             overwrite=TRUE)
## 

## ----import-lidar--------------------------------------------------------

DSM <- raster("lidar/Teak_lidarDSM.tif")

plot(DSM,
     col=grey(1:100/100),
     main="DSM")
plot(ndvi_rast, 
     add=TRUE,
     alpha=.3
     )

