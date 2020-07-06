#' keypr main() Wrapper
#'
#' A try-catch wrapper around `keypr_main()`.
#'
#' @param ... Arguments to `keypr_main()`.
#'
#' @return Quits R with an error code: 0 if no errors, > 0 otherwise.
#'
#' @seealso [keypr_main()].
#'
#' @export
keypr <- function(...) {
    error_code <- 1
    tryCatch(
        {
            error_code <- keypr_main(...)
        },
        invalid_arguments = function(e) invisible(NULL),
        no_config = function(e) invisible(NULL),
        no_passwd = function(e) invisible(NULL),
        no_gpg = function(e) invisible(NULL),
        decrypt_failed = function(e) invisible(NULL),
        conversion_error = function(e) invisible(NULL),
        bad_input = function(e) invisible(NULL),
        user_terminated = function(e) invisible(NULL),
        fs_error = function(e) invisible(NULL),
        gpg_error = function(e) invisible(NULL),
        # "error" is the default class for all non-caught exceptions
        error = function(e) {
            e
            # cli_alert_danger(e$message)
            # if (is.null(getOption('keypr.debug')) || getOption('keypr.debug')) {
                # print(e)
                # quit(status = 1)
            # }
        }
    )
    quit(status = error_code)
}


#' keypr Main Function
#'
#' Parse the arguments, read the passwd file, execute the given command (`get`,
#' `add`, ...).
#'
#' @param cmd_args Command-line arguments as recognized by `docopt`.  See `-h`
#'   usage screen.
#' @param passphrase A passphrase to the encrypted passwd.  Only for testing.
#'
#' @return An error code: 0 if no errors, > 0 otherwise.
#' @export
#'
#' @examples
#' \dontrun{
#' keypr_main(c('--password_length', '12', 'add', 'brin@gmail.com', 'google.com'))
#' }
keypr_main <- function(cmd_args = NULL, passphrase = NULL) {
    parsed_args <- parse_cmd_args(cmd_args = cmd_args)
    passwd_pathname <- get_passwd_pname(config_pname = parsed_args$config_file)
    passwd_yaml <- read_passwd(passwd_pathname = passwd_pathname, passphrase = passphrase)

    if (parsed_args$get) {
        passwd_yaml %>%
            as_tibble() %>%
            filter_passwd(
                service_name = parsed_args$service_name,
                name_filters = parsed_args$name_filter
            ) %>%
            pretty_print()
    } else if (parsed_args$add) {
        password <- parsed_args$password
        if (is.null(password)) {
            password <- gen_password(len = parsed_args$password_length)
        }
        login <- parsed_args$login
        if (is.null(login)) {
            login <- ''
        }
        if (parsed_args$service_name %in% names(passwd_yaml)) {
            go_on <- ask_add_confirmation(
                passwd_yaml = passwd_yaml,
                service_name = parsed_args$service_name
            )
            if (!go_on) {
                abort(class = 'user_terminated')
            }
        }
        passwd_yaml %>%
            add_record(
                service_name = parsed_args$service_name,
                login = login,
                password = password
            ) %>%
            save_passwd(
                pname = passwd_pathname,
                passphrase = passphrase
            )
    } else {
        die('Unknown verb.', class = 'invalid_arguments')
    }

    return(0)
}