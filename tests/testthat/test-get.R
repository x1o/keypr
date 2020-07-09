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
            c('-c', '../testdata/home/_config/keypr/config.yaml', 'get', 'non-present'),
            passphrase = '1234'
        ),
        NULL
    )
})

test_that('An empty passwd is created on the first run', {
    passwd_first_run_pname <- '../testdata/passwd-empty-first_run.yaml.gpg'
    assertthat::assert_that(!file.exists(passwd_first_run_pname))
    keypr_main(
        c(
            '--first_run',
            '-c', '../testdata/home/_config/keypr/config-empty-first_run.yaml',
            'get',
            'anything'
        ),
        passphrase = '1234'
    )
    expect_true(file.exists(passwd_first_run_pname))
    file.remove(passwd_first_run_pname)
})


test_that('get on an empty passwd results in a notice', {
    passwd_first_run_pname <- '../testdata/passwd-empty.yaml.gpg'
    expect_message(
        keypr_main(
            c(
                '-c', '../testdata/home/_config/keypr/config-empty.yaml',
                'get',
                'anything'
            ),
            passphrase = '1234'
        ),
        regexp = 'empty'
    )
})
