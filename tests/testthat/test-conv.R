test_that("as_tibble works", {
    passwd_yaml <- read_passwd('../testdata/passwd.yaml.gpg', passphrase = '1234')
    passwd_df <- as_tibble(passwd_yaml)
    expect_s3_class(passwd_df, 'passwd')
    expect_s3_class(passwd_df, 'tbl')
    passwd_df <- as_tibble(passwd_df)
    expect_s3_class(passwd_df, 'passwd')
    expect_s3_class(passwd_df, 'tbl')
    class(passwd_df) <- c('XXX', 'passwd')
    expect_error(
        as_tibble(passwd_df),
        paste0('Unknown classes ', paste0(dQuote(c('XXX', 'passwd')), collapse = ', ')),
        class = 'conversion_error'
    )
})

test_that("as_tibble produces correct tibble", {
    passwd_df <-
        '../testdata/passwd.yaml.gpg' %>%
        read_passwd(passphrase = '1234') %>%
        as_tibble()
    expect_equal(nrow(passwd_df), 11)
    expect_equal(colnames(passwd_df), c('service', 'login', 'password'))
    expect_equal(passwd_df$login[8], '')
    expect_equal(passwd_df$service[11], '+1 123 456 7890')
})