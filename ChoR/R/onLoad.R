#' @title Loading function for ChoR.
# The JVM is initialized when loading the commonsMath package.
.onLoad <- function(libname, pkgname) {
  rJava::.jaddClassPath(system.file("java", package=pkgname))
  rJava::.jaddClassPath(dir(system.file("java", package=pkgname), full.names=TRUE))
}

