
################################
setwd("F:/cuESTARFM_archivo/")
rm(list=ls())
################################


NDVI_rellenar_NA=function(NDVI_folder="F:/cuESTARFM_archivo/"){

library(raster)
library(rgdal)
################
NDVI_list=list.files(NDVI_folder,pattern=".tif$",ignore.case=TRUE,full.names=TRUE)
################

for(i in 1:length(NDVI_list)){
ndvi=raster(NDVI_list[i])
############3###
for(j in 1:25){
  ndvi[ndvi > 0.975] <- NA
  ndvi[ndvi < -0.975] <- NA
  ndvi=focal(ndvi,w=matrix(1,3,3),fun=mean,na.rm=TRUE,NAonly=TRUE,pad=TRUE)
  #gc()
  }
filename=paste("NA_FILL_",basename(NDVI_list[i]),sep="")
writeRaster(ndvi,filename=filename,format="GTiff",overwrite=TRUE)
gc()
}
}