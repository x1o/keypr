gpg_read_str <- function(pname, passphrase = NULL) {
    gpg_is_installed <- function() {
        suppressWarnings(
            system2('gpg', '--version', stdout = NULL, stderr = FALSE) == 0
        )
    }

    if (!gpg_is_installed()) {
        die('gpg is not installed.', 'no_gpg')
    }

    gpg_args <- c('--decrypt', shQuote(path.expand(pname)))
    if (!is.null(passphrase)) {
        gpg_args <- c(
            '--batch',
            '--passphrase', passphrase,
            '--pinentry-mode', 'loopback',
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

    str
}


gpg_write_str <- function(str, pname, passphrase = NULL) {
    gpg_args <- c()
    if (!is.null(passphrase)) {
        gpg_args <- c(
            gpg_args,
            '--batch',
            '--passphrase', passphrase,
            '--pinentry-mode', 'loopback'
        )
    }
    gpg_args <- c(
        gpg_args,
        '--yes',
        '--passphrase-repeat', 0,
        # '--pinentry-mode', 'loopback',
        '--symmetric',
        '--output', shQuote(path.expand(pname))
    )
    gpg_args_str <- paste0(gpg_args, collapse = ' ')
    tryCatch(
        str |>
            # cat(file = pipe(glue('gpg {gpg_args_str}')), sep = '\n'),
            # writeLines(sep = '\n', pipe(glue('gpg {gpg_args_str}'))),
            cat(file = glue('|gpg {gpg_args_str}'), sep = '\n'),
        error = function(e) {
            die('Error encrypting "{path.expand(pname)}".', 'gpg_error')
        }
    )
}