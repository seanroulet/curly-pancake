#---------------------------------------------------------------------
######################################################################
##La funcion recibe como argumento el path del txt de descarga.#######
## y recibe la banda a renombrar con formato b01,b02 #################
######################################################################
#---------------------------------------------------------------------
library(stringr)
library(chron)
library(RCurl)
setwd("C:/Users/MC1988/Google Drive/PROFESIONALES-ACADEMICOS/AGRISAT/20180917_cuESTARFM/TEST_05_NQN/MODIS/")
#---------------------------------------------------------------------
MODIS_pre_cuestarfm<-function(MODIS_url,band_id){
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
  if(band_id=="_b02_"){band_out_id="IR"}
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
  