# Shanlong Ding · 丁善龙

A bilingual personal website about public health, data science, and open-source tools.

- English: https://shanlong-who.github.io/
- Chinese: https://shanlong-who.github.io/zh/
- Contact: dings@who.int

## Edit and build

Open `shanlong-site.Rproj` in RStudio. Edit the relevant English and Chinese `.qmd` files, then run:

```r
library(quarto)
quarto_render()
source("scripts/validate_site.R")
```

Or use the Quarto terminal command:

```sh
quarto render
Rscript scripts/validate_site.R
```

Commit the source and generated `docs/` directory together. GitHub Pages publishes `main:/docs`. A local preview is available with `Rscript scripts/preview.R`.

## Structure

- `index.qmd`, `projects/`, `notes/`, and `about/`: English content.
- `zh/`: corresponding Chinese pages.
- `templates/site.html`: shared accessible page layout and language navigation.
- `assets/site.css`: responsive styling; no external font dependency.
- `assets/`: supplied portrait and project artwork.
- `scripts/validate_site.R`: checks rendered pages, language pairs, assets, and internal links.
- `docs/`: generated publication files; edit source files rather than these files.

Each page declares matching English and Chinese URLs in its YAML metadata. Keep these fields aligned when adding a page. Tutorial cards link to existing public project documentation and label its language.

## Content and attribution

Profile details and contact information were supplied by Shanlong Ding. Project descriptions were checked against the public repositories on 3 November 2026.

DSIR, exmort, cataScience, and MOMO artwork is reproduced from the corresponding project repositories. Those projects retain their own licences, authorship, and copyright notices. The portrait is supplied for this personal website; no permission to reuse it is granted by this repository.

This site uses no analytics, cookie banner, login, or browser storage.
