#---------------------------------------------------------------------
######################################################################
##Esta funcion renombra las bandas de landsat de acuerdo al formato###
##necesario para cuESTARFM----> L_YYYY_MM_DD.tif#### #################
######################################################################
#---------------------------------------------------------------------
#---------------------------------------------------------------------
LANDSAT_cuESTARFM_rename<-function(LS_in_dir="Rasters/LANDSAT"){
  #-------------------------------------------------------
  # Inputs
  ## LS_in_dir -> folder where LANDSAT files are located
  ## LS_out_dir-> folder where LANDSAT files to be saved           
  ##              
  #-------------------------------------------------------
  library(stringr)
  library(chron)
  #-------------------------------------------------------
  #dir.create(paste(LS_out_dir,"LANDSAT_R",sep=""),showWarnings = FALSE)
  #dir.create(paste(LS_out_dir,"LANDSAT_NIR",sep=""),showWarnings = FALSE)
  #-------------------------------------------------------
  landR_path="Rasters/LANDSAT/LANDSAT_R/"
  landNIR_path="Rasters/LANDSAT/LANDSAT_NIR/"
  #-------------------------------------------------------
  landR_files=list.files(LS_in_dir,pattern="_R.tif")
  landNIR_files=list.files(LS_in_dir,pattern="_NIR.tif")
  #-------------------------------------------------------
  for(i in 1:length(landR_files)){
  landR_name=landR_files[i]
  ano=substr(landR_name,18,21)
  mes=substr(landR_name,22,23)
  dia=substr(landR_name,24,25)
  landR_out=paste(landR_path,"L_",ano,"_",mes,"_",dia,"_R.tif",sep="")
  file.rename(landR_name,landR_out)
  }
  for(i in 1:length(landNIR_files)){
  landNIR_name=landNIR_files[i]
  ano=substr(landNIR_name,18,21)
  mes=substr(landNIR_name,22,23)
  dia=substr(landNIR_name,24,25)
  landNIR_out=paste(landNIR_path,"L_",ano,"_",mes,"_",dia,"_NIR.tif",sep="")
  file.rename(landNIR_name,landNIR_out)
  }
}
  #-------------------------------------------------------

  