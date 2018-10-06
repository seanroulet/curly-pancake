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

create_Directories_for_cuESTARFM<-function(){

  #### Check if folders exist. Extracted, Processed, tmp etc.
  # Landsat Directories
  directoryExists("Rasters/LANDSAT/extracted")
  directoryExists("Rasters/LANDSAT/LANDSAT_R")
  directoryExists("Rasters/LANDSAT/LANDSAT_NIR")
  directoryExists("Rasters/LANDSAT/CROPPED")
  
  # MODIS directories
  directoryExists("Rasters/MODIS/REPROJECTED")
  directoryExists("Rasters/MODIS/MODIS_B1")
  directoryExists("Rasters/MODIS/MODIS_B2")
  
  directoryExists("Rasters/Ready_for_cuESTARFM")
  directoryExists("Rasters/tmp")
  directoryExists("Rasters/INDEX")
  
  
}


########  Set the tmp directory for the
########  Raster processes.  These take up 
########  a lot of space, so they need to be 
########  easy to clean up after processing is
########  done.

rasterOptions(tmpdir = "Rasters/tmp")

#####################################################
##### FUNCTIONS SECTION #############################
##### Load before running code above ################
#####################################################

reproject_MODIS_to_Landsat<-function(MODIS_folder="Rasters/MODIS/MODIS_B1",Landsat_folder="Rasters/LANDSAT/LANDSAT_R"){
  #################### Open a MODIS file
  ### Loads a MODIS raster from download and reprojects it to a Landsat CRS
  ####################
  modisList<-list.files(MODIS_folder, full.names=TRUE, pattern=".*\\.tif$")
  
  # load a LANDSAT sample so we can get the crs, etc.
  landsatList<-list.files(Landsat_folder, full.names=TRUE, pattern=".*\\.tif$")
  landsatSample<-raster(landsatList[1])
  landsatCRS<-crs(landsatSample)
  
  #####################
  # i<-1
  for(i in 1:length(modisList)){
    modisRaster<-raster(modisList[i])

    modisRasterUTM<-projectRaster(modisRaster,crs=landsatCRS)  
    modisRasterUTM30m<-disaggregate(modisRasterUTM, res(modisRaster)/30)  # closest number to 30
    
    ### reproject again so that the pixels are exactly 30M.
    modisRasterUTM30m<-projectRaster(modisRasterUTM30m, crs=landsatCRS, res=30)
    
    # Save the new Raster
    filename<-basename(modisList[i])
    filepath<-file.path("Rasters/MODIS/REPROJECTED",filename)
    writeRaster(modisRasterUTM30m, filename = filepath)
  }
  
  
  
}



crop_LANDSAT_to_MODIS<-function(MODIS_folder="Rasters/MODIS/REPROJECTED",Landsat_folder="Rasters/LANDSAT/LANDSAT_R"){
 
  ################
  # Load a Landsat Folder and CROP it to the REPROJECTED MODIS file
  ################
  
  # get a sample MODIS file so we can crop to it.
  modisList<-list.files(MODIS_folder, full.names=TRUE, pattern=".*\\.tif$")
  modisSample<-raster(modisList[1])
  
  landsatList<-list.files(Landsat_folder,full.names=TRUE, pattern=".*\\.tif$")
  #i<-1
  for (i in 1:length(landsatList)){
    landsatRaster<-raster(landsatList[i])

    landsatCrop<-crop(landsatRaster,modisSample, snap='near')
    filename<-basename(landsatList[i])
    filepath<-file.path("Rasters/CROPPED",filename)
    
    writeRaster(landsatCrop, filename = filepath)
    
    
  }
  
}











extract_LANDSAT_for_cuESTARFM<-function(LANDSAT_folder="Rasters/LANDSAT"){
  # Extract bands for L7
  
  #### Get list of L7 files.
  gzList<-list.files(LANDSAT_folder, full.names=TRUE, pattern="^LE07.*\\.gz")
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
    
    rename_LANDSAT_tif_R_NIR(filePatterns = filePatterns, bands = bands)
    
  }

    #### Extract Bands from L8
  
  #### Get list of L8 files.
  gzList<-list.files(LANDSAT_folder, full.names=TRUE, pattern="^LC08.*\\.gz")
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
    
    
    rename_LANDSAT_tif_R_NIR(filePatterns = filePatterns, bands = bands)
  }
  
}

rename_LANDSAT_tif_R_NIR<-function(filePatterns, bands, Extracted_folder="Rasters/LANDSAT/extracted"){
  ## rename the files to put the R or NIR
  for(j in 1:length(filePatterns)){
    
    BandFiles<-list.files(Extracted_folder,full.names=TRUE, pattern=filePatterns[j])
    for(k in 1:length(BandFiles)){
      myExt<-file_ext(BandFiles[k])
      myNewFileName<-paste(file_path_sans_ext(BandFiles[k]),"_", bands[j],".",myExt, sep="")
      myNewFileName<-paste("Rasters/LANDSAT/LANDSAT_",bands[j],"/",basename(myNewFilename),sep="")
      file.rename(BandFiles[k], myNewFileName)
    }
  }
  
}

extractBands<-function(zipFile,filePatterns,extractDirectory="Rasters/LANDSAT/extracted"){
  # extract bands from landsat zipfile, and save into directory "extracted"
  # 
  bandFiles<-NULL
  
  # set the extract directory
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
