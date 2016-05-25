---
layout: post
title: "R: Create a Canopy Height Model from LiDAR derived Rasters (grids) in R"
date:   2016-05-17
createdDate:   2016-05-17
lastModified:   2016-05-25
time: "9:00"
packagesLibraries: [raster, sp, dplyr, maptools, rgeos]
authors: [Leah A. Wasser, Kyla Dahlin]
instructors: [Leah, Naupaka, Kyla]
category: remote-sensing
categories: [Remote Sensing]
tags : [lidar, R]
mainTag: institute-day3
tutorialSeries: institute-day3
description: "Bring LiDAR-derived raster data (DSM and DTM) into R to create a final canopy height model representing the actual vegetation height with the influence of elevation removed. Then compare lidar derived height (CHM) to field measured tree height to estimate uncertainty in lidar estimates."
permalink: /compare-lidar-to-field-data-R/
comments: true
code1: /institute-day3/lidar-chm-to-insitu.R
image:
  feature: 
  credit: 
  creditlink:
---



## Background ##
NEON (National Ecological Observatory Network) will provide derived LiDAR products as one 
of its many free ecological data products. These products will come in a
 [geotiff](http://trac.osgeo.org/geotiff/ "geotiff (read more)") format, which 
is a `tif` raster format that is spatially located on the earth. Geotiffs 
can be accessed using the `raster` package in R.

A common first analysis using LiDAR data is to derive top of the canopy height values from 
the LiDAR data. These values are often used to track changes in forest structure over time, 
to calculate biomass, and even LAI. Let's dive into the basics of working with raster 
formatted lidar data in R! Before we begin, make sure you've downloaded the data required 
to run the code below.

<div id="objectives" markdown="1">
<h3>What you'll need</h3>

You will need the most current version of R or R studio loaded on your computer 
to complete this lesson.

### R Libraries to Install:

* **raster:** `install.packages("raster")`
* **sp:** `install.packages("sp")`
* **rgdal:** `install.packages("rgdal")`
* **dplyr:** `install.packages("dplyr")`
* **ggplot2:** `install.packages("ggplot2")`


## Data to Download

Download the raster and <i>insitu</i> collected vegetation structure data:

<a href="#" class="btn btn-success"> 
DOWNLOAD NEON  Sample NEON LiDAR Data</a>

<h3>Recommended Reading</h3>
<a href="http://neondataskills.org/remote-sensing/2_LiDAR-Data-Concepts_Activity2/">
What is a CHM, DSM and DTM? About Gridded, Raster LiDAR Data</a>
</div>

> NOTE: The data used in this tutorial were collected by the National Ecological 
> Observatory Network in their <a href="http://www.neoninc.org/science-design/field-sites/san-joaquin" target="_blank">
> Domain 17 California field site</a>. The data are available in full, for 
> no charge, but by request, [from the NEON data portal](http://data.neoninc.org/airborne-data-request "AOP data").





    # Import DSM into R 
    library(raster)
    library(rgdal)
    library(ggplot2)
    library(dplyr)
    
    options(stringsAsFactors = FALSE)
    
    # set working directory
    setwd("~/Documents/data/1_data-institute-2016")

## Import NEON CHM

First, we will import the NEON canopy height model. 


    # import canopy height model (CHM).
    SJER_chm <- raster("NEONdata/SJER/2013/lidar/SJER_lidarCHM.tif")
    SJER_chm

    ## class       : RasterLayer 
    ## dimensions  : 5059, 4296, 21733464  (nrow, ncol, ncell)
    ## resolution  : 1, 1  (x, y)
    ## extent      : 254571, 258867, 4107303, 4112362  (xmin, xmax, ymin, ymax)
    ## coord. ref. : +proj=utm +zone=11 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0 
    ## data source : /Users/lwasser/Documents/data/1_data-institute-2016/NEONdata/SJER/2013/lidar/SJER_lidarCHM.tif 
    ## names       : SJER_lidarCHM 
    ## values      : 0, 45.88  (min, max)

    # set values of 0 to NA as these are not trees
    SJER_chm[SJER_chm==0] <- NA
    
    # plot the data
    hist(SJER_chm,
         main="histogram of canopy heights\n NEON SJER Field Site",
         col="springgreen")

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day3_wednesday/lidar-chm-to-insitu/import-chm-1.png)


## Part 2. How does our CHM data compare to field measured tree heights?

We now have a canopy height model for our study area in California. However, how 
do the height values extracted from the CHM compare to our laboriously collected, 
field measured canopy height data? To figure this out, we will use *in situ* collected
tree height data, measured within circular plots across our study area. We will compare
the maximum measured tree height value to the maximum lidar derived height value 
for each circular plot using regression.

For this activity, we will use the a `csv` (comma separate value) file, 
located in `SJER/2013/insitu/veg_structure/D17_2013_SJER_vegStr.csv`.


    # import plot centroids 
    SJER_plots <- readOGR("NEONdata/SJER/vector_data",
                          "sjer_plot_centroids")

    ## OGR data source with driver: ESRI Shapefile 
    ## Source: "NEONdata/SJER/vector_data", layer: "sjer_plot_centroids"
    ## with 18 features
    ## It has 5 fields

    # Overlay the centroid points and the stem locations on the CHM plot
    plot(SJER_chm,
         main="Plot Locations",
         col=gray.colors(100, start=.3, end=.9))
    
    # pch 0 = square
    plot(SJER_plots,
         pch = 0,
         cex = 2,
         col = 2,
         add=TRUE)

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day3_wednesday/lidar-chm-to-insitu/read-plot-data-1.png)

### Extract CMH data within 20 m radius of each plot centroid.

Next, we will create a boundary region (called a buffer) representing the spatial
extent of each plot (where trees were measured). We will then extract all CHM pixels
that fall within the plot boundary to use to estimate tree height for that plot.

There are a few ways to go about this task. If your plots are circular, then the 
extract tool will do the job!


<figure>
    <img src="{{ site.baseurl }}/images/spatialData/BufferCircular.png">
    <figcaption>The extract function in R allows you to specify a circular buffer 
    radius around an x,y point location. Values for all pixels in the specified 
    raster that fall within the circular buffer are extracted. In this case, we
    will tell R to extract the maximum value of all pixels using the fun=max
    command.
    </figcaption>
</figure>

### Extract Plot Data Using Circle: 20m Radius Plots


    # Insitu sampling took place within 40m x 40m square plots so we use a 20m radius.	
    # Note that below will return a dataframe containing the max height
    # calculated from all pixels in the buffer for each plot
    SJER_height <- extract(SJER_chm,
                        SJER_plots,
                        buffer = 20, 
                        fun=max, 
                        sp=TRUE,
                        stringsAsFactors=FALSE)

#### If you want to explore The Data Distribution

If you want to explore the data distribution of pixel height values in each plot, 
you could remove the `fun` call to max and generate a list. 
`cent_ovrList <- extract(chm,centroid_sp,buffer = 20)`. It's good to look at the 
distribution of values we've extracted for each plot. Then you could generate a 
histogram for each plot `hist(cent_ovrList[[2]])`. If we wanted, we could loop 
through several plots and create histograms using a `for loop`.


    #cent_ovrList <- extract(chm,centroid_sp,buffer = 20)
    # create histograms for the first 5 plots of data
    #for (i in 1:5) {
    #  hist(cent_ovrList[[i]], main=(paste("plot",i)))
    #  }



### Variation 3: Derive Square Plot boundaries, then CHM values around a point
For see how to extract square plots using a plot centroid value, check out the
 [extracting square shapes activity.]({{ site.baseurl }}/working-with-field-data/Field-Data-Polygons-From-Centroids/ "Polygons")
 
 <figure>
    <img src="{{ site.baseurl }}/images/spatialData/BufferSquare.png">
    <figcaption>If you had square shaped plots, the code in the link above would
    extract pixel values within a square shaped buffer.
    </figcaption>
</figure>



## Extract descriptive stats from Insitu Data 
In our final step, we will extract summary height values from our field data. 
We will use the `dplyr` library to do this efficiently. We'll demonstrate both below

### Extract stats from our data.frame using DPLYR

First let's see how many plots are in the centroid folder.

    # import the centroid data and the vegetation structure data
    SJER_insitu <- read.csv("NEONdata/SJER/2013/insitu/veg_structure/D17_2013_SJER_vegStr.csv",
                            stringsAsFactors = FALSE)
    
    # How many plots are there?
    unique(SJER_plots$Plot_ID) 

    ##  [1] "SJER1068" "SJER112"  "SJER116"  "SJER117"  "SJER120"  "SJER128" 
    ##  [7] "SJER192"  "SJER272"  "SJER2796" "SJER3239" "SJER36"   "SJER361" 
    ## [13] "SJER37"   "SJER4"    "SJER8"    "SJER824"  "SJER916"  "SJER952"


Next, find the maximum MEASURED stem height value for each plot. We will compare 
this value to the max CHM value.


    #get list of unique plot id's 
    unique(SJER_insitu$plotid) 

    ##  [1] "SJER128"  "SJER2796" "SJER272"  "SJER112"  "SJER1068" "SJER916" 
    ##  [7] "SJER361"  "SJER3239" "SJER824"  "SJER8"    "SJER952"  "SJER116" 
    ## [13] "SJER117"  "SJER37"   "SJER4"    "SJER192"  "SJER36"   "SJER120"

    #find the max stem height for each plot
    insitu_maxStemHeight <- SJER_insitu %>% 
      group_by(plotid) %>% 
      summarise(max = max(stemheight))
    
    head(insitu_maxStemHeight)

    ## Source: local data frame [6 x 2]
    ## 
    ##     plotid   max
    ##      (chr) (dbl)
    ## 1 SJER1068  19.3
    ## 2  SJER112  23.9
    ## 3  SJER116  16.0
    ## 4  SJER117  11.0
    ## 5  SJER120   8.8
    ## 6  SJER128  18.2

    names(insitu_maxStemHeight) <- c("plotid","insituMaxHt")
    head(insitu_maxStemHeight)

    ## Source: local data frame [6 x 2]
    ## 
    ##     plotid insituMaxHt
    ##      (chr)       (dbl)
    ## 1 SJER1068        19.3
    ## 2  SJER112        23.9
    ## 3  SJER116        16.0
    ## 4  SJER117        11.0
    ## 5  SJER120         8.8
    ## 6  SJER128        18.2


### Merge the data into the SJER_height SP data.frame

Once we have our summarized insitu data, we can `merge` it into the centroids 
`data.frame`. Merge requires two data.frames and the names of the columns 
containing the unique ID that we will merge the data on. In this case, we will
merge the data on the plot_id column. Notice that it's spelled slightly differently 
in both data.frames so we'll need to tell R what it's called in each data.frame.


    require(sp)
    
    # merge to create a new spatial df
    SJER_height@data <- data.frame(SJER_height@data, 
                                   insitu_maxStemHeight[match(SJER_height@data[,"Plot_ID"], insitu_maxStemHeight$plotid),])
    
    # merge the insitu data into the centroids data.frame
    #SJER_height <- merge(SJER_height, 
    #                     insitu_maxStemHeight, 
    #                   by.x = 'Plot_ID', 
    #                   by.y = 'plotid')

### Plot Data (CHM vs Measured)
Let's create a plot that illustrates the relationship between in situ measured 
max canopy height values and lidar derived max canopy height values.



    # create plot
    ggplot(SJER_height@data, aes(x=SJER_lidarCHM, y = insituMaxHt)) + 
      geom_point() + 
      theme_bw() + 
      ylab("Maximum measured height") + 
      xlab("Maximum LiDAR pixel")+
      geom_abline(intercept = 0, slope=1) 

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day3_wednesday/lidar-chm-to-insitu/plot-w-ggplot-1.png)


We can also add a regression fit to our plot. Explore the GGPLOT options and 
customize your plot.


    #plot with regression fit
    p <- ggplot(SJER_height@data, aes(x=SJER_lidarCHM, y = insituMaxHt)) + 
      geom_point() + 
      ylab("Maximum Measured Height") + 
      xlab("Maximum LiDAR Height")+
      geom_abline(intercept = 0, slope=1)+
      geom_smooth(method=lm)
    
    p + theme(panel.background = element_rect(colour = "grey")) + 
      ggtitle("LiDAR CHM Derived vs Measured Tree Height") +
      theme(plot.title=element_text(family="sans", face="bold", size=20, vjust=1.9)) +
      theme(axis.title.y = element_text(family="sans", face="bold", size=14, angle=90, hjust=0.54, vjust=1)) +
      theme(axis.title.x = element_text(family="sans", face="bold", size=14, angle=00, hjust=0.54, vjust=-.2))

![ ]({{ site.baseurl }}/images/rfigs/institute-materials/day3_wednesday/lidar-chm-to-insitu/ggplot-data-1.png)



You have now successfully created a canopy height model using lidar data AND compared lidar 
derived vegetation height, within plots, to actual measured tree height data!


# Challenge 

> Create a plot of LiDAR 95th percentile value vs *insitu* max height. Or Lidar 95th 
> percentile vs *insitu* 95th percentile. Add labels to your plot. Customize the
> colors, fonts and the look of your plot. If you are happy with the outcome, share
> your plot in the comments below! 

## Create Plot.ly Interactive Plot

Plot.ly is a free to use, online interactive data viz site. If you have the 
plot.ly library installed, you can quickly export a ggplot graphic into plot.ly!
 (NOTE: it also works for python matplotlib)!! To use plotly, you need to setup 
an account. Once you've setup an account, you can get your key from the plot.ly 
site to make the code below work.



    library(plotly)
    #setup your plot.ly credentials
    set_credentials_file("yourUserName", "yourKey")
    p <- plotly(username="yourUserName", key="yourKey")
    
    #generate the plot
    py <- plotly()
    py$ggplotly()

Check out the results! 

NEON Remote Sensing Data compared to NEON Terrestrial Measurements for the SJER Field Site

<iframe width="460" height="293" frameborder="0" seamless="seamless" scrolling="no" src="https://plot.ly/~leahawasser/24.embed?width=460&height=293"></iframe>
