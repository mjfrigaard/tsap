#' Check if package contains data.frame
#'
#' @param pkg name of package (a character vector)
#'
#' @return logical (`TRUE` = has data.frame, `FALSE` = no data.frame)
#' @export check_df_in_pkg
#'
#' @description
#' Returns `TRUE` if package has `data.frame`. If package is not installed,
#' install with `install.packages(dependencies = TRUE)`.
#'
#' 1. Check if the package is installed and load it
#'
#' 2. Retrieve the objects in the package
#'
#' 3. Use `purrr::map_lgl()` to apply `is.data.frame()` to each object in the
#'  package. `map_lgl()` returns a logical vector with the same length as
#'  the retrieved package objects.
#'
#'
#' @seealso [check_inst_pkg()]
#'
#' @importFrom purrr map_lgl
#'
#' @examples
#' check_df_in_pkg("dplyr")
#' check_df_in_pkg("stringr")
check_df_in_pkg <- function(pkg) {
  if (!require(pkg, character.only = TRUE)) {
    check_pkg(pkg = pkg)
  }
  pkg_obj <- ls(paste("package", pkg, sep = ":"))
  #
  is_df <- purrr::map_lgl(.x = pkg_obj,
    ~ is.data.frame(get(x = .x,
      envir = as.environment(
        paste("package", pkg, sep = ":")
      ))))
  return(any(is_df))
}

#' Get packages with data.frames
#'
#' @return named vector of packages with `data.frame` objects
#' @export get_pkgs_with_dfs
#'
#' @importFrom purrr map_vec
#'
#' @examples
#' get_pkgs_with_dfs()
get_pkgs_with_dfs <- function() {
  all_pkgs <- get_search_list_pkgs()
  df_pkg_set <- purrr::map_vec(.x = all_pkgs, check_df_in_pkg)
  df_pkgs <- all_pkgs[df_pkg_set]
  return(df_pkgs)
}
