#' Check if package is loaded, if not load it
#'
#' @param pkg name of package (a character vector)
#'
#' @return Package: `'name'` loaded or Loading package: `'name'`
#' @export check_inst_pkg
#'
#' @description
#' Check if `pkg` is installed. If not, package is installed with
#' `install.packages(dependencies = TRUE)` and loaded with
#' `library(pkg, character.only = TRUE)`
#'
#'
#' @examples
#' check_inst_pkg("plotly")
check_inst_pkg <- function(pkg) {
  package.check <- suppressWarnings(
    suppressMessages(
      suppressPackageStartupMessages(
        lapply(X = pkg, FUN = function(x) {
          if (!require(x, character.only = TRUE)) {
            install.packages(x, dependencies = TRUE)
          }
        })
      )
    )
  )
  suppressWarnings(
    suppressPackageStartupMessages(
      library(pkg, character.only = TRUE)
    )
  )
}

#' Get all packages on search list
#'
#' @return All items from `search()` with a `package:` prefix
#' @export get_search_list_pkgs
#'
#' @description
#' This function is meant to be used in combination with `check_df_in_pkg()`
#'
#' @seealso [check_df_in_pkg()]
#'
#' @importFrom purrr set_names
#'
#' @examples
#' get_search_list_pkgs()
#'
get_search_list_pkgs <- function() {
  all_srch_lst <- search()
  all_pkgs <- grep(pattern = "package:", x = all_srch_lst, value = TRUE)
  pkgs <- gsub(pattern = ".*:|.GlobalEnv|datasets",
      replacement = "",
      x = all_pkgs)
  pkgs_chr <- pkgs[nzchar(pkgs)]
  pkg_nms <- purrr::set_names(pkgs_chr)
  return(pkg_nms)
}

#' Get names of data.frames from package
#'
#' @param pkg
#'
#' @return named vector of data.frames in package
#' @export get_pkg_df_names
#'
#' @examples
#' get_pkg_df_names(pkg = "base")
#' get_pkg_df_names(pkg = "datasets")
get_pkg_df_names <- function(pkg) {
  pkg_pos <- paste0("package:", pkg)
  pkg_nms <- ls(pkg_pos)
  data <- lapply(pkg_nms, get, pkg_pos)
  df_names <- pkg_nms[vapply(data, is.data.frame, logical(1))]
  if (length(df_names) > 1) {
    return(df_names)
  }
  return(NULL)
}

#' Get package datasets metadata
#'
#' @param package name of package (a character vector)
#' @param allClass logical (include all classes of data?)
#' @param incPackage logical (include package name in result?)
#' @param maxTitle maximum length of dataset title
#'
#' @description
#' This is a variation on the `vcdExtra::datasets()` function.
#' Read more here:
#' https://github.com/friendly/vcdExtra/blob/master/R/datasets.R
#'
#'
#' @return `data.frame` with 6 variables (`dataset`, `title`, `dimensions`,
#' `obs`, `vars`, `display_title`)
#'
#' @export get_pkg_datameta
#'
#' @importFrom tibble as_tibble
#' @importFrom dplyr select mutate
#' @importFrom tidyr separate
#'
#' @examples
#' require(tidyr)
#' get_pkg_datameta("tidyr")
get_pkg_datameta <- function(package, allClass = FALSE,
                     incPackage = length(package) > 1,
                     maxTitle = NULL) {
  # make sure requested packages are available and loaded
  for (i in seq_along(package)) {
    if (!isNamespaceLoaded(package[i])) {
      if (requireNamespace(package[i], quietly = TRUE)) {
        cat(paste("Loading package:", package[i], "\n"))
      } else {
        stop(paste("Package", package[i], "is not available"))
      }
    }
  }
  dsitems <- data(package = package)$results
  wanted <- c("Package", "Item", "Title")

  ds <- as.data.frame(dsitems[, wanted], stringsAsFactors = FALSE)

  getData <- function(x, pkg) {
    objname <- gsub(" .*", "", x)
    e <- loadNamespace(pkg)
    if (!exists(x, envir = e)) {
      dataname <- sub("^.*\\(", "", x)
      dataname <- sub("\\)$", "", dataname)
      e <- new.env()
      data(list = dataname, package = pkg, envir = e)
    }
    get(objname, envir = e)
  }

  getDim <- function(i) {
    data <- getData(ds$Item[i], ds$Package[i])
    if (is.null(dim(data))) length(data) else paste(dim(data), collapse = "x")
  }
  getClass <- function(i) {
    data <- getData(ds$Item[i], ds$Package[i])
    cl <- class(data)
    if (length(cl) > 1 && !allClass) cl[length(cl)] else cl
  }

  ds$dim <- unlist(lapply(seq_len(nrow(ds)), getDim))

  ds$class <- unlist(lapply(seq_len(nrow(ds)), getClass))
  if (!is.null(maxTitle)) ds$Title <- substr(ds$Title, 1, maxTitle)
  if (incPackage) {
    ds[c("Package", "Item", "class", "dim", "Title")]
  } else {
    ds[c("Item", "class", "dim", "Title")]
  }
  # named cols
  ds_cols <- dplyr::select(
    .data = ds,
    package = Package,
    dataset = Item,
    title = Title,
    dimensions = dim
  )
  # observations and variables
  ds_obs_vars <- tidyr::separate(
    data = ds_cols,
    col = dimensions,
    into = c("obs", "vars"),
    sep = "x",
    remove = TRUE
  )
  # tibble
  tbl_out <- tibble::as_tibble(ds_obs_vars)
  return(tbl_out)
}

# library(Lahman)
# dataset_list <- pkg_data(package = "Lahman")
# dataset_list
# pkg_data_metadata <- tibble::as_tibble(datasets(package = "Lahman"))
# pkg_data_metadata
