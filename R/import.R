library(googledrive)
library(yaml)
library(dplyr)
library(readr)
library(purrr)
library(stringr)
library(tibble)
library(tidyr)
library(here)
source(here("R", "thumbnail-name.R"))

# Pull from google drive
sheet <- drive_download(
  as_id("17Uu_XyO3ILEO8tueOPfcqiLzauH8y1hplf8k-QcqS-E"),
  here("data", "raw.csv"),
  overwrite = TRUE
)

apps <- read_csv(here("data", "raw.csv")) |> 
  rename_all(tolower) |>
  rename(org = organization) |>
  mutate(
    category = str_to_title(category),
    # thumbnail is derived from the URL, not the sheet — see R/thumbnail-name.R
    thumbnail = map_chr(url, thumbnail_name)
  )

# Stop if any app is missing its thumbnail — capture them with R/capture.R
# (or the update-thumbnails skill) before regenerating apps.yml.
missing <- apps |>
  filter(!file.exists(here("thumbnails", thumbnail)))
if (nrow(missing) > 0) {
  stop(
    "Missing thumbnails for ", nrow(missing), " app(s):\n",
    paste0("  - ", missing$title, " (", missing$thumbnail, ")", collapse = "\n"),
    call. = FALSE
  )
}

cat_order <- tribble(
  ~category,         ~order,
  "Natural Resources",    1,
  "Public Health",        2,
  "Public Service",       3,
  "National Statistics",  4,
)

apps |>
  arrange(order) |>
  group_by(category) |>
  select(!new) |> 
  nest(.key = "tiles") |>
  left_join(cat_order) |>
  arrange(order) |>
  modify_in(.where = "tiles", .f = \(x) map(x, transpose)) |>
  transpose() |>
  write_yaml(here("apps.yml"), indent.mapping.sequence = TRUE)
