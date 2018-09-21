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

#### Extract Bands from L8



#####################################################
##### FUNCTIONS SECTION #############################
##### Load before running code above ################
#####################################################

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
