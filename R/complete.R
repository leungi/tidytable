#' Complete a data.table with missing combinations of data
#'
#' @description
#' Turns implicit missing values into explicit missing values.
#'
#' @param .df A data.frame or data.table
#' @param ... Columns to expand
#' @param fill A named list of values to fill NAs with.
#' @param .fill This argument has been renamed to fill and is deprecated
#'
#' @export
#'
#' @examples
#' test_df <- data.table(x = 1:2, y = 1:2, z = 3:4)
#'
#' test_df %>%
#'   complete.(x, y)
#'
#' test_df %>%
#'   complete.(x, y, fill = list(z = 10))
complete. <- function(.df, ..., fill = list(), .fill = NULL) {
  UseMethod("complete.")
}

#' @export
complete..data.frame <- function(.df, ..., fill = list(), .fill = NULL) {

  if (!is.null(.fill))
    deprecate_stop("0.5.5", "tidytable::complete.(.fill = )", "complete(fill = )")

  dots <- enquos(...)

  dots <- dots[!map_lgl.(dots, quo_is_null)]

  if (length(dots) == 0) return(.df)

  data_env <- env(quo_get_env(dots[[1]]), .df = .df)

  full_df <- eval_quo(
    tidytable::expand.(.df, !!!dots),
    new_data_mask(data_env), env = caller_env()
  )

  if (is_empty(full_df)) return(.df)

  full_df <- full_join.(full_df, .df, by = names(full_df))
  full_df <- replace_na.(full_df, replace = fill)

  full_df
}
