#este script es para ordenar y los rasters landsat 7 y landsat 8  a usar en el archivo de parametros
#necesario para ejecutar el cuESTARFM.
#---------------------------------------------------------------------
rm(list=ls())
getwd()
#---------------------------------------------------------------------
library(stringr)
library(chron)
library(RCurl)
library(raster)
library(dplyr)
#--------------TRABAJO CON LANDSAT 7 Y 8-----------------------------
LANDS_DIR="C:/Users/MC1988/Google Drive/PROFESIONALES-ACADEMICOS/AGRISAT/20180917_cuESTARFM/004_LANDSAT/"
LANDS_list=list.files(LANDS_DIR,pattern="\\.tif$",full.names = T)
#--------------------------------------------------------------------
LANDS_8_b4=LANDS_list[(str_detect(LANDS_list,'_band4')& str_detect(LANDS_list, 'LC08'))==TRUE]
LANDS_7_b3=LANDS_list[(str_detect(LANDS_list,'_band3')& str_detect(LANDS_list, 'LE07'))==TRUE]
LANDS_R=append(LANDS_8_b4,LANDS_7_b3)
#LANDS_R=as.data.frame(LANDS_R,byrow=T)
rm(LANDS_8_b4,LANDS_7_b3)
#------------------------
LANDS_8_b5=LANDS_list[(str_detect(LANDS_list,'_band5')& str_detect(LANDS_list, 'LC08'))==TRUE]
LANDS_7_b4=LANDS_list[(str_detect(LANDS_list,'_band4')& str_detect(LANDS_list, 'LE07'))==TRUE]
LANDS_IR=append(LANDS_8_b5,LANDS_7_b4)
#LANDS_IR=as.data.frame(LANDS_IR,byrow=T)
rm(LANDS_8_b5,LANDS_7_b4)
#para LANDS_R y LANDS_IR extraigo la fecha de captura y guardo las bandas en una carpeta
for(i in 1:length(LANDS_R)){
fecha=substr(basename(LANDS_R[i]),18,25)
ano=substr(fecha,1,4)
mes=substr(fecha,5,6)
dia=substr(fecha,7,8)
file_name=paste("L_",ano,"_",mes,"_",dia,".tif",sep="")
dir_R="C:/Users/MC1988/Google Drive/PROFESIONALES-ACADEMICOS/AGRISAT/20180917_cuESTARFM/004_LANDSAT/LANDS_R/"
file.copy(LANDS_R[i],paste(dir_R,file_name,sep=""),overwrite = TRUE)
}
#-----------------------------------------------
for(j in 1:length(LANDS_IR)){
  fecha=substr(basename(LANDS_IR[j]),18,25)
  ano=substr(fecha,1,4)
  mes=substr(fecha,5,6)
  dia=substr(fecha,7,8)
  file_name=paste("L_",ano,"_",mes,"_",dia,".tif",sep="")
  dir_IR="C:/Users/MC1988/Google Drive/PROFESIONALES-ACADEMICOS/AGRISAT/20180917_cuESTARFM/004_LANDSAT/LANDS_IR/"
  file.copy(LANDS_IR[j],paste(dir_IR,file_name,sep=""),overwrite = TRUE)
}
