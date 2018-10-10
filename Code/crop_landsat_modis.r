#### Este script a implementar en una funcion
#### hace lo siguiente
#### paso 1: lee un raster landsat y su crs
#### paso 2: lee un shapefile y su crs
#### paso 3: reprojecta el shapefile al crs landsat
#### paso 4: recorta todos los landsat de una carpeta
#### paso 5: recorta todos los MODIS de una carpeta
#### paso 6: todos los archivos se guardan con el mismo nombre
#---------------------------------------------------------------
library(raster)
library(rgdal)
library(gdalUtils)
library(tools)
library(rgeos)
library(sp)
library(stringr)
#---------------------------------------------------------------
#PASO 1
ls_raster=raster(file.choose())
ls_crs=crs(ls_raster)
#PASO 2
shape=readOGR(file.choose())
shape_crs=crs(shape)
#PASO 3
shape=spTransform(shape, ls_crs)
#----------------------------------------------------------------
MODIS_folder="C:/Users/MC1988/Desktop/Rasters/MODIS/REPROJECTED"
LANDSAT_folder="C:/Users/MC1988/Desktop/Rasters/LANDSAT/CROPPED"
MODIS_list=list.files(MODIS_folder,pattern=".tif",full.names =TRUE,ignore.case = TRUE)
LS_list=list.files(LANDSAT_folder,pattern=".tif",full.names =TRUE,ignore.case = TRUE)

for(i in 1:length(LS_list)){
  raster=raster(LS_list[i])
  # Getting the spatial extent of the shapefile
  e=extent(shape)
  # Cropping the raster to the shapefile spatial extent
  ras_crop=crop(raster, e,snap="near")
  name=paste(getwd(),"/crop_",basename(LS_list[i]),sep="")
  writeRaster(ras_crop,filename=name,format="GTiff",overwrite=T)
}


#PASO 5
for(i in 1:length(MODIS_list)){
  raster=raster(MODIS_list[i])
  # Getting the spatial extent of the shapefile
  e=extent(shape)
  # Cropping the raster to the shapefile spatial extent
  ras_crop=crop(raster, e,snap="near")
  name=paste(getwd(),"/crop_",basename(MODIS_list[i]),sep="")
  writeRaster(ras_crop,filename=name,format="GTiff",overwrite=T)
}

