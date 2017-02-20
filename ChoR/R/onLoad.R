#' @title Loading function for ChoR: initialize the JVM
.onLoad <- function(libname, pkgname) {
  rJava::.jpackage(pkgname, lib.loc = libname)
}

