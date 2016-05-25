---
layout: post
title: "Week 3 Activity"
description: "This page details how to complete the activity for pre-Institute week 3."
date: 2016-05-18
dateCreated: 2016-01-01
lastModified: 2016-05-25
estimatedTime: 
packagesLibraries: []
authors: [Megan A. Jones, Leah Wasser]
categories: [tutorial-series]
tags: []
mainTag: pre-institute3
tutorialSeries: pre-institute3
code1: 
image:
 feature: data-institute-2016.png
 credit:
 creditlink:
permalink: /tutorial-series/pre-institute3/rmd-activity
comments: true
---


**Due:** Please have this activity merged into the 
**NEON-WorkWithData/DI16-NEON-participants** GitHub repo by 11:59pm on 
16 June 2016.

This week, you will be working on opening and plotting NEON LiDAR data in R 
while learning how to use R Markdown and the knitr package to document your 
workflow. 

## Download Data 
Before we can begin to use R Markdown, you need to access the data: 

Download the Teakettle data subset from the NEON Data Skills Figshare Repository
Unzip 
Data directory 
There are several GeoTIFF files (raster format) in the “lidar” subdirectory of the subset. 


## Document Your Workflow
We will cover how to create and work in an R Markdown document in the next 
tutorial. Our scientific goal while doing this is to write the script for 
plotting these LiDAR raster files. 

Your script will document how you:

* plot at least 2 raster files from the data download using the raster::plot(raster) function and 
* create a histogram of the raster files to show the distribution of data values.

Once the script is complete, you will knit the R Markdown to html format and 
then submit your document (.html only) to the **/participants/TEAKRmd-week3** 
directory in the **NEON-WorkWithData/DI16-NEON-participants** GitHub repository. 

In the next two tutorials, we will focus on the documentation elements of the R 
Markdown and knitr tools as applied to this activity. If you are looking for 
assistance in plotting raster data in R, please see the NEON Data Skills tutorial 
<a href="http://neondataskills.org/R/Plot-Rasters-In-R/" target="_blank">*Plot Raster Data in R*</a>. 

## Submission Checklist
This checklist is provided for you to reference after you have completed the 
following tutorials and are ready to submit your documented workflow. 

Please include the following in your RMD file:

* Your name as an author of the file
* Explanatory text that describes your workflow in the Markdown portions of the 
R Markdown document. This text may include the data being used and plotted.
* 3 or more named R code chunks
* Code chunk options in at least 1 chunk


Now continue on to the 
[next tutorial]({{site.baseurl}}/tutorial-series/pre-institute3/rmd03)
to learn about R Markdown. 
