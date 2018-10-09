### function to check the OS and deliver different values depending on the answer

ifPlatform<-function(ifWindows,ifUnix){

  #### if UNIX
  if(.Platform$OS.type == "unix") {
    myAnswer <- ifUnix

  ### if WINDOWS
  } else if(.Platform$OS.type == "windows"){
    myAnswer <- ifWindows
  
  ### if unknown.
  } else {
    myAnswer <- "Error  Unkown Platform"
  }
  return(myAnswer)
}

