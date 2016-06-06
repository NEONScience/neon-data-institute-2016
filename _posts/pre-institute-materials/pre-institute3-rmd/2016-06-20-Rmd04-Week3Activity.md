---
layout: post
title: "Pre-Institute Week 3 Assignment"
description: "This page details how to complete the assignment for pre-Institute week 3."
date: 2016-05-16
dateCreated: 2016-01-01
lastModified: 2016-06-06
estimatedTime:
packagesLibraries:
authors:
categories: [tutorial-series]
tags:
mainTag: pre-institute3-rmd
tutorialSeries: pre-institute3-rmd
code1:
image:
 feature: data-institute-2016.png
 credit:
 creditlink:
permalink: /tutorial-series/pre-institute3/pre-week-3-activity
comments: true
---

## About
This tutorial covers the NEON Pre-Institute Week 3 assignment. If you already
are familiar with `R Markdown` and `knitr`, you may be able to complete the 
assignment without working through the tutorials. 

<div id="objectives" markdown="1">

# Deadlines
**Due:** Please submit your activity RMarkdown and HTML filesto the
**NEON-WorkWithData/DI16-NEON-participants** GitHub repo as a `pull-request`
by 11:59pm on 16 June 2016.

## Download Data

<a class="btn btn-success" href="https://ndownloader.figshare.com/files/5282317" 
target="_blank">NEON Lower Teakettle (TEAK) Field Site Data</a>

The LiDAR and imagery data used to create this raster teaching data subset were 
collected over the 
<a href="http://www.neonscience.org/" target="_blank">National Ecological Observatory Network’s </a>
<a href="http://www.neonscience.org/science-design/field-sites/lower-teakettle" target="_blank">Lower Teakettle field site </a>
and processed at NEON 
headquarters. The entire dataset can be accessed by request from the 
<a href="http://www.neonscience.org/data-resources/get-data/airborne-data" target="_blank"> NEON Airborne Data Request Page on the NEON website.

</div>


To begin, please do the following:

1. Download data from the Lower Teakettle field site - from the NEON Data Skills 
Figshare repository.
2. Unzip the data into a `data` directory on your computer. The path to your data 
will look like this:

`~\data\data-institute-2016\NEONdata\TEAK\2013\`

We will be using the GeoTIFF raster files in the “lidar” subdirectory of the 
download.

## Create RMD File

The next two tutorials will walk you through how to create, edit, and knit 
R Markdown files. Here are the components of the finished HTML file. 

* Create a new .Rmd file with an `HTML` output. 
* At the top of your `.Rmd` file, add your **bio** and **project summary**
that [you wrote and submitted in week 2 as a `.md` file]({{ site.baseurl}} tutorial-series/pre-institute2/git-culmination). 

* In the RMD file, create a script that does the following: 

  * Open and plot at least 2 raster files in the `/lidar/ directory using the `plot()` 
  function in the raster package.
  * Create a histogram for each raster file that shows the distribution of values 
  in the file.
  * Be sure to label your plots appropriately.
  
* Break up your code into R Markdown chunks that makes sense to you. Use Markdown to 
document the steps that you are taking to "process" the data. Provide some summary
discussion of the results at the end of the document. HINT: the raster `Teak_lidarCHM` 
represents **tree height** for the field site. You might comment on how tall the 
trees are on average at the site.

Please include the following in your R Markdown file:

* Your name as an author of the file.
* Explanatory text that describes your workflow in the Markdown portions of the
R Markdown document. This text may include the data being used and plotted.
* 3 or more named R code chunks.
* OPTIONAL: Code chunk options in at least 1 chunk, e.g.`warnings = FALSE`.

## Knitr: RMD to HTML

Once you have completed the steps above:

* Knit your .Rmd file to HTML. 
* Submit both the .Rmd and the .html documents to the 
**/participants/pre-institute3-rmd** directory in the 
**NEON-WorkWithData/DI16-NEON-participants** GitHub repository.

## Supporting Materials

The next two tutorials will walk you through how to create an R Markdown file 
and knit to HTML in R. Visit the NEON Data Skills tutorial below for help 
opening and plotting rasters in R: <a href="http://neondataskills.org/R/Plot-Rasters-In-R/" target="_blank">*Plot Raster Data in R*</a> 


Now continue on to the
[next tutorial]({{site.baseurl}}/tutorial-series/pre-institute3/rmd03)
to learn about R Markdown.