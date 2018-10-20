###### Process for cuESTARFM

####INPUTS
#### List of Parameters text files for cuESTARFM execution
#### Ready_for_cuESTARFM folder with MODIS and Landsat files
#### already formated and named

##### OUTPUTS
#####  Sintetic Landsat files
#####  Sintetic Landsat files NA filled
#####   
#####
##### 
#####   
################# Load the Libraries ########
library(raster)
library(rgdal)
library(tools)
library(stringr)
library(chron)
library(RCurl)
#############################################
#Execute cuESTARFM for each parameter file
sys_command()
#Filter NDVI out of range and cuESTARFM discrepances
NDVI_fill_NA()
#############################################


##########################################################
##### This function executes cuESTARFM within r.     #####
####  It takes cuESTARFM parameter file as input     #####
##########################################################

sys_command=function(folder="Code/PARAMS",cu_path="/home/wtelectronica/cuESTARFM-master/Codes/cuESTARFM"){
  #leo los arhivos guardados, cada archivo es una ejecucion de cuESTARFM
  params_list=list.files(path=folder,pattern=".txt",full.names=TRUE)
  #genero un loop para ejecutar el programa
  #i=1
  for(i in 1:length(params_list)){
    #genero la sentencia de ejecucion del programa
    exec_sentence=paste(cu_path,params_list[i],sep=" ")
    #ejecuto el comando
    system(exec_sentence,wait=TRUE,show.output.on.console=TRUE)
  }
  
}

###############################################################################
####    This function replaces outlyer values with NA and completes   #########
####    NA regions obtained from cuESTARFM processing                 #########
###############################################################################


NDVI_fill_NA=function(NDVI_folder="Rasters/after_cuESTARFM"){
  
  ################
  NDVI_list=list.files(NDVI_folder,pattern=".tif$",ignore.case=TRUE,full.names=TRUE)
  ################
  
  for(i in 1:length(NDVI_list)){
    ndvi=raster(NDVI_list[i])
    ############3###
    for(j in 1:25){
      # Quito extremos superiores
      ndvi[ndvi > 0.975] <- NA
      #Quiro extremos inferiores
      ndvi[ndvi < -0.975] <- NA
      # reemplazo los valores NA con la media focal 3x3 
      # En el calculo de la media focal no tengo en cuenta los valores NA.
      ndvi=focal(ndvi,w=matrix(1,3,3),fun=mean,na.rm=TRUE,NAonly=TRUE,pad=TRUE)
      #gc()
    }
    filename=paste("NA_FILL_",basename(NDVI_list[i]),sep="")
    writeRaster(ndvi,filename=filename,format="GTiff",overwrite=TRUE)
    # Libero el uso de la memoria RAM luego de cada loop
    gc()
  }
}
################################################################################











