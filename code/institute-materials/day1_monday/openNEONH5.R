## ----load-libraries, warning=FALSE---------------------------------------
# load libraries
library(raster)
library(rhdf5)
library(rgdal)

# set wd
# setwd("~/Documents/data/1_data-institute-2016")

## ----read-file, results='hide'-------------------------------------------
# define the file name as an object
f <- "Teakettle/may1_subset/spectrometer/Subset3NIS1_20130614_100459_atmcor.h5"

# view the structure of the H5 file
h5ls(f, all = TRUE)


## ----view-attributes-----------------------------------------------------

# View map info attributes
# Map Info contains some key coordinate reference system information
# Including the UPPER LEFT corner coordinate in UTM (meters) of the Reflectance
# data.
mapInfo <- h5read(f,"map info", read.attributes = TRUE)
mapInfo

## ----view-attr-----------------------------------------------------------

# r  get attributes for the Reflectance dataset
reflInfo <- h5readAttributes(f,"Reflectance")

# view the scale factor for the data
reflInfo$`Scale Factor`

# view the data ignore value
reflInfo$`data ignore value`



## ----import-reflectance--------------------------------------------------

# open the file for viewing
fid <- H5Fopen(f)
# open the reflectance dataset
did <- H5Dopen(fid, "Reflectance")
did

# grab the dimensions of the object
sid <- H5Dget_space(did)
dims <- H5Sget_simple_extent_dims(sid)$size

# take note that the data seem to come in ROTATED. wavelength is the
# THIRD dimension rather than the first. Columns are the FIRST dimension, then rows.
# close everything
H5Sclose(sid)
H5Dclose(did)
H5Fclose(fid)


## ----import-wavelength---------------------------------------------------

# import the center wavelength in um of each "band"
wavelengths<- h5read(f,"wavelength")
str(wavelengths)


## ----read-refl-data------------------------------------------------------
# if you get an error with the file being "open" just use the generic h5 close below
# when we are done with our attributes you can skip all of this nonsense :)
H5close()
# Extract or "slice" data for band 34 from the HDF5 file
b56<- h5read(f,"Reflectance", index=list(1:dims[1],1:dims[2],56))

# note the data come in as an array
class(b56)


## ----view-data-----------------------------------------------------------
# Convert from array to matrix so we can plot and convert to a raster
b56 <- b56[,,1]

# plot the data
# what happens when we plot?
image(b56)

# looks like we need to force a stretch
image(log(b56),
      main="band 56 with log transformation")
# view distribution of reflectance data
# force non scientific notation
options("scipen"=100, "digits"=4)

hist(b56,
     col="springgreen",
     main="Distribution of Reflectance Values \nBand 56")


## ----no-data-scale-------------------------------------------------------

# extract no data value from the attributes
noDataVal <- as.integer(reflInfo$`data ignore value`)
# set all reflectance values = 15,000 to NA
b56[b56 == noDataVal] <- NA

# Extract the scale factor as an object
scaleFactor <- reflInfo$`Scale Factor`
# divide all values in our B56 object by the scale factor to get a range of
# reflectance values between 0-1 (the valid range)
b56 <- b56/scaleFactor

# view distribution of reflectance values
hist(b56,
     main="distribution with NoData Value considered\nData scaled")

## ----transpose-data------------------------------------------------------
# Because the data import column, row but we require row, column in R,
# We need to transpose x and y values in order for our final image to plot properly
b56<-t(b56)
image(log(b56), main="Transposed image")


## ------------------------------------------------------------------------
# so we can extract the lower left hand corner coordinates.
# the numbers as position 4 and 5 are the UPPER LEFT CORNER (x,y)
mapInfo<-unlist(strsplit(mapInfo, ","))

# grab the XY left corner coordinate
xMin <- as.numeric(mapInfo[4])
# ensure the format is numeric
yMax <- as.numeric(mapInfo[5])
# we can get the x and y resolution from this string too
res <- c(mapInfo[2],mapInfo[3])
res <- as.numeric(res)

#  finally calculate the xMAX value and the YMIN value
# we grabbed the dimensions above. the xmax is the left corner + number of columns* resolution
xMax <- xMin + (dims[1]*res[1])
yMin <- yMax - (dims[2]*res[2])

# also note that x and y res are the same (1 meter)
# Now, define the raster extent
# define the extent (left, right, top, bottom)
rasExt <- extent(xMin, xMax,yMin,yMax)

# now we can create a raster and assign it it's spatial extent
b56r <- raster(b56,
               crs=CRS("+init=epsg:32611"))
# assign CRS
extent(b56r) <- rasExt

# view raster object attributes
b56r
plot(b56r, main="Raster for Teakettle - B56")


## ----export-tif, eval=FALSE----------------------------------------------
## 
## writeRaster(b56r,
##             file="band56.tif",
##             format="GTiff",
##             naFlag=-9999)

