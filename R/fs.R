mkdir <- function(dname, what) {
    if (!dir.exists(dname)) {
        create_config_dir <-
            glue(
                '{what} directory "{dname}" does not exist.  Create one?'
            ) |>
            ask_yn()
        if (create_config_dir) {
            dname |>
                dir.create(recursive = TRUE, showWarnings = FALSE, mode = '0770')
        } else {
            invisible(FALSE)
        }
    } else {
        invisible(TRUE)
    }
}
