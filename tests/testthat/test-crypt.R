# test_that("Reading YAML works", {
    # cat(file('../testdata/test_passwd.yaml', 'r'))
# })
test_that('Decrypting a non-existing file fails', {
    expect_error(
        read_passwd('nonexisting-file', passphrase = 'x'),
        class = 'no_passwd'
    )
})


test_that('Decryption with a wrong passphrase fails', {
    expect_error(
        read_passwd('../testdata/passwd.yaml.gpg', passphrase = 'x'),
        class = 'decrypt_failed'
    )
})


test_that('Incorrect gpg binary is detected', {
    expect_error(
        read_passwd(
            '../testdata/passwd.yaml.gpg',
            passphrase = '1234',
            gpg_binary_name = 'xxx'
        ),
        class = 'no_gpg'
    )
})


test_that('Decryption works', {
    passwd_yaml <- read_passwd('../testdata/passwd.yaml.gpg', passphrase = '1234')
    expect_true(!is.null(passwd_yaml))
})


test_that('Decrypted passwd has the right format', {
    passwd_yaml <- read_passwd('../testdata/passwd.yaml.gpg', passphrase = '1234')
    expect_type(passwd_yaml, 'list')
    expect_equal(length(passwd_yaml), 10)
    expect_s3_class(passwd_yaml, 'passwd')
})
