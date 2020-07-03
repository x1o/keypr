.onLoad <- function(libname, pkgname) {
    if (getRversion() >= "2.15.1")
        utils::globalVariables(c("service", "."))
}