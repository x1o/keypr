test_that("get finds domain registrar", {
    filtered_passwd <-
        read_passwd(passwd_pathname = '../testdata/passwd.yaml.gpg', passphrase = '1234') %>%
        as_tibble() %>%
        filter_passwd('domain')
    expect_equal(nrow(filtered_passwd), 1)
    expect_equal(filtered_passwd$login, '1234/abc-d (tech)')
})


test_that("get finds company wifi", {
    filtered_passwd <-
        read_passwd(passwd_pathname = '../testdata/passwd.yaml.gpg', passphrase = '1234') %>%
        as_tibble() %>%
        filter_passwd('Companyn', 'wifi')
    expect_equal(nrow(filtered_passwd), 1)
    expect_equal(filtered_passwd$login, '')
})


test_that("get returns info message for a service not present in passwd", {
    expect_message(
        keypr_main(
            c('-c', '../testdata/home/.config/keypr/config.yaml', 'get', 'non-present'),
            passphrase = '1234'
        ),
        NULL
    )
})
