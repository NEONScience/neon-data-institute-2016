## ----load-libraries, warning=FALSE, results='hide', message=FALSE--------
# load libraries
library(raster)
library(rhdf5)
library(rgdal)

# setwd("C:/Users/kdahlin/Dropbox/NEON_WWDI_2016")
setwd("~/Documents/data/1_data-institute-2016")

## ----import-h5-functions-------------------------------------------------

# your file will be in your working directory!

# this is also an R package!
source("/Users/lwasser/Documents/GitHub/neon-aop-package/neonAOP/R/aop-data.R")

## ----import-lidar--------------------------------------------------------

# import digital surface model (dsm) (top of the surface - includes trees and buildings)
dsm <- raster("NEONdata/D17-California/TEAK/2013/lidar/Teak_lidarDSM.tif")
# import  digital terrain model (dtm), elevation
dtm <- raster("NEONdata/D17-California/TEAK/2013/lidar/Teak_lidarDTM.tif") 

# import canopy height model (height of vegetation) 
chm <- raster("NEONdata/D17-California/TEAK/2013/lidar/Teak_lidarCHM.tif")


## ------------------------------------------------------------------------

# do the numbers look reasonable? 60 m is tall for a tree, but
# this is Ponderosa pine territory (I think), so not out of the question.
plot(chm,
     main="Canopy Height - Teakettle \nCalifornia") 

hist(chm,
     main="Distribution of Canopy Height - Teakettle \nCalifornia",
     xlab="Tree Height (m)", 
     col="springgreen")


## ----remove-nonvalid-values----------------------------------------------
# assign chm values of 0 to NA
# chm[chm < 2] <- NA
hist(chm, 
     main="Distribution of Canopy Height - Teakettle \nCalifornia",
     xlab="Tree Height (m)", 
     col="springgreen")


## ----create-stack--------------------------------------------------------
# for simplicity later let's stack these rasters together
# do we need the dtm dsm??
lidar.brick <- brick(dsm, dtm, chm)


## ----read-hsi-data, eval=FALSE-------------------------------------------
## 
## # first identify the file of interest
## #f <- "NEONdata/D17-California/TEAK/2013/spectrometer/reflectance/Subset3NIS1_20130614_100459_atmcor.h5"
## # then id the projection code
## # define the CRS definition by EPSG code
## #epsg <- 32611
## 
## # create a list of bands
## #bands <- c(60,83)
## 
## # Let's read in a few spectral bands as a stack using a function
## #ndvi.stack <- create_stack(bands = bands,
## #             epsg=epsg)
## 
## # calculate ndvi
## #ndvi <- (ndvi.stack[[2]]-ndvi.stack[[1]]) / (ndvi.stack[[2]]+ndvi.stack[[1]])
## #names(ndvi) <- "Teak_hsiNDVI"
## # check the extents of the two layers -- if they are different
## # crop both datasets
## #if (extent(chm) == extent(ndvi)){
## #  } else {
## #  overlap <- intersect(extent(ndvi), extent(lidar.brick))
##   # now let's crop the lidar data to the HSI data
## #  lidar.brick <- crop(lidar.brick, overlap)
## #  ndvi <- crop(ndvi, overlap)
## #  print("Extents are different, cropping data")
## #  }
## 
## 

## ----import-NDVI---------------------------------------------------------

# import NDVI
ndvi <- raster("NEONdata/D17-California/TEAK/2013/spectrometer/veg_index/NEON.D17.TEAK.DP2.20130614_100459_NDVI.tif")

# plot NDVI
plot(ndvi,
     main="NDVI, TEAK Field Site")


## ----create-brick--------------------------------------------------------

# Create a brick from all of the data 
all.data <- brick(ndvi, lidar.brick)

# make names nice!
all.names <- c("NDVI", "DSM", "DTM", "CHM" )
names(all.data) <- all.names


## ----import-aspect-------------------------------------------------------

# 1. Import aspect data product (derived from the DTM)
aspect <- raster("NEONdata/D17-California/TEAK/2013/lidar/Teak_lidarAspect.tif")
# crop the data to the extent of the other rasters we are working with
aspect <- crop(aspect, extent(chm))


## ----create-aspect-mask--------------------------------------------------

# Create a classified aspect intermediate output 
# first create a matrix of values that represent the classification ranges
# North face = 1
# South face = 2
class.m <- c(0, 45, 1, 
             45, 135, NA, 
             135, 225, 2,  
             225 , 315, NA, 
             315, 360, 1)
# reshape into a matrix
rcl.m <- matrix(class.m, 
                ncol=3, 
                byrow=TRUE)
rcl.m
# classify the aspect product using the classification matrix
asp.ns <- reclassify(aspect, rcl.m)
# set 0 values to NA
asp.ns[asp.ns==0] <- NA


## ----plot-aspect-product-------------------------------------------------

# define the extetn of the map -
# this is used to place the legend on the plot.
ns.extent <- extent(asp.ns)

# plot data

plot(asp.ns, 
     col=c("blue","green"),
     axes=F,
     main="North and South Facing Slopes \nNEON Teakettle Field Site",
     bty="n",
     legend=F)

# allow legend to plot outside of bounds
par(xpd=TRUE)

legend((par()$usr[2] + 20), ns.extent@ymax-100, # set xy legend location
       legend = c("North", "South"),
       fill = c("blue", "green"), 
       bty="n") # turn off border


## ----ns-facing-----------------------------------------------------------

# create north facing mask object
north.facing <- asp.ns==1
north.facing[north.facing == 0] <- NA

# Create south facing mask object
south.facing <- asp.ns==2
south.facing[south.facing == 0] <- NA


## ----export-gtif-ns, eval=FALSE------------------------------------------
## 
## # export geotiff
## writeRaster(asp.ns,
##             filename="outputs/TEAK/Teak_nsAspect.tif",
##             format="GTiff",
##             options="COMPRESS=LZW",
##             overwrite = TRUE,
##             NAflag = -9999)
## 

## ----id-veg-metrics------------------------------------------------------

# histogram of tree ht
hist(all.data[[4]],
     main="Distribution of Canopy Height Model (CHM) values \nNEON Teakettle Field Site",
     col="springgreen")

# get mean, min max stats to use later
# chm.stats <- data.frame(t(summary(all.data[[4]], na.rm=F)))
# chm.stats$mean <- ht.mean <- cellStats(all.data[[4]], mean)
# chm.stats$sd <- ht.mean <- cellStats(all.data[[4]], sd)


# get mean, min max stats for all layers
all.data.stats <- data.frame(t(summary(all.data, na.rm=T)))
all.data.stats$mean <- ht.mean <- cellStats(all.data, mean, na.rm=T)
all.data.stats$sd <- ht.mean <- cellStats(all.data, sd, na.rm=T)

row.names(all.data.stats) <- all.names

# view data.frame
all.data.stats

# let's be semi-robust and call 'tall' trees those with mean + 1 sd
ht.threshold <- all.data.stats["CHM","mean"] + all.data.stats["CHM","sd"]
ht.threshold


## ----explore-ndvi--------------------------------------------------------
# now let's look at ndvi
hist(all.data[[1]],
     main="Distribution of NDVI values\n Teakettle",
     col="springgreen")

# this is a nice bimodal data set, so let's just take the top 1/3 of the data
# could take the 3rd quartile
# do this using summary stats
# stats <- summary(all.data[[1]])
# stats[["3rd Qu.", 1]]

# or manually calculate the top third
green.range <- all.data.stats["NDVI","Max."] - all.data.stats["NDVI","Min."]
green.threshold <- all.data.stats["NDVI","Max."] - (green.range/3)


## ----calculate-percent---------------------------------------------------

# North = 1 and South facing = 2, calculate total pixels
north.count <- freq(asp.ns, value =1)
south.count <- freq(asp.ns, value =2)

# note there's  more south facing area in this image than north facing

# create a new layer with pixels that are north facing, above the green threshold and
# above the CHM height threshold
north.tall.green <- asp.ns == 1  & 
                    all.data[[1]] >= green.threshold & 
                    all.data[[4]] >= ht.threshold

# assign values of 0 to NA so this becomes a mask
north.tall.green[north.tall.green == 0] <- NA

# how many pixels fit the "north, tall green" criteria?
north.tall.green.count <- freq(north.tall.green, value =1)


# repeat the same steps for south facing slopes. Note
# we are repeating code - this could become a nice function!
south.tall.green <- asp.ns == 2 & 
                    all.data[[1]] >= green.threshold & 
                    all.data[[4]] >= ht.threshold

south.tall.green.count <- freq(south.tall.green, value=1)
south.tall.green[south.tall.green == 0] <- NA

# divide the number of pixels that are green by the total north facing pixels
north.tall.green.frac <- north.tall.green.count/freq(asp.ns, value=1)
south.tall.green.frac <- south.tall.green.count/freq(asp.ns, value=2)

# if we look at these fracs, >11% of the pixels on north facing slopes should
# meet our tall and green criteria, while <6% of the pixels on south facing
# slopes do. So that's reassuring. (using original data set)


## ----view-cir------------------------------------------------------------

f <- "NEONdata/D17-California/TEAK/2013/spectrometer/reflectance/Subset3NIS1_20130614_100459_atmcor.h5"

# define the CRS definition by EPSG code
epsg <- 32611

# create a list of bands
bands <- c(83, 60, 35)

# Let's read in a few spectral bands as a stack using a function
cir.stack <- create_stack(file=f,
                          bands = bands,
                          epsg=epsg)

# ignore reflectance values > 1
cir.stack[cir.stack > 1] <- NA

# plot cir image
plotRGB(cir.stack, 
        scale = 1, 
        stretch = "lin")

plot(north.tall.green, 
     col = "cyan", 
     add = T, 
     legend = F)
plot(south.tall.green, 
     col = "blue", 
     add = T, 
     legend = F)






## ----run-stats-----------------------------------------------------------
# (5) let's do some stats! t-test and boxplots of veg height and greenness 
# distributions in north versus south facing parts of scene.

# let's start with NDVI - isolate NDVI on north and south facing slopes
north.NDVI <- mask(all.data[[1]], north.facing)
south.NDVI <- mask(all.data[[1]], south.facing)


## ----compare-aspect-NDVI-------------------------------------------------

## get values and coerce to north values to dataframe
north.ndvi.df <- na.omit(as.data.frame(getValues(north.NDVI)))
north.ndvi.df$aspect <- rep("north", length(north.ndvi.df[,1]))
names(north.ndvi.df) <- c("NDVI","aspect")

south.ndvi.df <- na.omit(as.data.frame(getValues(south.NDVI)))
south.ndvi.df$aspect <- rep("south", length(south.ndvi.df[,1]))
names(south.ndvi.df) <- c("NDVI","aspect")

ndvi.df <- rbind(north.ndvi.df, south.ndvi.df)
# convert aspect to factor - NOTE you don't have to do this
ndvi.df$aspect <- as.factor(ndvi.df$aspect)

boxplot(NDVI ~ aspect, 
        data = ndvi.df, 
        col = "cornflowerblue", 
        main = "NDVI on North versus South facing slopes")


# and now a t-test - note that since these aren't normally distributed, this
# might not be the best approach, but ok for a quick assessment.
NDVI.ttest <- t.test(north.ndvi.df$NDVI, 
                     south.ndvi.df$NDVI, 
                     alternative = "greater")


## ----another-solution----------------------------------------------------

# now to do more complicated non-spatial stats in R we need to convert our
# raster data to vectors - for this example the spatial distribution of the
# data doesn't matter.

#north.NDVI.vec <- getValues(north.NDVI)
#south.NDVI.vec <- getValues(south.NDVI)


# and get rid of NAs for simplicity (the above vectors are all the same length
# and include all the cells in the original dataset)

#north.NDVI.vec <- north.NDVI.vec[!is.na(north.NDVI.vec)]
#south.NDVI.vec <- south.NDVI.vec[!is.na(south.NDVI.vec)]

# now let's make a data frame with a north versus south column
#aspect.NDVI <- c(rep("north", length(north.NDVI.vec)), 
#                 rep("south", length(south.NDVI.vec)))
#aspect.NDVI <- as.factor(aspect.NDVI)

#NDVI.vec <- c(north.NDVI.vec, south.NDVI.vec)

# this (below) is clunky - I thought I could use cbind but 'factors' are getting the 
# best of me
#NDVI.dat <- as.data.frame(matrix(NA, nrow = length(NDVI.vec), ncol = 2))
#names(NDVI.dat) <- c("aspect", "NDVI")
#NDVI.dat[,1] <- aspect.NDVI
#NDVI.dat[,2] <- NDVI.vec
#boxplot(NDVI ~ aspect, data = NDVI.dat, col = "cornflowerblue", main = "NDVI 
#        on North versus South facing slopes")

# and now a t-test - note that since these aren't normally distributed, this
# might not be the best approach, but ok for a quick assessment.
# NDVI.ttest <- t.test(north.NDVI.vec, south.NDVI.vec, alternative = "greater")


## ----veght-aspect-compare------------------------------------------------
# mask tall pixels on north and south facing slopes 
north.veght <- mask(all.data[[4]], north.facing)
south.veght <- mask(all.data[[4]], south.facing)

## get values and coerce to north values to dataframe
north.veght.df <- na.omit(as.data.frame(getValues(north.veght)))
north.veght.df$aspect <- rep("north", length(north.veght.df[,1]))
names(north.veght.df) <- c("veght","aspect")

south.veght.df <- na.omit(as.data.frame(getValues(south.veght)))
south.veght.df$aspect <- rep("south", length(south.veght.df[,1]))
names(south.veght.df) <- c("veght","aspect")

veght.df <- rbind(north.veght.df, south.veght.df)
# convert aspect to factor - NOTE you don't have to do this
veght.df$aspect <- as.factor(veght.df$aspect)

boxplot(veght ~ aspect, 
        data = veght.df, 
        col = "cornflowerblue", 
        main = "veght on North versus South facing slopes")


# and now a t-test - note that since these aren't normally distributed, this
# might not be the best approach, but ok for a quick assessment.
veght.ttest <- t.test(north.veght.df$veght, south.veght.df$veght, alternative = "greater")


## ----veg-ht--------------------------------------------------------------

# # isolate veg height pixels on north and south facing slopes
# north.veght <- all.data[[4]] * north.facing
# south.veght <- all.data[[4]] * south.facing
# 
# # and now for veg height
# north.veght.vec <- getValues(north.veght)
# south.veght.vec <- getValues(south.veght)
# 
# north.veght.vec <- north.veght.vec[!is.na(north.veght.vec)]
# south.veght.vec <- south.veght.vec[!is.na(south.veght.vec)]
# 
# # now let's make a data frame with a north versus south column
# aspect.veght <- c(rep("north", length(north.veght.vec)), 
#                  rep("south", length(south.veght.vec)))
# aspect.veght <- as.factor(aspect.veght)
# 
# veght.vec <- c(north.veght.vec, south.veght.vec)
# 
# veght.dat <- as.data.frame(matrix(NA, nrow = length(veght.vec), ncol = 2))
# names(veght.dat) <- c("aspect", "veght")
# veght.dat[,1] <- aspect.veght
# veght.dat[,2] <- veght.vec
# boxplot(veght ~ aspect, data = veght.dat, col = "aquamarine4", main = "Veg Ht 
#         on North versus South facing slopes")
# 
# # same caution as above!
# veght.ttest <- t.test(north.veght.vec, south.veght.vec, alternative = "greater")



