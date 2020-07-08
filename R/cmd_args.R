parse_cmd_args <- function(cmd_args = NULL) {
    KEYPR_VERSION <- packageVersion("keypr")

    doc <- glue("
keypr version {KEYPR_VERSION}

Usage:
  keypr [-F] [-c <pathname>] get <service_name> [<name_filter>...]
  keypr [-F] [-c <pathname>] [-l <n>] add [<login>] [-p <password>] <service_name>
  keypr (-h | -v)

Verbs:
  get: looks up all stored login-password pairs for the given service
       (regexp ok).  Optional service <name_filter>s are applied to the result.
  add: adds a login-password pair to the passwd file for the specified
       service.  Empty logins ok.  See the `-p' option.

Options:
  -F, --first_run                       If the passwd file is missing, create a
                                        new one.
  -c <pathname>, --config_file=<pathname> Pathname of a keypr configuration file
                                        (.yaml).
  -l <n>, --password_length=<n>         Length of the generated password
                                        [default: 12].
  -p <password>, --password=<password>  Password; if omitted, a random string of
                                        length <n> will be generated, shown to
                                        the user and used as a password.
  -h, --help                            Show this screen.
  -v, --version                         Show version.
    ")

    if (is.null(cmd_args)) {
        cmd_args <- commandArgs(trailingOnly = TRUE)
    }

    tryCatch({
            parsed_args <- docopt::docopt(
                doc,
                args = cmd_args,
                help = TRUE,
                version = paste0(KEYPR_VERSION, "\n")
            )
        },
        simpleError = function(e) {
            cli_alert_danger('Invalid arguments.  See usage instructions below.')
            cat('\n', doc, '\n', sep = '')
            # e$message %>%
            #     substr(2, nchar(.)) %>%
            #     str_replace_all('\n  \n', '\n') %>%
            #     cat('\n')
            rlang::abort(class = 'invalid_arguments')
        }
    )

    return(parsed_args)
}