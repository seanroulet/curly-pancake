##### Cleanup of folders after ESTARFM 

### not to be run yet.  needs to be tested.

Folders_to_clean<-c("MODIS/MODIS_B1","MODIS/MODIS_B2","extracted","LANDSAT/REPROJECTED",
                    "LANDSAT/CROPPED","LANDSAT/LANDSAT_R","LANDSAT/LANDSAT_NIR","tmp") # possibly "INDEX"

for( i in 1:length(Folders_to_clean)){
  message(paste("clean",Folders_to_clean[i]))
  files_to_remove<-list.files(file.path("Rasters",Folders_to_clean[i]), full.names=TRUE)
  message(files_to_remove)
  }
