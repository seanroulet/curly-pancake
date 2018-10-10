######## genero una funcion para generar el bounding box de un shapefile#
######## a posterior se exporta el bounding box como un shapefile########
#########################################################################
shapefile_input="C:/Users/MC1988/Google Drive/PROFESIONALES-ACADEMICOS/AGRISAT/20180809_102_RENDIMIENTO_LOTES_VID/001-shapefiles-terminados/2018_carinae_shapefile/carinae_2018_shapefile/carinae_2018_shapefile.shp"


shape2bb=function(shapefile_input){
#--------------------
library(sp)
library(rgdal)
library(stringr)
library(raster)
library(rgeos)
#---------------------  
shape_01=readOGR(shapefile_input) 
#nombre del archivo de salida 
shape_01_crs=crs(shape_01)
shape_01_name=str_replace_all(basename(shapefile_input),pattern=".shp",replacement="")
bb_name=paste(shape_01_name,"_bbox.shp",sep="")
#--------------------------------
shape_01_bb=as(raster::extent(shape_01), "SpatialPolygons")
proj4string(shape_01_bb) <- shape_01_crs
shape_01_bb=as(shape_01_bb, "SpatialPolygonsDataFrame")
#--------------------------------
writeOGR(shape_01_bb, dsn=paste(getwd(),"/",bb_name,sep=""),layer=bb_name, driver = "ESRI Shapefile",overwrite=T)
}
