#este script es para ordenar y los archivos MODIS a usar en el archivo de parametros
#necesario para ejecutar el cuESTARFM
#---------------------------------------------------------------------
rm(list=ls())
getwd()
#---------------------------------------------------------------------
library(stringr)
library(chron)
library(RCurl)
library(raster)
#--------------TRABAJO CON MODIS 6 9CG-----------------------------
MODIS6_url=readLines(file.choose())
MODIS6_B1=as.data.frame(grep("_b01_", MODIS6_url, value = TRUE),bycol=T)
names(MODIS6_B1)="B1"
MODIS6_B1=data.frame(lapply(MODIS6_B1, as.character), stringsAsFactors=FALSE)
MODIS6_B2=as.data.frame(grep("_b02_", MODIS6_url, value = TRUE),bycol=T)
names(MODIS6_B2)="B2"
MODIS6_B2=data.frame(lapply(MODIS6_B2, as.character), stringsAsFactors=FALSE)
names(MODIS6_B2)="B2"
MODIS6=cbind.data.frame(MODIS6_B1,MODIS6_B2)
names(MODIS6)=c("B1","B2")
rm(MODIS6_B1,MODIS6_B2)
#Extraigo el valor de fecha para cada MODIS
nrow(MODIS6)
for(i in 1:nrow(MODIS6)){
date=gsub(".*[_doy]([^.]+)[_].*", "\\1", MODIS6$B1[i])
MODIS6$YEAR[i]=as.numeric(substr(date, start = 1, stop = 4))
#--------------------
julian_day=as.numeric(substr(date, start = 5, stop = 7))  
origin.=as.numeric(c(month = 1, day = 1, year = MODIS6$YEAR[i]))
date=month.day.year(julian_day, origin.)
month=str_pad(date$month, 2, pad = "0")
day=str_pad(date$day, 2, pad = "0")
MODIS6$NOMBRE[i]=gsub(" ","",as.character(paste("M_",date$year,"_",month,"_",day,".tif")))
#--------------------
URL <- MODIS6$B1[i]
destfile=as.character(MODIS6$NOMBRE[i])
destpath="C:/Users/MC1988/Google Drive/PROFESIONALES-ACADEMICOS/AGRISAT/20180917_cuESTARFM/006_MODIS/MODIS_B1/"
download.file(url=URL,paste(destpath,destfile), method='curl')
#--------------------
URL <- MODIS6$B2[i]
destfile=as.character(MODIS6$NOMBRE[i])
destpath="C:/Users/MC1988/Google Drive/PROFESIONALES-ACADEMICOS/AGRISAT/20180917_cuESTARFM/006_MODIS/MODIS_B2/"
download.file(url=URL,paste(destpath,destfile), method='curl')

}
