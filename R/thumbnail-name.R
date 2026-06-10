library(stringr)

#' Canonical thumbnail filename for an app URL.
#'
#' The single source of truth for the naming convention, sourced by both
#' `R/import.R` (to derive the `thumbnail` column) and `R/capture.R` (to save
#' screenshots). Strips the protocol and any `#fragment`/`?query`, replaces
#' slashes with underscores, and appends `.png`.
#'
#' @param url App URL.
#'
#' @examples
#' thumbnail_name("https://rconnect.usgs.gov/PA_radon_map/")
#' #> "rconnect.usgs.gov_PA_radon_map_.png"
#' thumbnail_name("https://skylab.cdph.ca.gov/communityBurden/#tab-2190-1")
#' #> "skylab.cdph.ca.gov_communityBurden_.png"
thumbnail_name <- function(url) {
  url |>
    str_remove("^https?://") |>
    str_remove("[#?].*$") |>
    str_replace_all("/", "_") |>
    paste0(".png")
}
