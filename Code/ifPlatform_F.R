### function to check the OS and deliver different values depending on the answer

ifPlatform<-function(ifWindows,ifUnix){
  if(.Platform$OS.type == "unix") {
    myAnswer <- ifUnix
  } else {
    myAnswer <- ifWindows
  }
  return(myAnswer)
}