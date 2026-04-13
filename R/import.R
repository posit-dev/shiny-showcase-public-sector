library(googledrive)
library(yaml)
library(dplyr)
library(readr)
library(purrr)
library(stringr)
library(tibble)
library(tidyr)
library(here)

# Pull from google drive
sheet <- drive_download(
  as_id("17Uu_XyO3ILEO8tueOPfcqiLzauH8y1hplf8k-QcqS-E"),
  here("data", "raw.csv"),
  overwrite = TRUE
)

apps <- read_csv(here("data", "raw.csv")) |> 
  rename_all(tolower) |>
  rename(org = organization) |>
  mutate(category = str_to_title(category))

cat_order <- tribble(
  ~category,         ~order,
  "Natural Resources",    1,
  "Public Health",        2,
  "Public Service",       3,
)

apps |>
  arrange(order) |>
  group_by(category) |>
  nest(.key = "tiles") |>
  left_join(cat_order) |>
  arrange(order) |>
  modify_in(.where = "tiles", .f = \(x) map(x, transpose)) |>
  transpose() |>
  write_yaml(here("apps.yml"), indent.mapping.sequence = TRUE)
