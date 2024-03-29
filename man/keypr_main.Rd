% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/keypr.R
\name{keypr_main}
\alias{keypr_main}
\title{keypr Main Function}
\usage{
keypr_main(raw_cmd_args = NULL, passphrase = NULL)
}
\arguments{
\item{raw_cmd_args}{Command-line arguments as a string, as recognized by
\code{docopt}.  See \code{-h} usage screen.}

\item{passphrase}{A passphrase to the encrypted passwd.  Only for testing.}
}
\value{
An error code: 0 if no errors, > 0 otherwise.
}
\description{
Parse the arguments, read the passwd file, execute the given command (\code{get},
\code{add}, ...).
}
\examples{
\dontrun{
keypr_main(c('--password_length', '12', 'add', 'brin@gmail.com', 'google.com'))
}
}
