---
layout: post
title: "Document Code with R Markdown"
description: "This tutorial introduces how to use R Markdown files to document code."
date: 2016-05-17
dateCreated: 2016-01-01
lastModified: 2016-05-27
estimatedTime:
packagesLibraries: [knitr, rmarkdown]
authors: [Megan A. Jones, Leah Wasser]
categories: [tutorial-series]
tags: 
mainTag: pre-institute3-rmd
tutorialSeries: pre-institute3-rmd
code1:
image:
 feature: data-institute-2016.png
 credit:
 creditlink:
permalink: /tutorial-series/pre-institute3/rmd03
comments: true
---

{% include _toc.html %}

You will need to have `RMarkdown` and the `knitr`
package installed on your computer, prior to completing this tutorial. Refer to 
<a href="http://neon-workwithdata.github.io/neon-data-institute-2016/tutorial-series/install-R-packages" target="_blank"> the setup materials</a> to get these installed. 

<div id="objectives" markdown="1">

# Learning Objectives
At the end of this activity, you will:

* Know how to create an R Markdown file in RStudio.
* Be able to write a script with text and R code chunks.
* Create an R Markdown document ready to be ‘knit’ into an HTML document to
share your code and results.

## Things You’ll Need To Complete This Tutorial

You will need the most current version of R and, preferably, RStudio loaded on 
your computer to complete this tutorial.

### Install R Packages

To use R Markdown and knit: 
* **knitr:** `install.packages("knitr")`
* **rmarkdown:** `install.packages("rmarkdown")`

To complete Week 3 Assignment: 
* **raster:** `install.packages("raster")`
* **rgdal:** `install.packages("rgdal")`

### Download Data

<a class="btn btn-inverse" href="https://ndownloader.figshare.com/files/5282317" 
target="_blank">NEON Lower Teakettle (TEAK) Field Site Data</a>

The LiDAR and imagery data used to create this raster teaching data subset were 
collected over the 
<a href="http://www.neonscience.org/" target="_blank">National Ecological Observatory Network’s </a>
<a href="http://www.neonscience.org/science-design/field-sites/lower-teakettle" target="_blank">Lower Teakettle field site </a>
and processed at NEON 
headquarters. The entire dataset can be accessed by request from the 
<a href="http://www.neonscience.org/data-resources/get-data/airborne-data" target="_blank"> NEON Airborne Data Request Page on the NEON website.

## Additional Resources
* <a href="http://www.rstudio.com/wp-content/uploads/2016/03/rmarkdown-cheatsheet-2.0.pdf" target="_blank"> R Markdown Cheetsheet</a>: a very handy reference for using R
Markdown
* <a href="http://www.rstudio.com/wp-content/uploads/2015/03/rmarkdown-reference.pdf" target="_blank"> R Markdown Reference Guide</a>: a more expensive reference for R
Markdown
* <a href="http://rmarkdown.rstudio.com/articles_intro.html" target="_blank"> Introduction to R Markdown by Garrett Grolemund</a>: a tutorial for learning R Markdown

</div>


## Get Started

To begin, watch this 6:38 minute video that covers R Markdown and knitr in R Studio. 
The text size in the video is small - we recommend that you watch the video in
full screen mode.

<iframe width="560" height="315" src="https://www.youtube.com/embed/DNS7i2m4sB0" frameborder="0" allowfullscreen></iframe>

## Create a new RMarkdown file in RStudio

Our goal in week 3 is to document our workflow. We can do this by 

1. Creating an RMD file in R studio and
2. Rendering that RMD file to HTML using `knitr`. 

Please do the following: 

1. Create a new R Markdown file and choose HTML as the desired output format.
2. Enter a Title (Explore NEON LiDAR Data) and Author Name (your name). Then click OK.
3. Save the file using the following format: **LastName-institute-week3.rmd**
NOTE: The document title does not specify the filename.
4. Hit the knit button in R studio (as is done in the video above). What happens?

<figure>
	<a href="{{ site.baseurl }}/images/pre-institute-content/pre-institute3-rmd/KnitButton-screenshot.png">
	<img src="{{ site.baseurl }}/images/pre-institute-content/pre-institute3-rmd/KnitButton-screenshot.png"></a>
	<figcaption> Location of the knit button in RStudio in Version 0.99.486.
	Source: National Ecological Observatory Network (NEON)
	</figcaption>
</figure>



## Understand Structure of an R Markdown file

 <figure>
	<a href="{{ site.baseurl }}/images/pre-institute-content/pre-institute3-rmd/NewRmd-html-screenshot.png">
	<img src="{{ site.baseurl }}/images/pre-institute-content/pre-institute3-rmd/NewRmd-html-screenshot.png"></a>
	<figcaption> Screenshot of a new R Markdown document in RStudio.
	Source: National Ecological Observatory Network (NEON)  
	</figcaption>
</figure>

<i class="fa fa-star"></i> **Data Tip:** Screenshots on this page are
from RStudio with appearance preferences set to `Twilight w/ Monaco font`. You can
change the appearance of your RStudio by **Tools** > **Options**
(or **Global Options** depending on operating system). For more, see the
<a href="https://support.rstudio.com/hc/en-us/articles/200549016-Customizing-RStudio" target="_blank">Custominzing RStudio page</a>.
{: .notice}

When you open a new R Markdown file, it is pre-populated with content within 3 
main sections:

* Header text - in YAML format.
* Markdown or plain text.
* Code chunk text.

Next let's explore each section.

### Header text -- YAML block

An R Markdown file always starts with a YAML block. There are four default elements 
in the YAML header: 

* **title:** the title of your document. NOTE: This is not the same as the file name.
* **author:** who wrote the document
* **date:** by default this is the date that the file is created.
* **output:** what format will the output be in. We will use HTML.

There are many other ways this header can appear depending on the output or
formatting that you’d like to add. If interested, in these options see the
<a href="http://rmarkdown.rstudio.com/authoring_quick_tour.html#output_options" target="_blank"> R Markdown documentation</a>.

<div id="challenge" markdown="1">
## Activity: R Markdown YAML
Customize the header of your RMD file as follows: 

* **Title:** Provide a title that fits the code that will be in your RMD.  
* **Author:** Add your name here!  
* **Output:** This should be HTML! Leave this as is. we will be rendering an HTML file!  

</div>

### R Markdown Text / Markdown Blocks

In between code chunks and below the header text at the top of the document, you 
an add markdown syntax (the same syntax that we learned in week 2 - last week) 
to describe your workflow. For instance, you might describe
the data that you are using and what the outputs are. 

When you render your document to HTML, this markdown will appear as text on the 
document. 

<a class="btn btn-inverse" href="http://rmarkdown.rstudio.com/authoring_basics.html" target="_blank"> Learn More about RStudio Markdown Basics</a>

### Explore Your Rmd File

Look closely at the pre-populated markdown and R code chunks in your rmd file. 
Does any of the markdown syntax look familiar?

* Are any words in bold?
* Are any words in italics?
* Are any words highlighted as code?

If you are unsure, the answers are at the bottom of this page.

 <div id="challenge" markdown="1">
## Activity: R Markdown Text
Delete the text on line 8 and instead enter your own text that explains where
the NEON Teakettle LiDAR data come from and what the goal of this script is.
</div>

<i class="fa fa-star"></i> **Data Tip**: You can add code output or an R object
name to markdown segments of an Rmd. For more, view this
<a href="http://rmarkdown.rstudio.com/authoring_quick_tour.html#inline_r_code" target="_blank"> R Markdown documentation</a>.
{: .notice}

### Code chunks

Code chunks are where your R code goes. All
code chunks start and end with <code>```</code>  -- three backticks or graves.

HINT: On your keyboard, the backticks can be found on the same key as the tilde. 
They are not the apostrophe.

The initial line of the chunk must appear as:

<pre><code> ```{r chunk-name-with-no-spaces} 
# code goes here
 ```</code></pre>

The `r` part of the chunk header identifies this chunk as an R code chunk and is 
mandatory. Next to the `r`, there is a chunk name. This name is not required for 
basic knitting however,
it is good practice to give each chunk a unique name as it is required for
more advanced knitting approaches. 

<div id="challenge" markdown="1">
## Activity: Add Code Chunks to Your Rmd File

*  Delete all of the pre-populated text and code in your R Markdown file. DO NOT 
DELETE the YAML header!

* Create a code chunk that loads the libraries required to work with 
raster data in R, and sets the working directory.

<pre><code>```{r setup-read-data }
   library(rgdal)
   library(raster)

   # set working directory to ensure R can find the file we wish to import
   setwd("~/Documents/data/data-institute-2016/")

 ```</code></pre>

* Add another chunk that loads a raster file.

<pre><code>```{r load-dsm-raster }

   # import dsm
   teak_dsm <- raster("NEONdata/TEAK/2013/lidar/Teak_lidarDSM.tif")
 ```</code></pre>

* Run the code in chunk one. 

You can run code chunks: 

* **Line-by-line:** with cursor on current line, Ctrl + Enter (Windows/Linux) or
Command + Enter (Mac OS X).
* **By chunk:** You can run the entire chunk (or multiple chunks) by
clicking on the `Chunks` dropdown button in the upper right corner of the script
environment and choosing the appropriate option. Keyboard shortcuts are
available for these options.

</div>

### Code chunk options

You can also add arguments or options to each code chunk. These arguments allow 
you to customize how or if you want code to be
processed or appear on the output HTML document. Code chunk arguments are added on 
the first line of a code
chunk after the name, within the curly brackets.

The example below, is a code chunk that will not be "run" or evaluated by R. 
The code within the chunk will appear on the output document however there
will be not outputs from the code.

<pre><code>```{r intro-option, eval=FALSE}
# the code here will not be processed by R 
# but it will appear on your output document
1+2
 ```</code></pre>

Three common code chunk options are:

* `eval = FALSE` -- do not **eval**uate this code chunk when
running the script. The code will still show in the output, but will not be
evaluated.
* `echo=FALSE` -- hide the code in the output. The code is
evaluated but only the output is rendered on the output document.
* `results=hide` -- the code chunk will be evaluated but the results will not
be rendered on the output document.

Multiple code chunk options can be used for the same chunk. For more on code
chunk options, read
<a href="http://rmarkdown.rstudio.com/authoring_rcodechunks.html" target="_blank"> the RStudio documentation</a>
or the
<a href="http://yihui.name/knitr/demo/output/" target="_blank"> knitr documentation</a>.

<div id="challenge" markdown="1">
## Activity: Add More Code to Your Rmd

Update your Rmd file as follows:

* Add code to plot the dsm raster file a new code chunk. 
Experiment with colors in your plot. Be sure to add a title. 
* Run the code that you've added to your document.
* Open and plot another raster file. The Teak_lidarCHM is a good raster to plot.
* Add code to your document to create a histogram for both rasters that you've opened. 

If you need a resource for plotting rasters see the NEON Data Skills tutorial
<a href="http://neondataskills.org/R/Plot-Rasters-In-R/" target="_blank">*Plot Raster Data in R*</a>. 

We will knit this document to HTML in the next tutorial. 
</div>

Now continue on to the
[next tutorial]({{site.baseurl}}/tutorial-series/pre-institute3/rmd04)
to learn how to knit this document into a HTML file.

### Answers to the Default Text Markdown Syntax Questions

* Are any words in bold? - Yes, “Knit” on line 10
* Are any words in italics? - No
* Are any words highlighted as code? - Yes, “echo = FALSE” on line 22