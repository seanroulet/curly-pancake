#este script lee los rasters MODIS de una carpeta
#lee los rasters landsat de otra carpeta
#se genera un dataframe y se los aparea por fecha
#se escribe el archivo de parametros de cuESTARFM para cada uno de ellos
#---------------------------------------------------------------------
rm(list=ls())
getwd()
#---------------------------------------------------------------------
library(stringr)
library(chron)
library(raster)
library(data.table)
#--------------importo el archivo txt con los parametros----------------
cuESTARFM_parameters=readLines("C:/Users/MC1988/Google Drive/PROFESIONALES-ACADEMICOS/AGRISAT/20180917_cuESTARFM/002_cuESTARFM parameters example/parameters_example.txt")
#--------------armo dos listas con MODIS y Landsat---------------------
MODIS_B1_IN ="C:/Users/MC1988/Google Drive/PROFESIONALES-ACADEMICOS/AGRISAT/20180917_cuESTARFM/006_MODIS/MODIS_B1/"
MODIS_B2_IN="C:/Users/MC1988/Google Drive/PROFESIONALES-ACADEMICOS/AGRISAT/20180917_cuESTARFM/006_MODIS/MODIS_B2/"
LANDS_IR="C:/Users/MC1988/Google Drive/PROFESIONALES-ACADEMICOS/AGRISAT/20180917_cuESTARFM/004_LANDSAT/LANDS_IR/"
LANDS_R="C:/Users/MC1988/Google Drive/PROFESIONALES-ACADEMICOS/AGRISAT/20180917_cuESTARFM/004_LANDSAT/LANDS_R/"
#--------------------------------------------------------------------
MODIS_B1_IN=list.files(MODIS_B1_IN,pattern="\\.tif$",full.names = T)
MODIS_B2_IN=list.files(MODIS_B2_IN,pattern="\\.tif$",full.names = T)
LANDS_IR=list.files(LANDS_IR,pattern="\\.tif$",full.names = T)
LANDS_R=list.files(LANDS_R,pattern="\\.tif$",full.names = T)
#Genero un identificador de fecha para agregar al dataframe
#CHEQUEAR DESDE ACA HACIA ABAJO--------
MODIS_B1_DF=as.data.frame(MODIS_B1_IN,byrow=TRUE)
MODIS_B2_DF=as.data.frame(MODIS_B2_IN,byrow=TRUE)
LANDS_B1_DF=as.data.frame(LANDS_IR,byrow=TRUE)
LANDS_B2_DF=as.data.frame(LANDS_R,byrow=TRUE)
#----------agrego fecha al dataframe de modis b01 y b02-----------
for(i in 1:length(MODIS_B1_IN)){
  date=as.numeric(str_replace_all(gsub(".*M_|.tif.*", "", MODIS_B1_IN[i]),pattern="_",replacement=""))
  MODIS_B1_DF$DATE[i]=date
  MODIS_B2_DF$DATE[i]=date
}
rm(MODIS_B1_IN)
rm(MODIS_B2_IN)
#----------agrego fecha al dataframe de landsat b01 y b02----------
for(i in 1:length(LANDS_R)){
  date=as.numeric(str_replace_all(gsub(".*L_|.tif.*", "", LANDS_R[i]),pattern="_",replacement=""))
  LANDS_B1_DF$DATE[i]=date
  LANDS_B2_DF$DATE[i]=date
}
rm(LANDS_IR)
rm(LANDS_R)
#----Ahora combino ambos dataframes con id de LANDS_B1_DF$DATE[i]--
B1_REF=merge(MODIS_B1_DF,LANDS_B1_DF,by="DATE")
B2_REF=merge(MODIS_B2_DF,LANDS_B2_DF,by="DATE")
#Ya con los extremos de interpolacion,armo un df MODIS
#con los puntos que se busca interpolar
MODIS_B1_PRED=MODIS_B1_DF[!(MODIS_B1_DF$DATE %in% B1_REF$DATE),]
MODIS_B2_PRED=MODIS_B2_DF[!(MODIS_B2_DF$DATE %in% B2_REF$DATE),]

#CONTRUIR EL ARCHIVO DE PARAMETROS PARA LA BANDA 1 Y LA BANDA 2
#LLAMAR A cuESTARFM desde R y ejecutarlo.

INTERP_DAYS_B1=MODIS_B1_PRED[MODIS_B1_PRED$DATE > B1_REF$DATE[1] & MODIS_B1_PRED$DATE < B1_REF$DATE[2],]
INTERP_DAYS_B2=MODIS_B2_PRED[MODIS_B2_PRED$DATE > B2_REF$DATE[i] & MODIS_B2_PRED$DATE < B2_REF$DATE[i],]


