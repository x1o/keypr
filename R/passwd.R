read_passwd <- function(passwd_pathname, passphrase = NULL, gpg_binary_name = 'gpg') {
    gpg_is_installed <- function(binary_name = 'gpg') {
        suppressWarnings(
            system2(binary_name, '--version', stdout = NULL, stderr = FALSE) == 0
        )
    }

    if (!file.exists(passwd_pathname)) {
        die(glue('passwd file "{passwd_pathname}" does not exist.'), 'no_passwd')
    }
    if (!gpg_is_installed(binary_name = gpg_binary_name)) {
        die('gpg is not installed.', 'no_gpg')
    }
    gpg_args <- c('--decrypt', passwd_pathname)
    if (!is.null(passphrase)) {
        gpg_args <- c(
            '--batch',
            '--passphrase', passphrase,
            gpg_args
        )
    }
    passwd_raw <-
        suppressWarnings(
            system2(
                gpg_binary_name,
                args = gpg_args,
                stdout = TRUE,
                stderr = FALSE
            )
        )
    if (!is.null(attributes(passwd_raw)$status)) {
        die(
            glue('Could not decrypt passwd file "{passwd_pathname}".'),
            'decrypt_failed'
        )
    }
    passwd_yaml <-
        passwd_raw %>%
        paste0(collapse = '\n') %>%
        yaml::yaml.load()
    class(passwd_yaml) <- c('passwd', class(passwd_yaml))
    return(passwd_yaml)
}


as_tibble.passwd <- function(passwd) {
    if ('tbl' %in% class(passwd)) {
        return(passwd)
    } else if (!'list' %in% class(passwd)) {
        die(
            glue(
                'Unknown classes ',
                paste0(dQuote(class(passwd)), collapse = ', ')
            ),
            'conversion_error'
        )
    }

    passwd_df <-
        passwd %>%
        imap_dfr(~{
            .x %>%
                flatten() %>%
                imap_dfr(~{
                    list(
                        login = .y,
                        password = as.character(.x)
                    )
                }) %>%
                bind_cols(list(service = .y)) %>%
                select(service, everything())
        })

    class(passwd_df) <- c('passwd', class(passwd_df))
    return(passwd_df)
}


filter_passwd <- function(passwd_df, service_name, name_filters = list()) {
    passwd_df %>%
        filter(str_detect(service, service_name)) %>%
        {
            reduce(
                name_filters,
                function(df, name_filter)
                    filter(df, str_detect(service, name_filter)),
                .init = .
            )
        }
}


gen_password <- function(len = 10) {
    c(letters, LETTERS, as.character(0:9)) %>%
        sample(len, replace = TRUE) %>%
        paste0(collapse = '')
}


add_record <- function(passwd_yaml, service_name, login, password) {
    new_record <- list()
    new_record[[login]] <- password
    passwd_yaml[[service_name]] <- list(new_record)
    return(passwd_yaml)
}


save_passwd <- function(passwd_yaml, pname, passphrase = NULL) {
    tryCatch(
        file.copy(pname, paste0(pname, '.backup'), overwrite = TRUE),
        error = function(e) {
            die('Error making a passwd backup.', 'fs_error')
        }
    )
    tryCatch(
        passwd_yaml_str <-
            passwd_yaml %>%
            yaml::as.yaml(indent = 2, indent.mapping.sequence = TRUE),
        error = function(e) {
            die('Error converting list YAML into the string.', 'yaml_error')
        }
    )
    gpg_args <- c()
    if (!is.null(passphrase)) {
        gpg_args <- c(gpg_args, '--batch', '--passphrase', passphrase)
    }
    gpg_args <- c(
        gpg_args,
        '--yes',
        '-c',
        '-o', pname
    )
    gpg_args_str <- paste0(gpg_args, collapse = ' ')
    tryCatch(
        passwd_yaml_str %>%
            cat(file = glue('|gpg {gpg_args_str}'), sep = '\n'),
        error = function(e) {
            die('Error converting list YAML into the string.', 'gpg_error')
        }
    )
}