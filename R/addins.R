#' Run `dvc repro`
#'
#' @param stage up to which stage to run. Default = "" i.e. tries to run the whole pipeline.
#'
#' @return runs `dvc repro`
#' @export
dvc_repro <- function(stage = "") {
  if (stage != "") {
    stage <- (paste0(" ", stage))
  }
  message(
    glue::glue("Running `dvc repro{stage}`")
  )
  rstudioapi::terminalExecute(
    glue::glue("dvc repro{stage}")
  )
}

#' Run `dvc repro` up to the currently open stage
#'
#' @return runs `dvc repro {stage}`
dvc_repro_upstream <- function() {
  project_path <- rstudioapi::getActiveProject()
  dvc_yaml_path <- glue::glue("{project_path}/dvc.yaml")
  active_file_path <- rstudioapi::documentPath()
  active_file_name <- fs::path_file(active_file_path)

  if (!fs::path_ext(active_file_path) %in% c("R", "r")) {
    stop(
      glue::glue("`{active_file_name}` is not an R script! Please use stages ending in *.R")
    )
  }

  if (!fs::file_exists(dvc_yaml_path)) {
    stop(glue::glue("Could not find `dvc.yaml` in `{project_path}` (the current project's path)"))
  }

  dvc_yaml <- yaml::read_yaml(dvc_yaml_path)

  # TODO: replace purrr with base R solutions to avoid one extra dependency
  stages_df_list <- purrr::imap(
    dvc_yaml$stages,
    function(value, key) {

      if ("foreach" %in% names(value)) {
        .cmd <- value$do$cmd
      } else {
        .cmd <- value$cmd
      }

      data.frame(stage = key, cmd = .cmd)
    }
  )

  stages_df <- purrr::reduce(stages_df_list, rbind)

  stages <- unique(stages_df[grepl(active_file_name, stages_df$cmd), ]$stage)

  if (length(stages) == 0) {
    stop(
      glue::glue("There is no stage in `{dvc_yaml_path}` using `{active_file_name}`!")
    )
  }

  if (length(stages) == 1) {
    dvc_repro(stages)
  } else if (length(stages) > 1) {
    purrr::walk(stages, dvc_repro)
  }
}
