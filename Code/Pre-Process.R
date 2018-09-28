###### Pre-Process for cuESTARFM

####INPUTS
#### Landsat images in tar.gz format. for the corresponding dates
#### MODIS images cropped by shapefile to all the dates

##### Extract Landsat BANDS.
##### Bands of interest are 
##### L8  R<- band4  
#####     NIR<- band5
#####
##### L7  R<- band3
#####     NIR<- band4


################# Load the Libraries ########
library(raster)
library(rgdal)
library(tools)


############ START Pre Processing ###########
#### Set the working directory
setwd("/Volumes/PLEXTOR/JASPR/cuESTARFM-R")


#### Check if folders exist. Extracted, Processed, tmp etc.

directoryExists("Rasters/extracted")
directoryExists("Rasters/reprojected")
directoryExists("Rasters/Ready_for_cuESTARFM")
directoryExists("Rasters/tmp")

########  Set the tmp directory for the
########  Raster processes.  These take up 
########  a lot of space, so they need to be 
########  easy to clean up after processing is
########  done.

rasterOptions(tmpdir = "Rasters/tmp")


#### Extract Bands from L7

#### Get list of L7 files.
gzList<-list.files("Rasters/Landsat", full.names=TRUE, pattern="^LE07.*\\.gz")
lastRow<-length(gzList)

################################################
# Load all the necessary parameters for Landsat7
bands<-c("R","NIR")
filePatterns<-c("band3\\.tif$","band4\\.tif$")
#########################################

if(is.null(gzList)){
  message("There are no images for L7 in the folder")
  
}else{
  for (i in 1:lastRow){
    # go through each file to process it
    # Extract the needed bands
    zipFile<-gzList[i]
    extractBands(zipFile=zipFile, filePatterns)
  }
  message(paste("Extracted", lastRow, "Landsat7 files"))
  
  ## rename the files to put the R or NIR
  for(j in 1:length(filePatterns)){

    BandFiles<-list.files("Rasters/extracted",full.names=TRUE, pattern=filePatterns[j])
    for(k in 1:length(BandFiles)){
      myExt<-file_ext(BandFiles[k])
      myNewFileName<-paste(file_path_sans_ext(BandFiles[k]),"_", bands[j],".",myExt, sep="")
      file.rename(BandFiles[k], myNewFileName)
    }
  }
  
}



#### Extract Bands from L8

#### Get list of L8 files.
gzList<-list.files("Rasters/Landsat", full.names=TRUE, pattern="^LC08.*\\.gz")
lastRow<-length(gzList)

################################################
# Load all the necessary parameters for Landsat8
bands<-c("R","NIR")
filePatterns<-c("band4\\.tif$","band5\\.tif$")
#########################################

if(is.null(gzList)){
  message("There are no images for L8 in the folder")
  
}else{
  for (i in 1:lastRow){
    # go through each file to process it
    # Extract the needed bands
    zipFile<-gzList[i]
    extractBands(zipFile=zipFile, filePatterns)
  }
  message(paste("Extracted", lastRow, "Landsat8 files"))
  
  
  ## rename the files to put the R or NIR
  for(j in 1:length(filePatterns)){
    
    BandFiles<-list.files("Rasters/extracted",full.names=TRUE, pattern=filePatterns[j])
    for(k in 1:length(BandFiles)){
      myExt<-file_ext(BandFiles[k])
      myNewFileName<-paste(file_path_sans_ext(BandFiles[k]),"_", bands[j],".",myExt, sep="")
      file.rename(BandFiles[k], myNewFileName)
    }
  }
}





#################### Open a MODIS file
modisList<-list.files("Rasters/MODISTest/MODIS_B2", full.names=TRUE, pattern=".*\\.tif$")

modisSample<-raster(modisList[1])
modisCRS<-crs(modisSample)
modisExtent<-extent(modisSample)
LandsatList<-list.files("Rasters/extracted", full.names=TRUE, pattern=".*\\.tif$")
landsatSample<-raster(LandsatList[1])
landsatCRS<-crs(landsatSample)
#####################
# i<-1
for(i in 1:length(modisList)){
  modisRaster<-raster(modisList[i])
  #res(modisRaster30m)<-30
  modisRasterUTM<-projectRaster(modisRaster,crs=landsatCRS)  # need to load the landsatCRS first!
  modisRasterUTM30m<-disaggregate(modisRasterUTM, res(modisRaster)/30)  # closest number to 30
  ### reproject again so that the pixels are exactly 30M.
  modisRasterUTM30m<-projectRaster(modisRasterUTM30m, crs=landsatCRS, res=30)
  # Save the new Raster
  
  filename<-paste("UTM",basename(modisList[i]),sep="_")
  filepath<-file.path("Rasters/reprojected",filename)
  modisUTMExtent<-extent(modisRasterUTM30m)
  writeRaster(modisRasterUTM30m, filename = filepath)
}





landsatList<-list.files("Rasters/extracted",full.names=TRUE, pattern=".*\\.tif$")
#i<-1
for (i in 1:length(landsatList)){
  landsatRaster<-raster(landsatList[i])
  landsatCRS<-crs(landsatRaster)
  landsatCrop<-crop(landsatRaster,modisRasterUTM30m, snap='near')
  filename<-paste("UTM",basename(landsatList[i]),sep="_")
  filepath<-file.path("Rasters/reprojected",filename)
  
  writeRaster(landsatCrop, filename = filepath)
  
  
}






#####################################################
##### FUNCTIONS SECTION #############################
##### Load before running code above ################
#####################################################



extractBands<-function(zipFile,filePatterns){
  # extract bands from landsat zipfile, and save into directory "extracted"
  # 
  bandFiles<-NULL
  
  # set the extract directory
  extractDirectory <-file.path(getwd(),"Rasters/extracted")
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
