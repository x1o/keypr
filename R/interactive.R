ask_add_confirmation <- function(passwd_yaml, service_name) {
    existing_logins <-
        passwd_yaml[[service_name]] %>%
        flatten() %>%
        names()
    existing_logins_str <- paste0(dQuote(existing_logins), collapse = ', ')
    s <- if (length(existing_logins) > 1) 's' else ''
    return(
        glue(
            'Service "{service_name}" is already known',
            ' (login{s} {existing_logins_str}). Add anyway?'
        ) %>%
        ask_yn()
    )
}


ask_yn <- function(question) {
    cat(paste0(question, ' [Y/n] '))
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

    return(user_response %in% c('', 'y', 'Y'))
}