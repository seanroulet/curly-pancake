######## encuentro el centroide, ancho y alto del bbox de una finca######
######## esto se usara con la API de MODIS                       ########
#########################################################################

bb_input=file.choose()

bb2cg=function(bb_input){
  #--------------------
  library(sp)
  library(rgdal)
  library(stringr)
  library(raster)
  library(rgeos)
  library(geosphere)
  #-------------------
  bb_01=readOGR(bb_input) 
  bb_01_crs=crs(bb_01)
  #-------------------
  #el bbox tiene que estar como lat-lon
  bb_01=spTransform(bb_01,CRS("+init=epsg:4326"))
  bb_cg=gCentroid(bb_01)
  #calculo los extremos del bbox
  lon1=bb_01@bbox[1,1]
  lon2=bb_01@bbox[1,2]
  lat1=bb_01@bbox[2,1]
  lat2=bb_01@bbox[2,2]
  #-calculo con haversine las distancias
  alto=distm(c(lon1,lat1),c(lon1,lat2), fun = distHaversine)
  ancho=distm(c(lon1,lat1), c(lon2,lat1), fun = distHaversine)
  
  

  
  
  
  
}
