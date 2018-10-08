#esta funcion toma como argumento un order_id de ESPA USGS #######
#y descarga los rasters de Earth Explorer                  #######
### Es necesario contar con Python instalado en la pc      #######
### Es necesario contar con espa bulk downloader instalado #######
### https://github.com/USGS-EROS/espa-bulk-downloader      #######
##################################################################

download_landsat=function(order_id="espa-pctowers@agrisat-sa.com.ar-0101807257547",exec_path="/home/wtelectronica/bulk-downloader/download_espa_order.py",dest="/Rasters/LANDSAT/"){
#-------------------------------------------
user="pctowers"
pass="torbis0330"
#-------ejecuto el comando para descargar los rasters USGS
download_rasters=paste("python ",exec_path," -o ",order_id, " -d ",dest," -u ",user," -p ",pass,sep="")
system(download_rasters)
#print(download_rasters)
}