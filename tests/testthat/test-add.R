test_that("gen_password works", {
    set.seed(1)
    expect_equal(gen_password(9), '4dMaH8wQn')
})


test_that("Adding records works", {
    passwd_yaml <- read_passwd(passwd_pathname = '../testdata/passwd.yaml.gpg', passphrase = '1234')
    passwd_yaml <-
        passwd_yaml %>%
        add_record(
            service_name = 'test_service',
            login = 'test_login',
            password = 'test_password'
        )
    expect_equal(
        passwd_yaml$test_service[[1]]$test_login,
        'test_password'
    )
})


test_that("Saving works", {
    passwd_pathname <- '../testdata/passwd.yaml.gpg'
    passphrase <- '1234'
    backup_pathname <- paste0(passwd_pathname, '.backup')
    passwd_hash <- as.character(tools::md5sum(passwd_pathname))
    passwd_yaml <- read_passwd(
        passwd_pathname = passwd_pathname,
        passphrase = passphrase
    )
    suppressWarnings(file.remove(backup_pathname))
    # backup created
    save_passwd(
        passwd_yaml,
        pname = passwd_pathname,
        passphrase = passphrase
    )
    expect_equal(passwd_hash, as.character(tools::md5sum(backup_pathname)))
    expect_identical(
        read_passwd(
            passwd_pathname = passwd_pathname,
            passphrase = passphrase
        ),
        passwd_yaml
    )
})
