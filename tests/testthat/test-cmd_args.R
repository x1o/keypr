test_that("Empty arguments is an error", {
    expect_error(capture.output(parse_cmd_args('')), class = 'invalid_arguments')
})


test_that("Unknown verb is an error", {
    expect_error(capture.output(parse_cmd_args('UnKnOwN')), class = 'invalid_arguments')
})


test_that("get comand works", {
    args <- parse_cmd_args('-c dir/dummy get xyz')
    expect_true(args$get)
    expect_false(args$add)
    expect_equal(args$service_name, 'xyz')
    expect_equal(args$config_file, 'dir/dummy')
})


test_that("add command works", {
    args <- parse_cmd_args('add user -p qwerty xyz')
    expect_true(args$add)
    expect_false(args$get)
    expect_equal(args$login, 'user')
    expect_equal(args$password, 'qwerty')
    expect_equal(args$service_name, 'xyz')
})


test_that("add command works (empty password)", {
    args <- parse_cmd_args('-l 3 add user xyz')
    expect_equal(args$password_length, '3')
    expect_equal(args$login, 'user')
    expect_null(args$password)
    expect_equal(args$service_name, 'xyz')
})


test_that("add command works (empty login & password)", {
    args <- parse_cmd_args('add xyz')
    expect_null(args$password)
    expect_null(args$login)
    expect_equal(args$service_name, 'xyz')
})


test_that("add command works (empty login)", {
    args <- parse_cmd_args('add -p qwerty xyz')
    expect_equal(args$password, 'qwerty')
    expect_null(args$login)
    expect_equal(args$service_name, 'xyz')
})