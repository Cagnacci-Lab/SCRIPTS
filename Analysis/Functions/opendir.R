opendir <- function(dir = getwd()){
# Copied from http://stackoverflow.com/questions/12135732/how-to-open-working-directory-directly-from-r-console
    if (.Platform['OS.type'] == "windows"){
        shell.exec(dir)
    } else {
        system(paste(Sys.getenv("R_BROWSER"), dir))
    }
}
