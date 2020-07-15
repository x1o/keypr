get_passwd_pname <- function(config_pname = NULL) {
    if (is.null(config_pname)) {
        keypr_config_dir <- rappdirs::user_config_dir(appname = 'keypr')
        # if (!dir.exists(keypr_config_dir)) {
            # create_config_dir <-
            #     glue(
            #         'keypr config directory {keypr_config_dir} does not exist.  Create one?'
            #     ) %>%
            #     ask_yn()
            # if (create_config_dir) {
            #     keypr_config_dir %>%
            #         dir.create(recursive = TRUE, showWarnings = FALSE, mode = 0770)
            # }
        # }
        config_pname <- file.path(keypr_config_dir, 'config.yaml')
    }

    if (!file.exists(config_pname)) {
        die(
            glue(
                'Config file "{config_pname}" does not exist.'
            ),
            'no_config'
        )
    }

    return(read_yaml(config_pname)$passwd_pathname)
}