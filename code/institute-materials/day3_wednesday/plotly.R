## ----import-plot-DSM, echo=FALSE, results='hide', message=FALSE----------

# load libraries
library(ggplot2)

options(stringsAsFactors = FALSE)

# set working directory
setwd("~/Documents/data/1_data-institute-2016")

## ----import-chm, echo=FALSE, results='hide', message=FALSE---------------

# import canopy height model (CHM).
SJER_chm <- raster("NEONdata/SJER/2013/lidar/SJER_lidarCHM.tif")
SJER_chm

# set values of 0 to NA as these are not trees
SJER_chm[SJER_chm==0] <- NA

# import plot centroids 
SJER_plots <- readOGR("NEONdata/SJER/vector_data",
                      "sjer_plot_centroids")

# Insitu sampling took place within 40m x 40m square plots so we use a 20m radius.	
# Note that below will return a dataframe containing the max height
# calculated from all pixels in the buffer for each plot
SJER_height <- extract(SJER_chm,
                    SJER_plots,
                    buffer = 20, 
                    fun=max, 
                    sp=TRUE,
                    stringsAsFactors=FALSE)


# import the centroid data and the vegetation structure data
SJER_insitu <- read.csv("NEONdata/SJER/2013/insitu/veg_structure/D17_2013_SJER_vegStr.csv",
                        stringsAsFactors = FALSE)


#find the max stem height for each plot
insitu_maxStemHeight <- SJER_insitu %>% 
  group_by(plotid) %>% 
  summarise(max = max(stemheight))


names(insitu_maxStemHeight) <- c("plotid","insituMaxHt")

# merge to create a new spatial df
SJER_height@data <- data.frame(SJER_height@data, 
                               insitu_maxStemHeight[match(SJER_height@data[,"Plot_ID"], insitu_maxStemHeight$plotid),])

#plot with regression fit
p <- ggplot(SJER_height@data, aes(x=SJER_lidarCHM, y = insituMaxHt)) + 
  geom_point() + 
  ylab("Maximum Measured Height") + 
  xlab("Maximum LiDAR Height")+
  ggtitle("LiDAR CHM Derived vs Measured Tree Height") +
  geom_abline(intercept = 0, slope=1)+
  geom_smooth(method=lm)


## ----create-local-plot---------------------------------------------------

# install.packages("plotly")
library(plotly)

# your ggplot - object
p

## ----plot-ly-local, eval=FALSE-------------------------------------------
## # plot your plot using plot_ly locally
## ggplotly(p)
## 

## ----create-plotly, eval=FALSE-------------------------------------------
## 
## 
## # setup your plot.ly credentials
## Sys.setenv("plotly_username"="NEONDataSkills")
## Sys.setenv("plotly_api_key"="kuu0m1xwne")
## 
## # generate the plot
## plotly_POST(p,
##             filename='NEON SJER CHM vs Insitu Tree Height') # let anyone in the world see the plot!
## 

