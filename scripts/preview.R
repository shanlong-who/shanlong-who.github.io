library(httpuv)

site_root <- normalizePath("docs", winslash = "/", mustWork = TRUE)
site_port <- as.integer(Sys.getenv("SITE_PREVIEW_PORT", "4857"))
mime_types <- c(html = "text/html; charset=utf-8", css = "text/css; charset=utf-8",
                svg = "image/svg+xml", png = "image/png", jpg = "image/jpeg",
                js = "text/javascript; charset=utf-8", xml = "application/xml",
                txt = "text/plain; charset=utf-8", json = "application/json")
site_app <- list(call = function(request) {
  request_path <- sub("^/+", "", URLdecode(request$PATH_INFO))
  file_path <- normalizePath(file.path(site_root, request_path),
                             winslash = "/", mustWork = FALSE)
  if (!identical(file_path, site_root) &&
      !startsWith(tolower(file_path), paste0(tolower(site_root), "/"))) {
    return(list(status = 403L, headers = list("Content-Type" = "text/plain"), body = "Forbidden"))
  }
  if (dir.exists(file_path)) file_path <- file.path(file_path, "index.html")
  status <- 200L
  if (!file.exists(file_path)) {
    file_path <- file.path(site_root, "404.html")
    status <- 404L
  }
  extension <- tolower(tools::file_ext(file_path))
  content_type <- if (extension %in% names(mime_types)) mime_types[[extension]] else "application/octet-stream"
  list(status = status,
       headers = list("Content-Type" = content_type, "Cache-Control" = "no-store"),
       body = readBin(file_path, "raw", n = file.info(file_path)$size))
})
cat(sprintf("Local preview: http://127.0.0.1:%d/\n", site_port))
flush.console()
runServer("127.0.0.1", site_port, site_app)
