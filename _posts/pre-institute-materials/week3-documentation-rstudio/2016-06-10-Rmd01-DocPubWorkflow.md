---
layout: post
title: "Document & Publish Your Workflow --- R Markdown & knitr"
description: "This tutorial introduces the importance of documentation & 
publishing one's workflow, as well as tools to accomplish this task."
date: 2016-05-19
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
permalink: /tutorial-series/pre-institute3/rmd01
comments: true
---

{% include _toc.html %}

In this page, you will be introduced to the importance of version control in 
scientific workflows. 

<div id="objectives" markdown="1">

# Learning Objectives
At the end of this activity, you will: 

* Be able to document your code using R Markdown (.rmd).
* Be able to create an R Markdown file in R.
* Know how to use the knitr package to publish code and associated resultant 
plots / visualizations in RStudio. 

</div>

## Documentation Is Important

As we read in 
<a href="http://neon-workwithdata.github.io/neon-data-institute-2016/tutorial-series/pre-institute1/rep-sci" target="_blank"> week 1</a>, 
the four facets of reproducible science are **Documentation, Organization, 
Automation,** and **Dissemination**. This week we will learn about the 
R Markdown file format (and R package) which can be used with the knitr package 
to document and publish your code and workflow results. 

## Documentation and Dissemination
Please view 
<a href="http://neon-workwithdata.github.io/slide-shows/share-publish-archive-slideshow.html" target= "_blank"> this slideshow from the Reproducible Science Curriculum</a> 
for more on sharing, publishing, and archiving. 

## The Tools We Will be Using

### R Markdown  

> “R Markdown is an authoring format that enables easy creation of dynamic 
documents, presentations, and reports from R. It combines the core syntax of 
markdown (an easy to write plain text format) with embedded R code chunks that 
are run so their output can be included in the final document. R Markdown 
documents are fully reproducible (they can be automatically regenerated whenever 
underlying R code or data changes). " 
-- <a href="http://rmarkdown.rstudio.com/" target="_blank">RStudio</a>. 

We can use markdown syntax in R Markdown (.rmd) files to document workflows and 
to share data cleaning, analysis and visualization results. We can also use it 
to create reports or other materials that combine R output with text. 

<i class="fa fa-star"></i> **Data Tip:** Most of the 
<a href="https://github.com/NEONInc/NEON-Data-Skills" target="_blank">neondataskills.org </a> 
and the 
<a href="https://github.com/NEON-WorkWithData/neon-data-institute-2016" target="_blank">Data Institute </a> 
sites are built from R Markdown files. 
{: .notice}


### Why R Markdown? 
R Markdown offers several advantages to those who want to learn and use it: 

* the syntax is human readable.
* the syntax is relatively limited, so it isn’t too cumbersome to master.
* the analysis is self-documenting so you always know what steps, assumptions, 
tests, etc were used.
* one can easily extend or refine analyses by modifying existing or adding new 
code blocks.
* the results of the analysis can be disseminated in various formats including 
HTML, PDF, presentations and more as a summary of the analysis. 
* the code and associated data can also be shared directly with a colleague to 
replicate the workflow. 

<i class="fa fa-star"></i> **Data Tip:** 
<a href="https://rpubs.com/" target= "_blank ">RPubs</a> 
is a quick way to share and publish code. 
{: .notice}

## Knitr
The knitr package allows us to create easily readable documents from R Markdown 
files. It is actually this package that reads the R Markdown file and produces the html
or other file format. 

>The knitr package was designed to be a transparent engine for dynamic report 
generation with R -- 
<a href="http://yihui.name/knitr/" target="_blank"> Yihui Xi -- knitr package creator</a>


Now continue on to the 
[next tutorial]({{site.baseurl}}/tutorial-series/pre-institute3/rmd-activity)
to learn about this week's activity. 
