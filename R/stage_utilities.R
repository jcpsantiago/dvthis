#' Message to separate stages
#'
#' @param this_stage name of the stage
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

  rendered_stage
}


#' Message to finish stage
#'
#' @param .stage the name of the stage
#' @param .merchant_alias alias for merchant
#'
#' @return
#' @export
#'
#' @examples
stage_footer <- function(.stage = this_stage) {
  message(
    crayon::green(cli::symbol$tick),
    glue::glue(" Stage {cli::style_italic(.stage)} is done!")
  )
  cli::cat_line()
}



#' Log a stage step
#'
#' @param msg log message
#' @param .merchant_alias alias for merchant
#'
#' @return prints message to stdout
#' @author João Santiago
#' @export
log_stage_step <- function(msg) {
  cli::cat_bullet(
    glue::glue(msg)
  )
}


#' Saves data to intermediate
#' @param df the R data frame to save
#' @param .filename optional file name to pass qs::qsave. Default is df's name
#' @return saves data to intermediate folder as qs file
#' @author João Santiago
#' @export
save_intermediate_result <- function(r_object, .filename = NULL) {
  path_prefix <- here::here("data/intermediate")

  if (!fs::dir_exists(path_prefix)) {
    message(glue::glue("Creating dir {path_prefix}"))
    fs::dir_create(path_prefix)
  }

  if (!is.null(.filename)) {
    r_object_name <- .filename
  } else {
    r_object_name <- substitute(r_object)
  }

  message("Saving ", r_object_name, ".qs in ", path_prefix)
  qs::qsave(df, glue::glue("{path_prefix}/{r_object_name}.qs"))
}


#' Read an intermediate result
#' @param filename the filename to load as a string
#' @return an R object
#' @author João Santiago
read_intermediate_result <- function(filename) {
  qs::qread(
    here::here(
      glue::glue("data/intermediate/{filename}.qs")
    )
  )
}
