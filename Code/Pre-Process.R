###### Pre-Process for cuESTARFM

####INPUTS
#### Landsat images in tar.gz format. for the corresponding dates
#### MODIS images cropped by shapefile to all the dates

##### Extract Landsat BANDS.
##### Bands of interest are 
##### L8  R<-Band 4  
#####     NIR<- Band 5
#####
##### L7  R<-Band 3
#####     NIR<- Band 4


################# Load the Libraries ########
library(raster)


############ START Pre Processing ###########
#### Set the working directory
setwd("/Volumes/PLEXTOR/JASPR/cuESTARFM-R")

#### Check if folders exist. Extracted, Processed, tmp etc.

directoryExists("Rasters/extracted")
directoryExists("Rasters/done")
directoryExists("Rasters/tmp")

########  Set the tmp directory for the
########  Raster processes.  These take up 
########  a lot of space, so they need to be 
########  easy to clean up after processing is
########  done.

rasterOptions(tmpdir = "Rasters/tmp")


#### Extract Bands from L7

#### Get list of L7 files.
gzList<-list.files(getwd(), full.names=TRUE, pattern="^LE07_.*\\.gz")
lastRow<-length(gzList)

################################################
# Load all the necessary parameters for Landsat7
bands<-c("R","NIR")
filePatterns<-c("B4\\.TIF$","B5\\.TIF$")
bandFiles<-c(4,5)
#########################################





#### Extract Bands from L8



#####################################################
##### FUNCTIONS SECTION #############################
##### Load before running code above ################
#####################################################

######

extractBands<-function(zipFile,filePatterns){
  # extract bands from landsat zipfile, and save into directory "extracted"
  # Inputs m
  bandFiles<-NULL
  
  # set the extract directory
  extractDirectory <-file.path(dirname(zipFile), "Rasters/extracted")
  fileList<-untar(zipFile, list=TRUE)
  for(i in 1:length(filePatterns)){
    bandFiles[i]<-grep(filePatterns[i],fileList)
  }
  untar(zipFile, files = fileList[bandFiles], exdir = extractDirectory)
  
}



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
