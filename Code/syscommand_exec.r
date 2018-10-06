##########################################################
##### This function executes cuESTARFM within r.     #####
####  It takes cuESTARFM parameter file as input     #####
##########################################################

folder="C:/Users/MC1988/Google Drive/PROFESIONALES-ACADEMICOS/AGRISAT/20180917_cuESTARFM/007_testVM/PARAMS"
cu_path="/home/wtelectronica/cuESTARFM-master/Codes/cuESTARFM"

sys_command=function(folder="PARAMS",cu_path="/home/wtelectronica/cuESTARFM-master/Codes/cuESTARFM"){
  #leo los arhivos guardados, cada archivo es una ejecucion de cuESTARFM
  params_list=list.files(path=folder,pattern=".txt",full.names=TRUE)
  #genero un loop para ejecutar el programa
  #i=1
  for(i in 1:length(params_list)){
    #genero la sentencia de ejecucion del programa
    exec_sentence=paste(cu_path,params_list[i],sep=" ")
    #ejecuto el comando
    system(exec_sentence,wait=TRUE,show.output.on.console=TRUE)
    
    
  }
  
  
  
  
  
  
  
  
  
  
}

