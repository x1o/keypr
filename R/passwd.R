read_passwd <- function(
        passwd_pathname,
        init_passwd = FALSE,
        passphrase = NULL
    ) {
    echo_info('Using "{passwd_pathname}" password file')
    passwd_yaml <-
        if (!file.exists(passwd_pathname)) {
            echo_warn('The password file "{passwd_pathname} does not exist')
            NULL
        } else {
            gpg_read_str(pname = passwd_pathname, passphrase = passphrase) |>
                paste0(collapse = '\n') |>
                yaml::yaml.load(handlers = list(int = function(x) as.character(x)))
        }
    passwd_yaml <- passwd_yaml %||% list()

    class(passwd_yaml) <- c('passwd', class(passwd_yaml))
    passwd_yaml
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
        passwd |>
        imap_dfr(~{
            .x |>
                flatten() |>
                imap_dfr(~{
                    list(
                        login = .y,
                        password = as.character(.x)
                    )
                }) |>
                bind_cols(list(service = .y)) |>
                select(service, everything())
        })

    class(passwd_df) <- c('passwd', class(passwd_df))
    passwd_df
}


filter_passwd <- function(passwd_df, service_name, name_filters = list()) {
    apply_name_filters <- function(df, name_filters) {
        reduce(
            name_filters,
            function(df, name_filter) {
                filter(
                    df,
                    str_detect(
                        service,
                        regex(name_filter, ignore_case = TRUE)
                    )
                )
            },
            .init = df
        )
    }
    passwd_df |>
        filter(str_detect(service, regex(service_name, ignore_case = TRUE))) |>
        apply_name_filters(name_filters)
}


gen_password <- function(len = 10, special = FALSE) {
    s <- c(letters, LETTERS, 0:9)
    if (special)
        s <- c(s, unlist(strsplit('!@#$%^&*()', '')))
    paste0(sample(s, len, replace = TRUE), collapse = '')
}


add_record <- function(passwd_yaml, service_name, login, password) {
    new_record <- list()
    new_record[[login]] <- password
    if (service_name %in% names(passwd_yaml)) {
        go_on <- ask_add_confirmation(
            passwd_yaml = passwd_yaml,
            service_name = service_name
        )
        if (!go_on) {
            abort(class = 'user_terminated')
        }
        n_recs <- length(passwd_yaml[[service_name]])
        passwd_yaml[[service_name]][[n_recs + 1]] <- new_record
    } else {
        passwd_yaml[[service_name]] <- list(new_record)
    }
    passwd_yaml
}


save_passwd <- function(passwd_yaml, pname, passphrase = NULL) {
    passwd_dir_created <- mkdir(dirname(pname), 'Password file')
    if (!passwd_dir_created) {
        abort('Cannot create passwd file directory', class = 'no_passwd')
    }
    tryCatch(
        file.copy(pname, paste0(pname, '.backup'), overwrite = TRUE),
        error = function(e) {
            die('Error making a passwd backup.', 'fs_error')
        }
    )
    tryCatch(
        passwd_yaml_str <-
            passwd_yaml |>
            yaml::as.yaml(indent = 2, indent.mapping.sequence = TRUE),
        error = function(e) {
            die('Error converting list YAML into the string.', 'yaml_error')
        }
    )
    passwd_yaml_str |> gpg_write_str(pname, passphrase = passphrase)
}
