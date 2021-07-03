#' Create a new DVC project
#'
#' @param path user input; path to the new project
#' @param ... for future expansion, currenly unused
#'
create_dvc_project_gui <- function(path, ...) {
  tryCatch(
    system("dvc version", ignore.stderr = TRUE, ignore.stdout = TRUE),
    warning = function(w) {
      stop("DVC was not found in your system. Please make sure it is installed before creating a project.")
    }
  )

  tryCatch(
    system("git --version", ignore.stderr = TRUE, ignore.stdout = TRUE),
    warning = function(w) {
      stop("Git was not found in your system. Please make sure it is installed before creating a project.")
    }
  )

  full_path <- paste0(getwd(), "/", path)

  cli::cat_rule(glue::glue("Creating {path}..."))
  fs::dir_create(
    path,
    recurse = TRUE
  )
  cli::cli_alert_success("Created package directory")

  cli::cat_rule("Copying project skeleton...")
  from <- system.file("project-skeleton",
    package = "dvthis",
    lib.loc = NULL, mustWork = FALSE
  )

  ll <- list.files(
    path = from,
    full.names = TRUE,
    all.files = TRUE,
    no.. = TRUE
  )
  # remove `..`
  file.copy(
    ll,
    path,
    overwrite = TRUE,
    recursive = TRUE
  )

  t1 <- list.files(
    path,
    all.files = TRUE,
    recursive = TRUE,
    include.dirs = FALSE,
    full.names = TRUE
  )

  cli::cli_alert_success("Copied app skeleton")

  cli::cat_rule(glue::glue("Initializing git repo in {full_path}..."))
  system(
    glue::glue(
      "cd {full_path} && git init"
    ),
    ignore.stdout = TRUE,
    ignore.stderr = TRUE
  )
  cli::cli_alert_success("Git initialized")

  cli::cat_rule(glue::glue("Initializing DVC in {full_path}..."))
  system(
    glue::glue(
      "cd {full_path} && dvc init"
    ),
    ignore.stdout = TRUE,
    ignore.stderr = TRUE
  )
  cli::cli_alert_success("DVC is a go!")
  cli::cli_alert_success(glue::glue("{path} is ready!"))
}
