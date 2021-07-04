#' Prepare new stage list for DVC YAML
#'
#' @param new_stage_name string name of new stage.
#' @param .deps character vector with paths to dependencies. Always adds the stage script as a dependency. Optional.
#' @param .outs character vector with paths of outputs. Optional.
#'
#' @return a list.
prepare_new_stage_list <- function(new_stage_name, .deps = NULL, .outs = NULL) {
  cmd <- c(glue::glue("Rscript stages/{new_stage_name}.R"))
  deps <- c(glue::glue("stages/{new_stage_name}.R"), .deps)
  outs <- .outs

  new_stage_list_start <- list(
    stages = list(
      new_stage = c("cmd" = cmd, "deps" = deps, "outs" = outs)
    )
  )
  names(new_stage_list_start$stages) <- new_stage_name

  modifyList(new_stage_list_start, new_stage_list_start)
}

#' Build DVC arguments
#'
#' @param option command line option as a string. Example `-d`.
#' @param values character vector.
#'
#' @return a character.
build_dvc_args <- function(option, values) {
  ifelse(
    is.null(values),
    "",
    paste(sapply(values, function(x) paste(option, x)), collapse = " ")
  )
}

#' Combine all arguments for DVC command
#'
#' @param stage_name name of the stage without any white spaces. Example: `train_model`
#' @param .deps character vector with paths to dependencies. Optional.
#' @param .outs character vector with paths of outputs. Optional.
#'
#' @return a character.
combine_dvc_args <- function(stage_name, .deps = NULL, .outs = NULL) {
  stage_script_path <- glue::glue("stages/{stage_name}.R")

  deps <- build_dvc_args("-d", c(.deps, stage_script_path))
  outs <- build_dvc_args("-o", .outs)

  glue::glue(
    "run --no-exec -n {stage_name} {deps} {outs} Rscript {stage_script_path}"
  )
}

#' Add a new R stage
#'
#' @param stage_name name of the stage without any white spaces. Example: `train_model`
#' @param .deps character vector with paths to dependencies. Optional.
#' @param .outs character vector with paths of outputs. Optional.
#'
#' @return function is run for its side effects.
#' @export
add_r_stage <- function(stage_name, .deps = NULL, .outs = NULL) {
  dvc_yaml_path <- here::here("dvc.yaml")
  if (!fs::file_exists(dvc_yaml_path)) {
    stop(
      glue::glue("Can't find {dvc_yaml_path}. Did you run `dvc init` in the project root?")
    )
  }

  # this is a requirement because dvc.yaml is yaml and the stage names are top-level
  # objects which cannot have spaces
  if (grepl("\\s", stage_name)) {
    no_white_spaces <- gsub("\\s", "_", stage_name)
    if (!yesno::yesno(glue::glue("`{stage_name}` cannot contain spaces. Can I call the stage `{no_white_spaces}` instead?"))) {
      stop("Aborting adding new stage.", call. = FALSE)
    }
    name <- no_white_spaces
  } else {
    name <- stage_name
  }

  new_stage_path <- here::here(glue::glue("stages/{name}.R"))
  fs::file_copy(
    fs::path_package("dvthis", "templates", "new_stage.R"),
    new_stage_path
  )

  dvc_args <- combine_dvc_args(name, .deps, .outs)

  tryCatch(
    system2("dvc", dvc_args),
    finally = function() {
      fs::file_delete(new_stage_path)
    }
  )

  rstudioapi::navigateToFile(new_stage_path)
}
