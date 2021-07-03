#' Saves data to intermediate
#' @param r_object the R object to be saved.
#' @param rel_path optional path (relative to `data/intermediate`) to pass on to serializer. Defaults to the object's name without an extension added to the file on disk.
#' @param serializer function used to serialize the data to disk. Defaults to `qs::save`.
#' @param ... extra arguments passed to the serializer.
#' @return serializes an R object to the `data/intermediate` directory.
#' @author João Santiago
#' @export
save_intermediate_result <- function(r_object, rel_path = NULL, serializer = qs::qsave, ...) {
  path_prefix <- here::here("data/intermediate")

  if (!fs::dir_exists(path_prefix)) {
    if (!yesno::yesno(
      glue::glue("This will create {path_prefix}. Continue?")
    )) {
      stop(
        glue::glue("Aborting creation of {path_prefix}."),
        call. = FALSE
      )
    }

    message(glue::glue("Creating dir {path_prefix}"))
    fs::dir_create(path_prefix)
  }

  if (!is.null(rel_path)) {
    r_object_name <- rel_path
  } else {
    r_object_name <- substitute(r_object)
  }

  message(
    glue::glue("Saving {path_prefix}/{r_object_name}")
  )
  serializer(r_object, glue::glue("{path_prefix}/{r_object_name}"), ...)
}


#' Create function to read data level
#' @param data_level the level of data to read from. Example `intermediate` or `raw`.
#' @param .reader a reader function to be used as default. Optional.
#' @return a function.
#' @author João Santiago
make_read_data_function <- function(data_level, .reader = NULL) {
  function(rel_path, reader = .reader, ...) {
    if (is.null(reader) | class(reader) != "function") {
      stop(
        "Please provide a reader function. Example `qs::qread` or `readr::read_rds`",
        call. = FALSE
      )
    }

    path_prefix <- here::here(
      glue::glue("data/{data_level}")
    )
    full_path <- glue::glue("{path_prefix}/{rel_path}")

    if (!fs::file_exists(full_path)) {
      stop(
        glue::glue("Can't find {full_path}! Is there a typo?")
      )
    }

    reader(full_path, ...)
  }
}


#' Read an intermediate result
#' @param rel_path file path relative to `data/intermediate`.
#' @param reader function used to read the serialized data. Defaults to `qs::qread`.
#' @param ... extra arguments passed to the reader.
#' @return an R object.
#' @author João Santiago
#' @export
read_intermediate_result <- make_read_data_function("intermediate", qs::qread)


#' Read raw data
#' @param rel_path file path relative to `data/raw`.
#' @param reader function used to read the serialized data.
#' @param ... extra arguments passed to the reader.
#' @return an R object.
#' @author João Santiago
#' @export
read_raw_data <- make_read_data_function("raw")
