library(testthat)

source(file.path(getwd(), "R", "MonthLabelFormatter.R"))

formatter <- MonthLabelFormatter$new()

test_that("AllLabels returns twelve items", {
  labels <- formatter$AllLabels()
  expect_equal(length(labels), 12)
})

test_that("AllLabels are unique", {
  labels <- formatter$AllLabels()
  expect_equal(length(unique(labels)), 12)
})

test_that("AllLabels match expected values", {
  expected <- c(
    "J\u00b9", "F", "M\u00b9", "A\u00b9", "M\u00b2", "J\u00b2",
    "J\u00b3", "A\u00b2", "S", "O", "N", "D"
  )
  expect_equal(formatter$AllLabels(), expected)
})

test_that("Unique months have no superscript", {
  for (month in c(2, 9, 10, 11, 12)) {
    label <- formatter$Format(month)
    expect_equal(nchar(label), 1, info = paste("Month", month, "should be a single character"))
  }
})

test_that("Ambiguous months have superscript", {
  for (month in c(1, 3, 4, 5, 6, 7, 8)) {
    label <- formatter$Format(month)
    expect_equal(nchar(label), 2, info = paste("Month", month, "should have a superscript"))
  }
})

test_that("January", { expect_equal(formatter$Format(1), "J\u00b9") })
test_that("February", { expect_equal(formatter$Format(2), "F") })
test_that("March", { expect_equal(formatter$Format(3), "M\u00b9") })
test_that("April", { expect_equal(formatter$Format(4), "A\u00b9") })
test_that("May", { expect_equal(formatter$Format(5), "M\u00b2") })
test_that("June", { expect_equal(formatter$Format(6), "J\u00b2") })
test_that("July", { expect_equal(formatter$Format(7), "J\u00b3") })
test_that("August", { expect_equal(formatter$Format(8), "A\u00b2") })
test_that("September", { expect_equal(formatter$Format(9), "S") })
test_that("October", { expect_equal(formatter$Format(10), "O") })
test_that("November", { expect_equal(formatter$Format(11), "N") })
test_that("December", { expect_equal(formatter$Format(12), "D") })

test_that("Invalid month zero throws error", {
  expect_error(formatter$Format(0), "monthNumber must be an integer between 1 and 12")
})

test_that("Invalid month thirteen throws error", {
  expect_error(formatter$Format(13), "monthNumber must be an integer between 1 and 12")
})

test_that("Invalid month negative throws error", {
  expect_error(formatter$Format(-1), "monthNumber must be an integer between 1 and 12")
})
