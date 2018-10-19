#########function to filter outlyer NDVI pixels as #####
##### as given by cuESTARFM output  ################

NDVI_extremes=function(ndvi_folder="Rasters/INDEX/NDVI"){
  library(raster)
  library(rgdal)
  #Genero una lista de los rasters en la carpeta
  ndvi_list=list.files(path=ndvi_folder,pattern=".tif",full.names=TRUE)
  #Genero un loop para cada raster
  #i=1
  #for(i in 1:length(ndvi_list)){
    #abro el raster_i y su crs
    for(i in 1:length(ndvi_list)){
    ndvi_raster=raster(ndvi_list[i])
    ndvi_crs=crs(ndvi_raster)
    #Genero los limites inf y sup para NDVI
    ex_inf=-0.995
    ex_sup=0.995
    #Filtro el raster con esos limites
    ndvi_raster[ndvi_raster < ex_inf] <- ex_inf
    ndvi_raster[ndvi_raster > ex_sup] <- ex_sup
    #sobrescribo el archivo de NDVI en formato tif
    writeRaster(ndvi_raster,filename=ndvi_list[i],format="GTiff",overwrite=TRUE)
    }
  }
  



  
  
  
  
  
  
}