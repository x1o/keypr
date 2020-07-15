pretty_print <- function(x, ...) {
    UseMethod("pretty_print", x)
}

pretty_print.passwd <- function(passwd) {
    if (!'tbl' %in% class(passwd)) {
        passwd <- as_tibble(passwd)
    }
    if (nrow(passwd) == 0) {
        cli_text('No records found.')
    } else {
        passwd %>%
            hux() %>%
            set_bold(1, everywhere) %>%
            set_position('left') %>%
            print_screen(colnames = FALSE, max_width = Inf)
        cat('\n')
    }
}

