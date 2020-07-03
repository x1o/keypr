get_passwd_pname <- function(config_pname = NULL) {
    if (is.null(config_pname)) {
        config_home <- Sys.getenv('XDG_CONFIG_HOME')
        if (nchar(config_home) == 0) {
            home <- Sys.getenv('HOME')
            if (nchar(home) == 0) {
                die(
                    glue(
                        'Cannot locate a config file:',
                        ' both $XDG_CONFIG_HOME and $HOME are not set.'
                    ),
                    'no_config'
                )
            }
            config_home <- file.path(home, '.config')
        }
        keypr_config_dir <- file.path(config_home, 'keypr')
        dir.create(keypr_config_dir, recursive = TRUE, showWarnings = FALSE, mode = 0770)
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