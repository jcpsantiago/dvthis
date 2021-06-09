test_that("header returns properly", {
  expect_equal(stage_header("this is the stage"), "this is the stage")
  expect_equal(stage_header("this is really the stage",
                            .right = "this is on the right"),
               "this is really the stage")
})
