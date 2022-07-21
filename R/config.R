get_config_pname <- function(config_pname = NULL) {
    if (is.null(config_pname)) {
        # The config pathname has not been provided by the user; assume it is in
        # the default location
        config_pname <- file.path(
            rappdirs::user_config_dir(appname = 'keypr'),
            'config.yaml'
        )
    }
    echo_info('Using "{config_pname}" config file')
    config_pname
}


get_passwd_pname <- function(config_pname) {
    if (!file.exists(config_pname)) {
        # If the config file does not exist, create it with a default password
        # file path
        keypr_config_dir <- dirname(config_pname)
        config_dir_exists <- mkdir(keypr_config_dir, what = 'keypr config')
        if (!config_dir_exists) {
            abort('Not creating config directory', class = 'no_config')
        }
        passwd_pname <- file.path(
            rappdirs::user_data_dir(appname = 'keypr'),
            'passwd.yaml.gpg'
        )
        echo_warn('Will be using "{passwd_pname}" password file.  Change keypr config if unhappy')
        list(passwd_pathname = passwd_pname) |>
            yaml::as.yaml() |>
            writeLines(config_pname)
        # die(
        #     glue(
        #         'Config file "{config_pname}" does not exist.'
        #     ),
        #     'no_config'
        # )
    }

    read_yaml(config_pname)$passwd_pathname
}