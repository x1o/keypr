test_that("config$passwd_pathname can be read using $XDG_CONFIG_HOME", {
    old <- Sys.getenv('XDG_CONFIG_HOME')
    Sys.setenv(XDG_CONFIG_HOME = '../testdata/home/.config')
    file.rename('../testdata/home/_config', '../testdata/home/.config')
    expect_type(
        get_passwd_pname(config_pname = NULL),
        'character'
    )
    Sys.setenv(XDG_CONFIG_HOME = old)
    file.rename('../testdata/home/.config', '../testdata/home/_config')
})


test_that("config$passwd_pathname can be read using $HOME", {
    old <- Sys.getenv('HOME')
    Sys.setenv(HOME = '../testdata/home')
    file.rename('../testdata/home/_config', '../testdata/home/.config')
    expect_type(
        get_passwd_pname(config_pname = NULL),
        'character'
    )
    Sys.setenv(HOME = old)
    file.rename('../testdata/home/.config', '../testdata/home/_config')
})


test_that("config$passwd_pathname cannot be read from a wrong $HOME", {
    old <- Sys.getenv('HOME')
    Sys.setenv(HOME = '/nonexisting_path/home')
    expect_error(
        get_passwd_pname(config_pname = NULL),
        class = 'no_config'
    )
    Sys.setenv(HOME = old)
})