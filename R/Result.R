#' @include Connection.R
NULL

#' Odbc Result Methods
#'
#' Implementations of pure virtual functions defined in the `DBI` package
#' for OdbcResult objects.
#' @name OdbcResult
#' @docType methods
NULL

OdbcResult <- function(connection, statement) {
  ptr <- new_result(connection@ptr, statement)
  new("OdbcResult", connection = connection, statement = statement, ptr = ptr)
}

#' @rdname OdbcResult
#' @export
setClass(
  "OdbcResult",
  contains = "DBIResult",
  slots = list(
    connection = "OdbcConnection",
    statement = "character",
    ptr = "externalptr"
  )
)

#' @rdname OdbcResult
#' @inheritParams DBI::dbClearResult
#' @export
setMethod(
  "dbClearResult", "OdbcResult",
  function(res, ...) {
    if (!dbIsValid(res)) {
      warning("Result already cleared")
    } else {
      result_release(res@ptr)
    }
    invisible(TRUE)
  })

#' @rdname OdbcResult
#' @inheritParams DBI::dbFetch
#' @inheritParams DBI::sqlRownamesToColumn
#' @export
setMethod(
  "dbFetch", "OdbcResult",
  function(res, n = -1, ..., row.names = NA) {
    sqlColumnToRownames(result_fetch(res@ptr, n, ...), row.names)
  })

#' @rdname OdbcResult
#' @inheritParams DBI::dbHasCompleted
#' @export
setMethod(
  "dbHasCompleted", "OdbcResult",
  function(res, ...) {
    result_completed(res@ptr)
  })

#' @rdname OdbcResult
#' @inheritParams DBI::dbGetInfo
#' @export
setMethod(
  "dbGetInfo", "OdbcResult",
  function(dbObj, ...) {
    # Optional
    getMethod("dbGetInfo", "DBIResult", asNamespace("DBI"))(dbObj, ...)
  })

#' @rdname OdbcResult
#' @inheritParams DBI::dbIsValid
#' @export
setMethod(
  "dbIsValid", "OdbcResult",
  function(dbObj, ...) {
    result_active(dbObj@ptr)
  })

#' @rdname OdbcResult
#' @inheritParams DBI::dbGetStatement
#' @export
setMethod(
  "dbGetStatement", "OdbcResult",
  function(res, ...) {
    res@statement
  })

#' @rdname OdbcResult
#' @inheritParams DBI::dbColumnInfo
#' @export
setMethod(
  "dbColumnInfo", "OdbcResult",
  function(res, ...) {
    result_column_info(res@ptr, ...)
  })

#' @rdname OdbcResult
#' @inheritParams DBI::dbGetRowCount
#' @export
setMethod(
  "dbGetRowCount", "OdbcResult",
  function(res, ...) {
    result_row_count(res@ptr)
  })

#' @rdname OdbcResult
#' @inheritParams DBI::getRowsAffected
#' @export
setMethod(
  "dbGetRowsAffected", "OdbcResult",
  function(res, ...) {
    result_rows_affected(res@ptr)
  })

#' @rdname OdbcResult
#' @inheritParams DBI::dbBind
#' @export
setMethod(
  "dbBind", "OdbcResult",
  function(res, params, ...) {

    params <- as.list(params)

    if (any(lengths(params) != 1)) {
      stop("`params` elements can only be of length 1", call. = FALSE)
    }
    result_bind(res@ptr, params)
    invisible(res)
  })
