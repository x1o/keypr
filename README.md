# keypr

<!-- badges: start -->
[![Codecov test coverage](https://codecov.io/gh/x1o/keypr/branch/master/graph/badge.svg)](https://codecov.io/gh/x1o/keypr?branch=master)
[![Travis build status](https://travis-ci.org/x1o/keypr.svg?branch=master)](https://travis-ci.org/x1o/keypr)
![pkgdown](https://github.com/x1o/keypr/workflows/pkgdown/badge.svg?branch=master)
<!-- badges: end -->

`keypr` is a simple yet sufficient password manager designed to be used via CLI.  It operates on a YAML file (which stores credentials data) encrypted with [GnuPG](https://gnupg.org/).  The idea is that you can, in principle, maintain the password file yourself manually by encrypting / decrypting with `gpg`, `grep`'ping and/or modifying it with your favourite editor.  `keypr` just provides a convenient interface to all that.

## Raison d'etre

Pardon me -- a password manager in R?  But why?  Very simple: the author had a *sudden urge* to write it.

## Installation

Make sure [GnuPG](https://gnupg.org/) is installed (`gnupg` in dpkg-based distros).

In addition, on MacOS install `pinentry-mac` - a utility for passphrase entry.

You can install the latest version of `keypr` from github with:

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

GnuPG agent (`~/.gnupg/gpg-agent.conf`):

```
min-passphrase-len 0
min-passphrase-nonalpha 0
```

In addition, on MacOS, add 

```
pinentry-program /usr/local/bin/pinentry-mac
```

`keypr` is configured via a YAML configuration file `keypr.yaml`, which is by 
default stored in the user config directory; call

```r
rappdirs::user_config_dir(appname = 'keypr')
```

to find the exact location on your system.

In that file, specify the path to a `gpg`-encrypted password file, for example:

```yaml
passwd_pathname: "~/passwd.yaml.gpg"
```

If the config file does not exist, it will be created with `passwd_pathname`
equal to `passwd.yaml.gpg` in the user default data dir; call

```r
rappdirs::user_data_dir(appname = 'keypr')
```

to find the value on your system.

## Examples

### Adding records

Add a google login-password pair:

```sh
$ keypr add user1@gmail.com -p google_pass Google
```

And another one, but this time do not specify a password explictly -- it will be
generated (use `-s` to create a stronger password containing special symbols):

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

```sh
$ keypr get gith
```
```
  service        login   password
  Github R PAT           85a964v1ajg0592kkjfl3985802d955k4
```

The resulting passwd file would be

```sh
$ keypr config
```

```yaml
passwd_pathname: ~/Library/Application Support/keypr/passwd.yaml.gpg
```

```sh
$ gpg -d ~/Library/Application\ Support/keypr/passwd.yaml.gpg
```

```
gpg: AES256.CFB encrypted data
gpg: encrypted with 1 passphrase
Google:
  - user1@gmail.com: google_pass
  - user2@gmail.com: 7J1F4SFvIgn4
Github R PAT:
  - '': 85a964v1ajg0592kkjfl3985802d955k4
```

<!--
  Note on openssl vs gpg
    https://superuser.com/questions/981084/how-can-i-perform-pgp-encryption-and-decryption-method-using-openssl-commands
  gpg: only asymmetric
  rcrypt: only via an intermediate file
  https://github.com/Felor/ProdigyPass
-->
