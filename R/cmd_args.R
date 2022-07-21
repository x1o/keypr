parse_cmd_args <- function(raw_cmd_args = NULL) {
    KEYPR_VERSION <- packageVersion("keypr")

    doc <- glue("
keypr version {KEYPR_VERSION}

Usage:
  keypr [-v] [-c <pathname>] config
  keypr [-v] [-c <pathname>] get <service_name> [<name_filter>...]
  keypr [-v] [-c <pathname>] [-l <n>] [-s] add [-p <password>] <service_name>
  keypr [-v] [-c <pathname>] [-l <n>] [-s] add <login> [-p <password>] <service_name>
  keypr (-h | -V)

Verbs:
  config: show the config currently in use.
  get: looks up all stored login-password pairs for the given service
       (regexp ok).  Optional service <name_filter>s are applied to the result.
  add: adds a login-password pair to the passwd file for the specified
       service.  Empty logins ok.  See the `-p' option.

Options:
  -c <pathname>, --config_file=<pathname> Pathname of a keypr configuration file
                                        (.yaml).
  -l <n>, --password_length=<n>         Length of the generated password
                                        [default: 12].
  -s, --special_symbols                 Include special symbols in the generated
                                        password.
  -p <password>, --password=<password>  Password; if omitted, a random string of
                                        length <n> will be generated, shown to
                                        the user and used as a password.
  -v, --verbose                         Be verbose.
  -h, --help                            Show this screen.
  -V, --version                         Show version.
    ")

    if (is.null(raw_cmd_args)) {
        raw_cmd_args <- commandArgs(trailingOnly = TRUE)
        # R will insert --args after the first non-long form option
        raw_cmd_args <- raw_cmd_args[raw_cmd_args != '--args']
    }

    tryCatch({
            parsed_args <- docopt::docopt(
                doc,
                args = raw_cmd_args,
                help = TRUE,
                version = paste0(KEYPR_VERSION, "\n")
            )
        },
        simpleError = function(e) {
            cli_alert_danger('Invalid arguments.  See usage instructions below.')
            cat('\n', doc, '\n', sep = '')
            # e$message |>
            #     substr(2, nchar(.)) |>
            #     str_replace_all('\n  \n', '\n') |>
            #     cat('\n')
            rlang::abort(class = 'invalid_arguments')
        }
    )

    options(keypr.verbose = parsed_args$verbose)

    parsed_args
}