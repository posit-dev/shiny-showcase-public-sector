---
name: update-thumbnails
description: Capture or refresh Shiny app thumbnails for the public-sector showcase. Use when new apps have been added to the Google Sheet and need screenshots, or when an existing thumbnail needs re-taking. Opens each app in a browser the user can drive, screenshots at 2400x1600, saves under the canonical name, and regenerates apps.yml.
---

# Update showcase thumbnails

Thumbnails live in `thumbnails/` and are named canonically from each app's URL.
The name is **derived**, never stored in the Google Sheet — `R/thumbnail-name.R`
is the single source of truth (`thumbnail_name()` strips the protocol and any
`#fragment`/`?query`, replaces `/` with `_`, appends `.png`).

A "new app" is any row whose `thumbnail_name(url)` file is **absent** from
`thumbnails/`. Don't rely on the sheet's `New`/`Thumbnail` columns to decide this.

Run R **interactively** (in the Positron/RStudio console). Do **not** use `Rscript`.

## Steps

1. **Pull the latest sheet and regenerate.** In R:
   ```r
   source("R/import.R")   # downloads the sheet to data/raw.csv, writes apps.yml
   ```
   This needs `googledrive` auth (prompts on first run) and a restored renv library
   (`renv::restore()` if packages are missing).

2. **List apps still missing a thumbnail.** In R:
   ```r
   library(readr); library(dplyr); library(here)
   source(here("R", "thumbnail-name.R"))
   read_csv(here("data", "raw.csv")) |>
     mutate(file = vapply(URL, thumbnail_name, "")) |>
     filter(!file.exists(here("thumbnails", file))) |>
     select(Title, URL, file)
   ```

3. **Capture each missing app.** For one URL at a time:
   ```r
   source("R/capture.R")
   url <- "https://kdph.shinyapps.io/atlas/"
   b <- open_app(url)          # opens a viewable window, 2400x1600 output
   ```
   If the app opens looking small/zoomed-out, re-open with a `zoom` factor —
   the output stays 2400x1600 but content renders larger and sharper:
   ```r
   b$close(); b <- open_app(url, zoom = 2)
   ```
   Now get the app into the view you want before capturing:
   - Interact directly in the window (dismiss dialogs, click tabs, scroll), **or**
   - Drive it from R, e.g.
     `b$Runtime$evaluate('document.querySelector("a[data-value=\\"Map\\"]").click()')`
   - Give slow Shiny apps time to finish loading (`Sys.sleep(6)` if needed).

   When it looks right:
   ```r
   capture_app(b, url)   # saves thumbnails/<derived name>.png
   b$close()
   ```
   Ask the user to confirm the saved PNG looks good (interesting view, no spinners
   or modals) before moving on.

4. **Regenerate and preview.**
   ```r
   source("R/import.R")
   ```
   ```bash
   quarto preview
   ```
   Check every card renders an image — no broken thumbnails.

5. **Publish** via the Posit Publisher extension in Positron (see README).

## Notes

- No sheet write-back is needed — the `Thumbnail` column is vestigial; the filename
  is always derived from the URL.
- If an app needs a specific tab/scroll state, that's exactly why capture is manual:
  drive the live session, then `capture_app()`.
