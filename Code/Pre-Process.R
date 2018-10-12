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
library(stringr)
library(chron)
library(RCurl)

cuESTARFM_pre_process<-function(Modis_URL_List="Rasters/MODIS/GWE.txt",Index_to_calculate="NDVI"){
  # Create all the necessary directories
  
  create_Directories_for_cuESTARFM()
  
  ########  Set the tmp directory for the
  ########  Raster processes.  These take up 
  ########  a lot of space, so they need to be 
  ########  easy to clean up after processing is
  ########  done.
  
  #set tmp directory for RASTER functions
  rasterOptions(tmpdir = "Rasters/tmp")
  
  #Download and Rename b01
  download_MODIS_from_File_and_rename_to_band(Modis_URL_list, "b01")
  #Download and Rename b02
  download_MODIS_from_File_and_rename_to_band(Modis_URL_list, "b02")
  
  # Extract the LANDSAT bands from the LANDSAT tar.gz
  extract_LANDSAT_for_cuESTARFM()
  
  # Reproject b01 to LANDSAT
  reproject_MODIS_to_Landsat(MODIS_folder="Rasters/MODIS/MODIS_B1")
  
  # Reproject b02 to LANDSAT
  reproject_MODIS_to_Landsat(MODIS_folder="Rasters/MODIS/MODIS_B2")
  
  # crop Landsat images to MODIS extent
  crop_LANDSAT_to_MODIS()
  
  # Calculate INDICES for MODIS
  
  # Calculate INDICES for LANDSAT
  
  
}


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
  directoryExists("Rasters/PROCESSED")
  directoryExists("Code/PARAMS")
  
  
}




#---------------------------------------------------------------------
download_MODIS_from_File_and_rename_to_band<-function(MODIS_url,band_id="b01"){
  # Inputs
  ## MODIS_url -> text file with URLs of MODIS images to be downloaded
  ##              as generated from https://lpdaacsvc.cr.usgs.gov/appeears/explore
  ##              from NASA
  
  #armo una lista con todos los url a descargar
  MODIS_list=readLines(MODIS_url)
  
  #####Debug  
  #band_id="b01"
  ################
  
  band_id=paste("_",band_id,"_",sep="")
  #print(band_id)
  # selecciono que nombre de salida quiero tener si R o IR
  if(band_id=="_b01_"){band_out_id="R"}
  if(band_id=="_b02_"){band_out_id="NIR"}
  #Genero un dataframe solo con la banda requerida
  MODIS_DF=as.data.frame(grep(band_id, MODIS_list,value=TRUE),bycol=T)
  MODIS_DF=data.frame(lapply(MODIS_DF,as.character),stringsAsFactors=FALSE)
  #nombro la columna de df de acuerdo al nombre de banda R o IR
  #names(MODIS_DF)=band_out_id
  #Genero una carpeta donde se guardaran los rasters como /MODIS_R
  #getwd()
  directoryExists(paste("Rasters/MODIS/MODIS_",band_out_id,sep=""))
  dest_path=paste("Rasters/MODIS/MODIS_",band_out_id,"/",sep="")
  #i=1
  for(i in 1:nrow(MODIS_DF)){
    #Extraigo la fecha en formato de modis original 2015325
    date=gsub(".*[_doy]([^.]+)[_].*", "\\1", MODIS_DF[i,1])
    #agrego el a?o a una columna del dataframe
    MODIS_DF$YEAR[i]=as.numeric(substr(date, start = 1, stop = 4))
    #-transformo los dias julianos en mes y dia para cada a?o
    julian_day=as.numeric(substr(date, start = 5, stop = 7))  
    origin.=as.numeric(c(month = 1, day = 1, year = MODIS_DF$YEAR[i]))
    date=month.day.year(julian_day, origin.)
    month=str_pad(date$month, 2, pad = "0")
    day=str_pad(date$day, 2, pad = "0")
    #genero una columna del df con el formato de nombre que necesita cuESTARFM
    MODIS_DF$NOMBRE[i]=paste("M_",date$year,"_",month,"_",day,"_",band_out_id,".tif",sep="")
    #------descargo el raster para el renglon i del dataframe
    #lo guardo en el directorio creado y con el nombre_i
    URL <- as.character(MODIS_DF[i,1])
    destfile=as.character(MODIS_DF$NOMBRE[i])
    download.file(url=URL,paste(dest_path,destfile,sep=""), method='curl')
    #--------------------
    
  }
}
#------------------------------------------------------------------------------------
extract_LANDSAT_for_cuESTARFM<-function(LANDSAT_folder="Rasters/LANDSAT"){
  # Extract bands for L5
  #### Get list of L5 files.
  gzList<-list.files(LANDSAT_folder, full.names=TRUE, pattern="^LT05.*\\.gz")
  lastRow<-length(gzList)
  
  ################################################
  # Load all the necessary parameters for Landsat5
  
  bands<-c("R","NIR")
  filePatternsX<-c("band3\\.tif$","band4\\.tif$","B3\\.tif$","B4\\.tif$")
  filePatternsW<-c("band3.tif","band4.tif","B3.tif","B4.tif")
  
  filePatterns<-ifPlatform(filePatternsW,filePatternsX)
  #########################################
  
  if(length(gzList)==0){
    message("There are no images for L5 in the folder")
    
  }else{
    for (i in 1:lastRow){
      # go through each file to process it
      # Extract the needed bands
      zipFile<-gzList[i]
      extractBands(zipFile=zipFile, filePatterns)
    }
    message(paste("Extracted", lastRow, "Landsat 5 files"))
    
    rename_LANDSAT_tif_R_NIR(filePatterns = filePatterns, bands = bands)
    
  }
  
  # Extract bands for L7
  
  #### Get list of L7 files.
  gzList<-list.files(LANDSAT_folder, full.names=TRUE, pattern="^LE07.*\\.gz")
  lastRow<-length(gzList)
  
  ################################################
  # Load all the necessary parameters for Landsat7
  bands<-c("R","NIR")
  filePatternsX<-c("band3\\.tif$","band4\\.tif$" ,"B3\\.tif$","B4\\.tif$")
  filePatternsW<-c("band3.tif","band4.tif","B3.tif","B4.tif")
  
  filePatterns<-ifPlatform(filePatternsW,filePatternsX)
  
  
  #########################################
  
  if(length(gzList)==0){
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

  filePatternsX<-c("band4\\.tif$","band5\\.tif$","B4\\.tif$","B5\\.tif$")
#  filePatterns<-c("B4\\.tif$","B5\\.tif$")
  filePatternsW<-c("band4.tif","band5.tif","B4.tif","B5.tif")
 
  filePatterns<-ifPlatform(filePatternsW,filePatternsX)
  
  
   #########################################
  
  if(length(gzList)==0){
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
      myNewFileName<-paste("Rasters/LANDSAT/LANDSAT_",bands[j], "/", basename(myNewFileName),sep="")
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
    bandFiles[i]<-
      
      #grep(filePatterns[i],fileList)
      if (!any(grepl(filePatterns[i],fileList)))bandFiles[i]="NULL"  else bandFiles[i]=which(grepl(filePatterns[i],fileList)==TRUE)
      
  }
  bandFiles<-bandFiles[!bandFiles=="NULL"]
  # the bandFiles are seen as character...  so make them numeric.
  bandFiles<-as.numeric(bandFiles)

  untar(zipFile, files = fileList[bandFiles], exdir = extractDirectory)
  
}


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
    filepath<-file.path("Rasters/LANDSAT/CROPPED",filename)
    
    writeRaster(landsatCrop, filename = filepath)
    
    
  }
  
}



#######################################################
### Calculate the different Indices
#######################################################

###############
## NDVI
###############
calcNDVI<-function(rasterStack){
  NIR<-rasterStack$NIR
  R<-rasterStack$R
  message("NDVI")
  ndviRaster<-overlay(NIR,R,
                      fun=function(NIR,R){
                        return(
                          (R-NIR)/(R+NIR)
                        )
                      })
    ndviRaster<-removeNDVIextremes(ndviRaster)
  return(ndviRaster)
}

#######################
# MSAVI2
######################
calcMSAVI2<-function(rasterStack){
  NIR<-rasterStack$NIR
  R<-rasterStack$R
  message("MSAVI2")
  MSAVI2Raster<-overlay(NIR,R,
                        fun=function(NIR,R){
                          return(
                            (1/2)*((2*NIR + 1)-sqrt((2*NIR + 1)^2-8*(NIR - R)))
                          )
                        })
  return(MSAVI2Raster)
}

#######################
# WDRVI02
######################
calcWDRVI02<-function(rasterStack){
  NIR<-rasterStack$NIR
  R<-rasterStack$R
  message("WDRVI02")
  wdrvi02Raster<-overlay(NIR,R,
                         fun=function(NIR,R){
                           return(
                             (0.2*NIR - R) / (0.2*NIR + R)
                           )
                         })
  return(wdrvi02Raster)
}











directoryExists<-function(directory) {
  # check to see if there is a processing folder in workingDirectory 
  # and check that it is clear.
  if(dir.exists(directory)){
    message(paste("Nothing to do,",directory," exists"))
  }else{
    # if not the case, create it.
    
    dir.create(directory,recursive=TRUE)
  }
  
  
}

removeNDVIextremes<-function(r1){
  # remove values below -0.995, and make them -0.995
  r1[r1<-0.995]=-0.995
  # remove values above 0.995 and make them 0.995
  r1[r1>0.995]=0.995
  return(r1)
}

#--------------------------------------------
cuESTARFM_parameters_file<-function(MODIS_folder="Rasters/MODIS/REPROJECTED",LANDSAT_folder="Rasters/LANDSAT/CROPPED",cuESTARFM_parameters="C:/Users/MC1988/Google Drive/PROFESIONALES-ACADEMICOS/AGRISAT/20180917_cuESTARFM/002_cuESTARFM parameters example/parameters_example.txt"){
  #se procesa de a un par de bandas MODIS-LANDSAT por ejecucion Y se genera el archivo para ejecutar cuESTARFM
  library(stringr)
  library(chron)
  library(raster)
  library(data.table)
  #--------------------------------------------
  param_path="Code/PARAMS/"
  SINT_LS_path="Rasters/PROCESSED"
  #-------------------------------------------- 
  #leo linea por linea el ejemplo de los parametros del programa
  cuESTARFM_parameters=readLines(cuESTARFM_parameters)
  #--------------------------------------------
  MODIS_IN=gsub("/ ","/",list.files(MODIS_folder,pattern=".tif",full.names = T))
  LANDSAT_IN=gsub("/ ","/",list.files(LANDSAT_folder,pattern=".tif",full.names = T))
  #--------------------------------------------
  MODIS_IN=as.data.frame(basename(MODIS_IN),byrow=TRUE)
  names(MODIS_IN)="MODIS"
  LANDSAT_IN=as.data.frame(basename(LANDSAT_IN),byrow=TRUE)
  names(LANDSAT_IN)="LANDSAT"
  #----------agrego fecha a los DF MODIS Y LANDSAT-------
  
  for(i in 1:nrow(MODIS_IN)){
    date=as.numeric(str_replace_all(gsub(".*M_|.tif.*", "", MODIS_IN$MODIS[i]),pattern="_",replacement=""))
    MODIS_IN$DATE[i]=date
  }
  
  for(j in 1:nrow(LANDSAT_IN)){
    date=as.numeric(str_replace_all(gsub(".*L_|.tif.*", "", LANDSAT_IN$LANDSAT[j]),pattern="_",replacement=""))
    LANDSAT_IN$DATE[j]=date
  }
  
  #-Genero un DF con los pares MODIS-LANDSAT de referencia
  MODISLANDSAT_REF=merge(MODIS_IN,LANDSAT_IN,by="DATE")
  #Genero un DF con los MODIS de las fechas a interpolar
  MODIS_PRED=MODIS_IN[!(MODIS_IN$DATE %in% MODISLANDSAT_REF$DATE),]
  #Elimino los DF que ya no utilizo
  rm(MODIS_IN,LANDSAT_IN)
  #######################################################################################
  #Construyp el archivo de parametros cuESTARFM para cada par MODIS-LANDSAT de referencia
  #i=1
  for(i in 1:(nrow(MODISLANDSAT_REF)-1)){
    #filtro los MODIS que caen entre el par MODIS-LANDSAT
    #--------------------------------------------------
    MODIS_CAPTURED=MODIS_PRED[(MODIS_PRED$DATE > MODISLANDSAT_REF$DATE[i] & MODIS_PRED$DATE < MODISLANDSAT_REF$DATE[i+1]),]
    #genero una lista con los nombres a incluir
    MODIS_names=paste(basename(MODIS_CAPTURED$MODIS), collapse = " ")
    #rm(MODIS_CAPTURED)
    #--------------------------------------------------
    #agrego los nombres a usar para generar los landsat sinteticos
    MODIS_CAPTURED$SINT_LANDSAT=paste("SI_LS_",gsub(".*M_|$.*","",MODIS_CAPTURED$MODIS[i]),sep="")
    SINT_LS_names= paste(basename(MODIS_CAPTURED$SINT_LANDSAT), collapse = " ")
    #Modifico el archivo de parametros
    #modifico las filas del archivo de texto que se actualizan para cada ejecucion del programa
    cuESTARFM_parameters[8]=paste("  IN_PAIR_MODIS_FNAME =",MODISLANDSAT_REF$MODIS[i],MODISLANDSAT_REF$MODIS[i+1])
    cuESTARFM_parameters[12]=paste(" IN_PAIR_LANDSAT_FNAME =",MODISLANDSAT_REF$LANDSAT[i],MODISLANDSAT_REF$LANDSAT[i+1])
    cuESTARFM_parameters[17]=paste(" IN_PDAY_MODIS_FNAME =",MODIS_names)
    cuESTARFM_parameters[22]=paste(" OUT_PDAY_LANDSAT_FNAME =",SINT_LS_names)
    #creo el nombre del arhivo de salida
    txt_name=paste(param_path,"PARAM_",i,".txt",sep="")
    #exporto como txt el archivo de parametros con los datos
    writeLines(cuESTARFM_parameters,txt_name)
    #############################################################################
    #############      FIN                    ###################################
    #############################################################################
  }
}


### function to check the OS and deliver different values depending on the answer

ifPlatform<-function(ifWindows,ifUnix){
  
  #### if UNIX
  if(.Platform$OS.type == "unix") {
    myAnswer <- ifUnix
    
    ### if WINDOWS
  } else if(.Platform$OS.type == "windows"){
    myAnswer <- ifWindows
    
    ### if unknown.
  } else {
    myAnswer <- "Error  Unkown Platform"
  }
  return(myAnswer)
}
