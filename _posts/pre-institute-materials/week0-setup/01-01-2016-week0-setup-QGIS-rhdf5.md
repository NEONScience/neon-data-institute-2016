---
layout: post
title: "Install QGIS, HDF5 view"
description:
date: 2016-05-17
dateCreated: 2014-05-06
lastModified: 2016-05-18
estimatedTime: 1.0 - 1.5 Hours
packagesLibraries:
categories: [tutorial-series]
tutorialSeries: [pre-institute0]
tags:
mainTag: pre-institute0
code1:
image:
 feature: data-institute-2016.png
 credit:
 creditlink:
permalink: /tutorial-series/setup-qgis-h5view
comments: true
---

{% include _toc.html %}

## Install HDFView
The free HDFView application allows you to explore the contents of an HDF5 file.

To install HDFView:

1. Click
<a href="https://www.hdfgroup.org/products/java/release/download.html" target="_blank"> to go to the download page</a>.

2. From the section titled **HDF-Java 2.11 Pre-Built Binary Distributions**
select the HDFView download option that matches the operating system and
computer setup (32 bit vs 64 bit) that you have. The download will start
automatically.

3. Open the downloaded file. If you are on a MAC, you may want to add the
HDFView application to your Applications directory.

4. Open HDFView to ensure that the program installed correctly.

## Install QGIS
QGIS is a free, open-source GIS program. To install QGIS:

Download the installed on the
<a href="http://www.qgis.org/en/site/forusers/download.html" target="_blank">
QGIS download page here </a>. Follow the installation directions below for your
operating system.

### Windows

1. Select the appropriate **QGIS Standalone Installer Version** for your computer.
2. The download will automatically start.
3. Open QGIS to ensure that it is properly downloaded and installed.

#### Mac OSX

1. Select **<a href="http://www.kyngchaos.com/software/qgis" target=_"blank">
KyngChaos QGIS download page</a>**. This will take you to a new page.

2. Select the current version of QGIS. The download file (dmg format) should start automatically.
3. Once downloaded, open the file and read the READ ME BEFORE INSTALLING.rtf file.

Install the packages in the order indicated.

1. GDAL Complete.pkg
2. NumPy.pkg
3. matplotlib.pkg
4. QGIS.pkg - The other packages must be installed first.

<i class="fa fa-star"></i> **Data Tip:** If your computer doesn't allow you to
open these packages because they are from an unknown developer, right click on
the package and select Open With >Installer (default). You will then be asked
if you want to open the package. Select Open, and the installer will open.
{: .notice}

Once all of the packages are installed, open QGIS to ensure that it is properly
 installed.

#### LINUX

1. Select the appropriate download for your computer system.
2. Note: if you have previous versions of QGIS installed on your system, you may
run into problems. Check out
<a href="https://www.qgis.org/en/site/forusers/alldownloads.html" target="_blank">
this page from QGIS for additional information</a>.
3. Finally, open QGIS to ensure that it is properly downloaded and installed.
