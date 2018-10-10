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
  #busco vertices del bbox
  lon1=bb_01@bbox[1,1]
  lon2=bb_01@bbox[1,2]
  lat1=bb_01@bbox[2,1]
  lat2=bb_01@bbox[2,2]
  #calculo el alto y el ancho del bbox
  alto=distm(c(lon1,lat1),c(lon1,lat2),fun=distHaversine)/1000
  ancho=distm(c(lon1,lat1),c(lon2,lat1),fun=distHaversine)/1000
  #calculo el centroide del bbox
  bb_cg=gCentroid(bb_01)
}
  

#genero un get para traer el recorte en base al bbcx
get_rquest=paste("https://modis.ornl.gov/rst/api/v1/MOD11A2/subset?latitude=",bb_cg@coords[2],"&longitude=",bb_cg@coords[1],"&band=LST_Day_1km&startDate=A2001001&endDate=A2001001&kmAboveBelow=",alto,"&kmLeftRight=",ancho,sep=""), add_headers(Accept = "text/csv"))
