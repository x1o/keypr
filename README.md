# keypr

<!-- badges: start -->
[![Codecov test coverage](https://codecov.io/gh/x1o/keypr/branch/master/graph/badge.svg)](https://codecov.io/gh/x1o/keypr?branch=master)
[![Travis build status](https://travis-ci.org/x1o/keypr.svg?branch=master)](https://travis-ci.org/x1o/keypr)
<!-- badges: end -->

`keypr` is a simple yet sufficient password manager designed to be used via CLI.  It operates on a YAML file (which stores credentials data) encrypted with [GnuPG](https://gnupg.org/).  The idea is that you can, in principle, maintain the password file yourself manually by encrypting / decrypting with `gpg`, `grep`'ping and/or modifying it with your favourite editor.  `keypr` just provides a convenient interface to all that.

## Raison d'etre

Pardon me -- a password manager in R?  But why?  Very simple: the author had a *sudden urge* to write it.

## Installation

You can install the released version of `keypr` from [CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("keypr")
```

or a developemnt version from github with:

```r
devtools::install_github('x1o/keypr')
```

After the installation, put the following bash script to a location in your PATH:

```sh
#!/usr/bin/env bash

umask 0002
Rscript -e 'keypr::keypr()' "$@"
```

or copy it from `<package_installation_directory>/bin/keypr`.


## Configuration

`keypr` is configured via a YAML configuration file, which is `$HOME/.config/keypr/keypr.yaml` by default.  In that file, specify the path to a `gpg`-encrypted password file, for example:

```yaml
passwd_pathname: "pathname/to/passwd.yaml.gpg"
```

or copy a sample config file from `<package_installation_directory>/config.yaml`.

## Examples

### Adding records

Add a google login-password pair (you will be asked for a password twice):

```sh
$ keypr --first_run add user1@gmail.com -p google_pass Google
```

And another one, but this time do not specify a password explictly -- it will be generated:

```sh
$ keypr add user2@gmail.com Google
```
```
→ Generated password: 7J1F4SFvIgn4
Service "Google" is already known (login “user1@gmail.com”). Add anyway? [Y/n] 
```

Add a github R personal access token (which does not require a login):

```sh
$ keypr add -p 85a964v1ajg0592kkjfl3985802d955k4 'Github R PAT'
```

### Querying

Get all google credentials:

```sh
$ keypr get goo
```
```
  service   login             password      
  Google    user1@gmail.com   google_pass   
  Google    user2@gmail.com   7J1F4SFvIgn4  
```

<!--
  Note on openssl vs gpg
    https://superuser.com/questions/981084/how-can-i-perform-pgp-encryption-and-decryption-method-using-openssl-commands
  gpg: only asymmetric
  rcrypt: only via an intermediate file
  https://github.com/Felor/ProdigyPass
-->
