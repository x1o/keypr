die <- function(msg, class = 'error') {
    cli_alert_danger(msg)
    abort(msg, class = class)
}