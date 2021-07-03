add_stage_to_dvc_yaml <- function(current_dvc_yaml, new_stage_name, .deps = NULL, .outs = NULL) {
  cmd <- c(glue::glue("Rscript stages/{new_stage_name}.R"))
  deps <- c(glue::glue("stages/{new_stage_name}.R"), .deps)
  outs <- .outs

  new_stage_list_start <- list(
    stages = list(
      new_stage = list("cmd" = cmd, "deps" = deps, "outs" = outs)
    )
  )
  names(new_stage_list_start$stages) <- new_stage_name
  new_stage_list <- modifyList(new_stage_list_start, new_stage_list_start)

  new_dvc_yaml <- modifyList(current_dvc_yaml, new_stage_list)

  return(new_dvc_yaml)
}


#' Title
#'
#' @param stage_name
#' @param .deps
#' @param .outs
#' @param dvc_yaml_path
#'
#' @return
#' @export
#'
#' @examples
add_r_stage <- function(stage_name, .deps = NULL, .outs = NULL, dvc_yaml_path = NULL) {
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

  current_dvc_yaml <- yaml::read_yaml(dvc_yaml_path)
  if (name %in% names(current_dvc_yaml$stages)) {
    stop(
      glue::glue("`{name}` is already a stage in {dvc_yaml_path}, please use a different name."),
      call. = FALSE
    )
  }

  if (!yesno::yesno(
    glue::glue("This will write to {dvc_yaml_path}. Continue?")
  )) {
    stop("Aborting writing `dvc.yaml`", call. = FALSE)
  }

  new_dvc_yaml <- add_stage_to_dvc_yaml(current_dvc_yaml, name, .deps, .outs)

  yaml::write_yaml(new_dvc_yaml, dvc_yaml_path)

  new_stage_path <- here::here(glue::glue("stages/{name}.R"))
  fs::file_copy(
    fs::path_package("dvthis", "templates", "new_stage.R"),
    new_stage_path
  )

  rstudioapi::navigateToFile(new_stage_path)
}
