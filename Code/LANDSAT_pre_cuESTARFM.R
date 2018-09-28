# Functions needed to transform Landsat 8-7 images to pre-process for E-StarFM

#  These functions extract the file bands from the tar.gz re-project to UTM South
#  and calculate indices for each tile. 

#Load necessary Libraries
library(tools)
library(raster)
library(rgdal)
library(gdalUtils)
#-------------------------------------------------------
directoryExists<-function(directory) {
  # check to see if there is a processing folder in workingDirectory 
  # and check that it is clear.
  if(dir.exists(directory)){
    message(paste("Nothing to do,",directory," exists"))
  }else{
    # if not the case, create it.
    
    dir.create(directory)
  }
 }
#-------------------------------------------------------
initializeSettings<-function(workingDirectory="C:/Users/MC1988/Google Drive/PROFESIONALES-ACADEMICOS/AGRISAT/20180917_cuESTARFM/"){
  # set the working directory
  # in Windows use the "/"
  setwd("C:/Users/MC1988/Google Drive/PROFESIONALES-ACADEMICOS/AGRISAT/20180917_cuESTARFM/")
  
  # set the variable for the temp directory
  rasterTempDirectory<-file.path(getwd(),"tmp")
  extractedDirectory<-file.path(getwd(),"extracted")
  doneDirectory<-file.path(getwd(),"done")
  
  # check that the directory exists
  directoryExists(rasterTempDirectory)
  directoryExists(extractedDirectory)
  directoryExists(doneDirectory)
  
  # set the raster temp directory
  #rasterOptions(tmpdir = rasterTempDirectory)
  
}
#-------------------------------------------------------
extractBands<-function(zipFile,filePatterns){
  # extract bands from landsat zipfile, and save into directory "extracted"
  #
  # clean the extract Directory just in case there is something lurking there
  extractedFiles<-list.files(file.path(getwd(),"extracted"), full.names=TRUE)
  file.remove(extractedFiles)
  bandFiles<-NULL
  
  # set the extract directory
  extractDirectory <-file.path(dirname(zipFile), "extracted")
  fileList<-untar(zipFile, list=TRUE)
  for(i in 1:length(filePatterns)){
    bandFiles[i]<-grep(filePatterns[i],fileList)
  }
  untar(zipFile, files = fileList[bandFiles], exdir = extractDirectory)
  #------------------------------------------------------------------------
  LANDSAT_lista=list.files(getwd(), pattern=filePatterns, full.names=FALSE)
}
#-------------------------------------------------------
processSatFiles<-function(folder=getwd(), satellite="L8",newCRS="+proj=utm +zone=20 +south +datum=WGS84 +units=m +no_defs"){
  gzList<-NULL
  if(satellite=="L8"){
    gzList<-list.files(getwd(), full.names=TRUE, pattern="^LC08.*\\.gz")
    lastRow<-length(gzList)
    ################################################
    # Load all the necessary parameters for Landsat8
    bands<-c("R","NIR")
    filePatterns<-c("_band4//.TIF$","_band5//.TIF$")
    bandFiles<-c(4,5)
    #########################################
  }
  if(satellite=="L7"){
    gzList<-list.files(getwd(), full.names=TRUE, pattern="^LE07.*//.gz")
    lastRow<-length(gzList)
    ################################################
    # Load all the necessary parameters for Landsat7
    bands<-c("R","NIR")
    filePatterns<-c("B3//.TIF$","B4//.TIF$")
    bandFiles<-c(3,4)
    #########################################
  }
  if(is.null(gzList)){
    message(paste("There are no images for", satellite, "in the folder"))
    
  }else{
    for (i in 1:lastRow){
      # go through each file to process it
      # Extract the needed bands
      zipFile<-gzList[i]
      extractBands(zipFile=zipFile, filePatterns)
      
    }}}

#-------------------------------------------------------

