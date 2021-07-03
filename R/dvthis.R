#' \code{dvthis} package
#'
#' R utilities for DVC pipelines
#' @docType package
#' @name dvthis
NULL

## quiets concerns of R CMD check re: the .'s that appear in pipelines
if (getRversion() >= "2.15.1") {
  utils::globalVariables(
    c(
      "this_stage"
    )
  )
}
