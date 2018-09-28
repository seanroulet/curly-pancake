#---------------------------------------------------------------------
######################################################################
##Esta funcion renombra las bandas de landsat de acuerdo al formato###
##necesario para cuESTARFM----> L_YYYY_MM_DD.tif#### #################
######################################################################
#---------------------------------------------------------------------

setwd("C:/Users/MC1988/Google Drive/PROFESIONALES-ACADEMICOS/AGRISAT/20180917_cuESTARFM/")
LS_in_dir="C:/Users/MC1988/Google Drive/PROFESIONALES-ACADEMICOS/AGRISAT/20180917_cuESTARFM/"
LS_out_dir="C:/Users/MC1988/Google Drive/PROFESIONALES-ACADEMICOS/AGRISAT/20180917_cuESTARFM/LS_OUT/"
#---------------------------------------------------------------------
LANDSAT_cuESTARFM_rename<-function(LS_in_dir,LS_out_dir){
  #-------------------------------------------------------
  # Inputs
  ## LS_in_dir -> folder where LANDSAT files are located
  ## LS_out_dir-> folder where LANDSAT files to be saved           
  ##              
  #-------------------------------------------------------
  library(stringr)
  library(chron)
  library()
  #-------------------------------------------------------
  dir.create(paste(LS_out_dir,"LANDSAT_R",sep=""),showWarnings = FALSE)
  dir.create(paste(LS_out_dir,"LANDSAT_NIR",sep=""),showWarnings = FALSE)
  #-------------------------------------------------------
  landR_path=paste(LS_out_dir,"/LANDSAT_R/",sep="")
  landNIR_path=paste(LS_out_dir,"/LANDSAT_NIR/",sep="")
  #-------------------------------------------------------
  landR_files=list.files(LS_in_dir,pattern="_R.tif")
  landNIR_files=list.files(LS_in_dir,pattern="_NIR.tif")
  #-------------------------------------------------------
  for(i in 1:length(landR_files)){
  landR_name=landR_files[i]
  ano=substr(landR_name,18,21)
  mes=substr(landR_name,22,23)
  dia=substr(landR_name,24,25)
  landR_out=paste(landR_path,"L_",ano,"_",mes,"_",dia,".tif",sep="")
  file.copy(landR_name,landR_out)
  }
  for(i in 1:length(landNIR_files)){
  landNIR_name=landNIR_files[i]
  ano=substr(landNIR_name,18,21)
  mes=substr(landNIR_name,22,23)
  dia=substr(landNIR_name,24,25)
  landNIR_out=paste(landNIR_path,"L_",ano,"_",mes,"_",dia,".tif",sep="")
  file.copy(landNIR_name,landNIR_out)
  }
}
  #-------------------------------------------------------

  