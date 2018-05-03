#' @title Loading function for ChoR.
# The JVM is initialized when loading the commonsMath package.
.onLoad <- function(libname, pkgname) {

  rJava::.jaddClassPath(dir(system.file("java", package=pkgname), full.names=TRUE))

  jv <- .jcall("java/lang/System", "S", "getProperty", "java.runtime.version")
  if(substr(jv, 1L, 2L) == "1.") {
    jvn <- as.numeric(paste0(strsplit(jv, "[.]")[[1L]][1:2], collapse = "."))
    if(jvn < 1.8) stop("Java >= 8 is needed for this package but not available")
  }

}

