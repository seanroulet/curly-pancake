
######## ARGUMENTOS DE PRUEBA PARA USAR CON LA FUNCION
MODIS_folder="X:/Google Drive/PROFESIONALES-ACADEMICOS/AGRISAT/20180917_cuESTARFM/006_MODIS/MODIS_R"
LANDSAT_folder="X:/Google Drive/PROFESIONALES-ACADEMICOS/AGRISAT/20180917_cuESTARFM/004_LANDSAT/LANDS_R"
cuESTARFM_parameters="C:/Users/MC1988/Google Drive/PROFESIONALES-ACADEMICOS/AGRISAT/20180917_cuESTARFM/002_cuESTARFM parameters example/parameters_example.txt"
#############################################
#############################################



#--------------------------------------------
cuESTARFM_parameters_file<-function(MODIS_folder,LANDSAT_folder,cuESTARFM_parameters){
#se procesa de a un par de bandas MODIS-LANDSAT por ejecucion Y se genera el archivo para ejecutar cuESTARFM
  library(stringr)
  library(chron)
  library(raster)
  library(data.table)
#--------------------------------------------
#creo una carpeta donde guardar los archivos de parametros
dir.create("./PARAMS",showWarnings = FALSE)
param_path=paste(getwd(),"/PARAMS/",sep="")
#creo una carpeta donde se guardaran los landsats sinteticos
dir.create("./SINT_LS",showWarnings = FALSE)
SINT_LS_path=paste(getwd(),"/SINT_LS/",sep="")
#-------------------------------------------- 
#leo linea por linea el ejemplo de los parametros del programa
cuESTARFM_parameters=readLines(cuESTARFM_parameters)
#--------------------------------------------
MODIS_IN=gsub("/ ","/",list.files(MODIS_folder,pattern="\\.tif$",full.names = T))
LANDSAT_IN=gsub("/ ","/",list.files(LANDSAT_folder,pattern="\\.tif$",full.names = T))
#--------------------------------------------
MODIS_IN=as.data.frame(MODIS_IN,byrow=TRUE)
names(MODIS_IN)="MODIS"
LANDSAT_IN=as.data.frame(LANDSAT_IN,byrow=TRUE)
names(LANDSAT_IN)="LANDSAT"
#----------agrego fecha a los DF MODIS Y LANDSAT-------

for(i in 1:nrow(MODIS_IN)){
  date=as.numeric(str_replace_all(gsub(".*M_|.tif.*", "", MODIS_IN$MODIS[i]),pattern="_",replacement=""))
  MODIS_IN$DATE[i]=date
}

for(j in 1:nrow(LANDSAT_IN)){
  date=as.numeric(str_replace_all(gsub(".*L_|.tif.*", "", LANDSAT_IN$LANDSAT[j]),pattern="_",replacement=""))
  LANDSAT_IN$DATE[j]=date
}

#-Genero un DF con los pares MODIS-LANDSAT de referencia
MODISLANDSAT_REF=merge(MODIS_IN,LANDSAT_IN,by="DATE")
#Genero un DF con los MODIS de las fechas a interpolar
MODIS_PRED=MODIS_IN[!(MODIS_IN$DATE %in% MODISLANDSAT_REF$DATE),]
#Elimino los DF que ya no utilizo
rm(MODIS_IN,LANDSAT_IN)
#######################################################################################
#Construyp el archivo de parametros cuESTARFM para cada par MODIS-LANDSAT de referencia
#i=1
for(i in 1:(nrow(MODISLANDSAT_REF)-1)){
  #filtro los MODIS que caen entre el par MODIS-LANDSAT
  #--------------------------------------------------
  MODIS_CAPTURED=MODIS_PRED[(MODIS_PRED$DATE > MODISLANDSAT_REF$DATE[i] & MODIS_PRED$DATE < MODISLANDSAT_REF$DATE[i+1]),]
  #genero una lista con los nombres a incluir
  MODIS_names=paste(MODIS_CAPTURED$MODIS, collapse = " ")
  #rm(MODIS_CAPTURED)
  #--------------------------------------------------
  #agrego los nombres a usar para generar los landsat sinteticos
  MODIS_CAPTURED$SINT_LANDSAT=paste(SINT_LS_path,"SI_LS_",gsub(".*M_|$.*","",MODIS_CAPTURED$MODIS[i]),sep="")
  SINT_LS_names= paste(MODIS_CAPTURED$SINT_LANDSAT, collapse = " ")
  #Modifico el archivo de parametros
  #modifico las filas del archivo de texto que se actualizan para cada corrida del programa
  cuESTARFM_parameters[8]=paste("  IN_PAIR_MODIS_FNAME =",MODISLANDSAT_REF$MODIS[i],MODISLANDSAT_REF$MODIS[i+1])
  cuESTARFM_parameters[12]=paste(" IN_PAIR_LANDSAT_FNAME =",MODISLANDSAT_REF$LANDSAT[i],MODISLANDSAT_REF$LANDSAT[i+1])
  cuESTARFM_parameters[17]=paste(" IN_PDAY_MODIS_FNAME =",MODIS_names)
  cuESTARFM_parameters[22]=paste(" OUT_PDAY_LANDSAT_FNAME =",SINT_LS_names)
  #creo el nombre del arhivo de salida
  txt_name=paste(param_path,"PARAM_",i,".txt",sep="")
  #exporto como txt el archivo de parametros con los datos
  writeLines(cuESTARFM_parameters,txt_name)
  #############################################################################
  #############      FIN                    ###################################
  #############################################################################
}}

