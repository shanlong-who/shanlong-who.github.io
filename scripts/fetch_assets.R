library(curl)

asset_urls <- c(
  "dsir-logo.png" = "https://raw.githubusercontent.com/shanlong-who/DSIR/main/man/figures/logo.png",
  "exmort-logo.png" = "https://raw.githubusercontent.com/shanlong-who/exmort/main/man/figures/logo.png",
  "catascience-logo.png" = "https://raw.githubusercontent.com/shanlong-who/cataScience/main/man/figures/logo.png",
  "momo-mimi.png" = "https://raw.githubusercontent.com/shanlong-who/MOMO/main/Releases/2.0.0/MOMO-MIMI-preview.png"
)
for (asset_name in names(asset_urls)) {
  target_file <- file.path("assets", asset_name)
  curl_download(asset_urls[[asset_name]], target_file, quiet = TRUE,
                handle = new_handle(timeout = 60, connecttimeout = 15))
  cat(asset_name, file.info(target_file)$size, "bytes\n")
}
