

# get dimensions of the dataset

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



# create an extent boundary

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


# create a function to plot RGB data
# inputs bands (list)
# 
create_stack <- function(bands, epsg){
  
  # use lapply to run the band function across all three of the bands
  rgb_rast <- lapply(bands, open_band,
                     fileName=f,
                     epsg=epsg, 
                     dims=dims)
  
  # create a raster stack from the output
  rgb_rast <- stack(rgb_rast)
  # reassign band names
  names(rgb_rast) <- bands
  return(rgb_rast)
  
} 
