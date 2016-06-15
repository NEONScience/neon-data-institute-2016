## ----call-libraries, results="hide"--------------------------------------

# load packages
library(rhdf5)
library(raster)
library(plyr)
library(rgeos)
library(rgdal)
library(ggplot2)

# be sure to set your working directory
# setwd("~/Documents/data/NEONDI-2016") # Mac
# setwd("~/data/NEONDI-2016")  # Windows


## ----import-h5-functions-------------------------------------------------

# install devtools (only if you have not previously intalled it)
# install.packages("devtools")
# call devtools library
#library(devtools)

## install from github
install_github("lwasser/neon-aop-package/neonAOP")
## call library
library(neonAOP)



# your file will be in your working directory! This one happens to be in a diff dir
# than our data
# source("/Users/lwasser/Documents/GitHub/neon-aop-package/neonAOP/R/aop-data.R")



## ----open-H5-file, results='hide'----------------------------------------

# Define the file name to be opened
f <- "NEONdata/D17-California/TEAK/2013/spectrometer/reflectance/Subset3NIS1_20130614_100459_atmcor.h5"

# Look at the HDF5 file structure
h5ls(f, all=T)

# define the CRS in EPGS format for the file
epsg <- 32611


## ----read-band-wavelengths-----------------------------------------------

# read in the wavelength information from the HDF5 file
wavelengths<- h5read(f,"wavelength")
# convert wavelength to nanometers (nm)
# NOTE: this is optional!
wavelengths <- wavelengths*1000


## ----extract-subset------------------------------------------------------

# get of H5 file map tie point
h5.ext <- create_extent(f)

# turn the H5 extent into a polygon to check overlap
h5.ext.poly <- as(extent(h5.ext), "SpatialPolygons")

# open file clipping extent
clip.extent <- readOGR("NEONdata/D17-California/TEAK/vector_data", "TEAK_plot")

# assign crs to h5 extent
# paste0("+init=epsg:", epsg) -- it is better to use the proj string here

crs(h5.ext.poly) <- CRS("+proj=utm +zone=11 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")


# ensure the two extents overlap
gIntersects(h5.ext.poly, clip.extent)

# if they overlap, then calculate the extent
# this doesn't currently account for pixel size at all 
# and these values need to be ROUNDED

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
												 subsetData = TRUE
												 ,dims=index.bounds)

# plot clipped bands
plot(b58_clipped,
     main="Band 58 Clipped")


## ----open-many-bands-----------------------------------------------------

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


## ------------------------------------------------------------------------

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


## ----subset-h5-file------------------------------------------------------

# array containing the index dimensions to slice
H5close()

subset.h5 <- h5read(f, "Reflectance",
                    index=list(index.bounds[1]:index.bounds[2],
                    					 index.bounds[3]:index.bounds[4],
                    					 1:426)) # the column, row

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


