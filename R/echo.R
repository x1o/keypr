echo_info <- function(...) {
    if (getOption('keypr.verbose') %||% FALSE)
        cli_alert_info(..., .envir = parent.frame())
}

echo_warn <- function(...) {
    cli_alert_warning(..., .envir = parent.frame())
}