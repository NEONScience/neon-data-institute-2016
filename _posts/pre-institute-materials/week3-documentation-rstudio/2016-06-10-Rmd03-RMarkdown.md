---
layout: post
title: "Document Code with R Markdown"
description: "This tutorial introduces how to use R Markdown files to document code."
date: 2016-05-17
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
permalink: /tutorial-series/pre-institute3/rmd03
comments: true
---

{% include _toc.html %}

Prior to beginning this content you will need to have RMarkdown and the knitr 
package installed prior to completing this tutorial. If you do not, please refer 
back to 
<a href="http://localhost:4000/tutorial-series/install-R-packages" target="_blank"> the setup materials</a>. 

<div id="objectives" markdown="1">

# Learning Objectives
At the end of this activity, you will: 

* Know how to create an R Markdown file in RStudio.
* Be able to write a script with text and R code chunks.
* Create an R Markdown document ready to be ‘knit’ into an html document to 
share your code and results. 

## Additional Resources 
* <a href="http://www.rstudio.com/wp-content/uploads/2016/03/rmarkdown-cheatsheet-2.0.pdf" target="_blank"> R Markdown Cheetsheet</a>: a very handy reference for using R 
Markdown
* <a href="http://www.rstudio.com/wp-content/uploads/2015/03/rmarkdown-reference.pdf" target="_blank"> R Markdown Reference Guide</a>: a more expensive reference for R
Markdown
* <a href="http://rmarkdown.rstudio.com/articles_intro.html" target="_blank"> Introduction to R Markdown by Garrett Grolemund</a>: a tutorial for learning R Markdown

</div>

Watch this 6:38 minute video that introduces you to the use of R Markdown and 
knitr. Then continue onto the steps below that specify the use of R Markdown for 
this week’s activity and the Data Institute. Given the size of the text in the
video we recommend you watch this full screen. 

<iframe width="560" height="315" src="https://www.youtube.com/embed/DNS7i2m4sB0" frameborder="0" allowfullscreen></iframe> 

## Create a new RMarkdown file in RStudio
Our goal in week 3 is to document our workflow by creating a html file with our
code and output. Therefore, create a new R Markdown file and choose HTML as the
desired output format.

After creating a new R Markdown with html format selected, enter a Title 
(Plot NEON LiDAR Data) and Author Name (your name). Then click OK. 

Now save the file. When you entered the document title, you were not specifying 
the filename nor saving the document. Save the file as 
**LastName-LiDARplots-week3.rmd**. 

## Understand Structure of an R Markdown file

 <figure>
	<a href="{{ site.baseurl }}/images/pre-institute-content/RMD/NewRmd-html-screenshot.png">
	<img src="{{ site.baseurl }}/images//pre-institute-content/RMD/NewRmd-html-screenshot.png"></a>
	<figcaption> Screenshot of a new R Markdown document in RStudio. 
	Source: National Ecological Observatory Network (NEON)  
	</figcaption>
</figure>

<i class="fa fa-star"></i> **Data Tip:** All screenshots in this document are 
from RStudio with appearance preferences set to Twilight w/ Monaco font. You can 
change the appearance of your RStudio by **Tools** > **Options** 
(or **Global Options** depending on operating system). For more details, see the 
<a href="https://support.rstudio.com/hc/en-us/articles/200549016-Customizing-RStudio" target="_blank">Custominzing RStudio page</a>. 
{: .notice}

When you open a new R Markdown file, it comes pre-populated with text. This, and 
all R Markdown, text comes in 3 main sections: 

* header text 
* markdown or plain text 
* code chunk text 

We will further explore each section. 

### Header text -- YAML block: 
Just like in our Markdown file last week our R Markdown file starts with a YAML 
element. There are four default elements to the header: 

* **title:** the title of your document is not the same as the file name
* **author:** who should get credit for this document
* **date:** by default it is the date the file is created
* **output:** what format will the output be in, we will use html 

There are many other ways this header can appear depending on the output or 
formatting that you’d like to add. If interested, in these options see the 
<a href="http://rmarkdown.rstudio.com/authoring_quick_tour.html#output_options" target="_blank"> R Markdown documentation</a>.

<div id="challenge" markdown="1">
## Activity: R Markdown YAML 
The header block should be pre-populated with the information you input when creating the file. If any of the information is wrong or missing, add it now. 
</div>

### R Markdown Text

This is normal text that will show up as text and not code. You can use these 
areas to document your workflow. You can use any of the Markdown syntax we 
learned last week in these sections. In addition, there are a few R specific 
additions that can be added -- for details see 
<a href="http://rmarkdown.rstudio.com/authoring_basics.html" target="_blank"> RStudio’s Markdown Basics</a> . 

Look at the default text in your document. Based on your understanding of the 
markdown syntax: 

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

Code chunks are where the bulk of the actual code in the R Markdown occur. All 
code chunks starts and ends with ```  -- three backticks or graves (on the same 
key as the tilde, not the apostrophe). 

The initial line of the chunk must appear as: 

<pre><code> ```{r name-with-no-spaces} </code></pre>

The `r` identifies this as an R code chunk and is mandatory. The name, while not 
required, is a good practice in order to identify each chunk. 

 <div id="challenge" markdown="1">
## Activity: Code Chunks
First, create the first code chunk of your script for setting up the R 
environment and reading in the data.

<pre><code>```{r setup-read-data }
   library(rgdal)
   library(raster)
   
   # set working directory to ensure R can find the file we wish to import
   setwd("working-dir-path-here")
   
   # import first raster
   data <- raster("NEON-DS-Airborne-Remote-Sensing/HARV/DSM/HARV_dsmCrop.tif")
</code></pre>

Second, run the code. This can be done several ways:

* line-by-line: with cursor on current line, Ctrl + Enter (Windows/Linux) or 
Command + Enter (Mac OS X). 
* code chunk option: You can run the entire chunk (or multiple chunks) by 
clicking on the `Chunks` dropdown button in the upper right corner of the script 
environment and choosing the appropriate option. Keyboard shortcuts are 
available for these options. 

</div>

### Code chunk options

Code chunk options allow you to customize how or if you want code to be 
processed or appear. Code chunk options are added on the first line of a code 
chunk after the name, within the curly brackets.


     
Three common and useful options are:

* `eval = FALSE` -- this tells R to not **eval**uate this code chunk when 
running the script. The code will still show in the output, but will not be 
evaluated. 
* `echo=FALSE` -- this tells R to hide the code in the output. The code is 
evaluated but only the output shows. 
* `results=hide` -- the code chunk will be evaluated but the results will not 
be printed in the output. 

Multiple code chunk options can be used for the same chunk. For more on code 
chunk options, read 
<a href="http://rmarkdown.rstudio.com/authoring_rcodechunks.html" target="_blank"> the RStudio documentation</a>
or the 
<a href="http://yihui.name/knitr/demo/output/" target="_blank"> knitr documentation</a>.

 <div id="challenge" markdown="1">
## Activity
Plot the raster data file by adding one or more code chunks to your script. 
Ensure the code functions and then proceed to the next tutorial where we will 
use knitr to create the html file. 
</div>

Now continue on to the 
[next tutorial]({{site.baseurl}}/tutorial-series/pre-institute3/rmd04)
to learn how to knit this document into a html file. 

### Answers to the Default Text Markdown Syntax Questions

* Are any words in bold? - Yes, “Knit” on line 10 
* Are any words in italics? - No
* Are any words highlighted as code? - Yes, “echo = FALSE” on line 22
