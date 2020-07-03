die <- function(msg, class = 'error') {
    cli_alert_danger(msg)
    abort(msg, class = class)
}


ask_add_confirmation <- function(passwd_yaml, service_name) {
    existing_logins <-
        passwd_yaml[[service_name]] %>%
        flatten() %>%
        names()
    existing_logins_str <- paste0(dQuote(existing_logins), collapse = ', ')
    s <- if (length(existing_logins) > 1) 's' else ''
    cat(glue(
        'Service "{service_name}" is already known',
        ' (login{s} {existing_logins_str}). Add anyway? [Y/n] '
    ))
    tryCatch(
        {
            while (TRUE) {
                user_response <- readLines('stdin', n = 1, ok = FALSE)
                if (!user_response %in% c('', 'y', 'n', 'Y', 'N')) {
                    cat('\n', 'Y/n: ', sep = '')
                } else {
                    break
                }
            }
        },
        error = function(e) {
            cat('\n')
            die('Error reading user input.', 'bad_input')
        }
    )
    decision <- user_response %in% c('', 'y', 'Y')
    return(decision)
}