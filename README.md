# Shiny in the Public Sector Showcase

A Quarto website that showcases Shiny apps used in the public sector. Renders as a gallery of cards grouped by category (Natural Resources, Public Health, Public Service).

Deployed to Posit Connect at `pub.current.posit.team`.

## How it works

The source of truth for app data is a [Google Sheet](https://docs.google.com/spreadsheets/d/17Uu_XyO3ILEO8tueOPfcqiLzauH8y1hplf8k-QcqS-E/edit?gid=1174587849#gid=1174587849) (requires Posit, PBC membership to access). The R script `R/import.R` pulls the sheet, processes it, and writes `apps.yml`, which Quarto uses to render the gallery via the `showcase.ejs` template.

Never edit `apps.yml` directly — always update the Google Sheet and re-run the import.

## Updating apps

### 1. Edit the Google Sheet

Add, remove, or edit rows. Each row has: Organization, Title, URL, Description, Thumbnail, order, category, tags.

### 2. Add a thumbnail

Take a screenshot of the app at **2400x1600** pixels. Navigate to an interesting view first. In Chrome, you can use DevTools to set a custom device size, or take a full-size screenshot and crop.

Save the file to `thumbnails/` using the naming convention: the app URL with protocol stripped and slashes replaced by underscores, plus `.png`. For example:

```
https://rconnect.usgs.gov/PA_radon_map/  ->  rconnect.usgs.gov_PA_radon_map_.png
```

Make sure the `Thumbnail` column in the Google Sheet matches the filename.

### 3. Run the import script

```r
source("R/import.R")
```

This downloads the sheet to `data/raw.csv`, processes it, and writes `apps.yml`. You'll need Google Drive authentication via the `googledrive` R package — it will prompt you on first run.

R dependencies are managed with renv. To restore them:

```r
source("R/renv/activate.R")
renv::restore()
```

### 4. Preview locally

```bash
quarto preview
```

### 5. Publish

Use the Posit Publisher extension in Positron to deploy to Posit Connect.

## Adding a new category

Categories and their display order are hardcoded in `R/import.R` in the `cat_order` tribble. If you add a new category in the Google Sheet, you also need to add it there:

```r
cat_order <- tribble(
  ~category,         ~order,
  "Natural Resources",    1,
  "Public Health",        2,
  "Public Service",       3,
  "New Category",         4,
)
```

## Project structure

```
apps.yml              # Generated app data (do not edit directly)
data/raw.csv          # Downloaded Google Sheet data
index.qmd             # Main page
showcase.ejs          # Card layout template
thumbnails/           # App screenshot images (2400x1600)
R/import.R            # Script to pull from Google Sheet and generate apps.yml
_brand.yml            # Posit brand colors and typography
_variables.yml        # Site-level variables (vertical name, URLs)
_quarto.yml           # Quarto project config
styles.scss           # Custom styles
title-block.html      # Custom title block partial
.posit/               # Posit Publisher deployment config
```
