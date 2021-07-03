#' Header to separate stages
#'
#' @param this_stage name of the stage.
#' @param .right additional information to show on the right side of the header. Defaults to NULL.
#'
#' @return string with name of stage
#' @author João Santiago
#' @export
stage_header <- function(this_stage, .right = NULL) {
  rendered_stage <- glue::glue(this_stage, .envir = .GlobalEnv)

  cli::cat_line()
  cli::cli_rule(
    crayon::yellow(
      rendered_stage
    ),
    right = .right
  )

  as.character(rendered_stage)
}


#' Message to finish stage
#'
#' @param .stage the name of the stage as a string. Default behavior is to search the global environment for a `this_stage` object containing the return string of `dvthis::stage_header`.
#'
#' @return prints a closing footer
#' @export
stage_footer <- function(.stage = this_stage) {
  message(
    crayon::green(cli::symbol$tick),
    glue::glue(" Stage {cli::style_italic(.stage)} is done!")
  )
  cli::cat_line()
}



#' Log a stage step
#'
#' @param msg log message.
#'
#' @return prints message to stdout
#' @author João Santiago
#' @export
log_stage_step <- function(msg) {
  cli::cat_bullet(
    glue::glue(msg)
  )
}
