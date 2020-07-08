gpg_read_str <- function(pname, passphrase = NULL) {
    gpg_is_installed <- function() {
        suppressWarnings(
            system2('gpg', '--version', stdout = NULL, stderr = FALSE) == 0
        )
    }

    if (!gpg_is_installed()) {
        die('gpg is not installed.', 'no_gpg')
    }

    gpg_args <- c('--decrypt', pname)
    if (!is.null(passphrase)) {
        gpg_args <- c(
            '--batch',
            '--passphrase', passphrase,
            gpg_args
        )
    }
    str <-
        suppressWarnings(
            system2(
                'gpg',
                args = gpg_args,
                stdout = TRUE,
                stderr = FALSE
            )
        )
    if (!is.null(attributes(str)$status)) {
        die(
            glue('Could not decrypt file "{pname}".'),
            'gpg_error'
        )
    }

    return(str)
}


gpg_write_str <- function(str, pname, passphrase = NULL) {
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
        str %>%
            cat(file = glue('|gpg {gpg_args_str}'), sep = '\n'),
        error = function(e) {
            die('Error encrypting {pname}.', 'gpg_error')
        }
    )
}