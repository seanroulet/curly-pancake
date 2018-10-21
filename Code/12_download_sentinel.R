download_sentinel=function(input_txt="/home/martin-r/Rasters/sentinel_test.txt",output_folder="Rasters/after_cuESTARFM"){
  ################
  library(stringr)
  library(utils)
  ################
  #-------------------------------------------
  usr="mlcastellan"
  pass="Agrisat_esacopernicus"
  ################
  #Leo de un archivo txr la lista de rasters a descargar y genero una lista.
  SENTINEL_list=readLines(input_txt)
  ################
  for(i in 1:length(SENTINEL_list)){
    #-------------------------------------------
    uri=SENTINEL_list[i]
    #uri_1=strsplit(uri, "\\$")[[1]][1]
    #uri_2=strsplit(uri, "\\$")[[1]][2]
    #uri_3="\\$"
    #dwn_uri=paste(uri_1,uri_3,uri_2,sep="")
    #dwn_uri=str_replace_all(dwn_uri,pattern="\\\\","\\")
    #-------------------------------------------
    extra_argum=paste(" --no-check-certificate --continue --user=",usr," --password=",pass," ",sep="")
    #-------------------------------------------
    filename=paste("SENTINEL_",i,sep="")
    filepath<-file.path(output_folder,filename)
    #-------------------------------------------
    download.file(url=uri ,destfile=filepath, method="wget", quiet = FALSE,cacheOK = TRUE,extra=extra_argum)
    new_filename<-str_replace(paste((unzip(filepath, list=TRUE))[[1]][1],".zip",sep=""),pattern=".SAFE/.zip",replacement=".zip")
    new_filepath<-file.path(output_folder,new_filename)
    #-------------------------------------------
    file.rename(filepath,new_filepath)
    #command=paste("wget -O ",filepath," --no-check-certificate --continue --user=",usr," --password=",pass," ",dwn_uri,sep="")
    #system(command,wait=TRUE,show.output.on.console=TRUE)

    }
  }




