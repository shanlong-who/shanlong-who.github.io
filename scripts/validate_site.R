library(xml2)

site_root <- normalizePath("docs", winslash = "/", mustWork = TRUE)
html_files <- list.files(site_root, pattern = "\\.html$", recursive = TRUE, full.names = TRUE)
stopifnot(length(html_files) == 17L)
errors <- character()
check <- function(condition, message) {
  if (!isTRUE(condition)) errors <<- c(errors, message)
}
resolve_local <- function(url, source_file) {
  url <- sub("[?#].*$", "", URLdecode(url))
  if (!nzchar(url)) return(source_file)
  candidate <- if (startsWith(url, "/")) file.path(site_root, sub("^/", "", url)) else file.path(dirname(source_file), url)
  if (dir.exists(candidate)) candidate <- file.path(candidate, "index.html")
  normalizePath(candidate, winslash = "/", mustWork = FALSE)
}
titles <- character()
for (html_file in html_files) {
  relative_file <- substring(html_file, nchar(site_root) + 2L)
  document <- read_html(html_file, encoding = "UTF-8")
  language <- xml_attr(xml_find_first(document, "//html"), "lang")
  expected_language <- if (startsWith(relative_file, "zh/")) "zh-CN" else "en"
  check(identical(language, expected_language), paste(relative_file, "has incorrect document language"))
  h1_nodes <- xml_find_all(document, "//main//h1")
  check(length(h1_nodes) == 1L, paste(relative_file, "must have one main heading"))
  title <- xml_text(xml_find_first(document, "//title"))
  titles <- c(titles, title)
  check(nchar(title) > 12L, paste(relative_file, "has an empty title"))
  check(length(xml_find_all(document, "//meta[@name='description'][string-length(@content)>20]")) == 1L,
        paste(relative_file, "has no useful description"))
  check(length(xml_find_all(document, "//a[@href='mailto:dings@who.int']")) > 0L,
        paste(relative_file, "has no contact link"))
  check(length(xml_find_all(document, "//nav//a[@aria-current='page']")) == 1L,
        paste(relative_file, "has ambiguous current navigation"))
  canonical <- xml_attr(xml_find_first(document, "//link[@rel='canonical']"), "href")
  check(startsWith(canonical, "https://shanlong-who.github.io/"), paste(relative_file, "has an invalid canonical URL"))
  if (relative_file != "404.html") {
    alternate <- xml_find_all(document, "//link[@rel='alternate'][@hreflang='en' or @hreflang='zh-CN']")
    check(length(alternate) == 2L, paste(relative_file, "has incomplete language alternatives"))
    for (alternate_url in xml_attr(alternate, "href")) {
      target <- resolve_local(sub("^https://shanlong-who.github.io", "", alternate_url), html_file)
      check(file.exists(target), paste(relative_file, "has a missing language counterpart:", alternate_url))
    }
  }
  image_nodes <- xml_find_all(document, "//img")
  image_alt <- xml_attr(image_nodes, "alt")
  check(all(!is.na(image_alt) & nzchar(image_alt)), paste(relative_file, "has an image without alternative text"))
  link_nodes <- xml_find_all(document, "//*[@href or @src]")
  links <- unique(c(xml_attr(link_nodes, "href"), xml_attr(link_nodes, "src")))
  links <- links[!is.na(links) & nzchar(links)]
  local_links <- links[!grepl("^(https?:|mailto:|tel:|data:|//)", links)]
  for (local_link in local_links) {
    target <- resolve_local(local_link, html_file)
    check(file.exists(target), paste(relative_file, "has a broken local link:", local_link))
    if (grepl("#", local_link, fixed = TRUE) && file.exists(target) && grepl("\\.html$", target)) {
      fragment <- sub("^.*#", "", local_link)
      if (nzchar(fragment)) {
        target_doc <- if (identical(target, html_file)) document else read_html(target)
        check(fragment %in% xml_attr(xml_find_all(target_doc, "//*[@id]"), "id"),
              paste(relative_file, "has a missing anchor:", local_link))
      }
    }
  }
  text <- paste(readLines(html_file, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
  check(!grepl("\\$(if|endif|body|title|translation-path)\\b", text),
        paste(relative_file, "contains an unresolved template variable"))
}
check(length(unique(titles)) == length(titles), "Page titles are not unique across languages")
check(file.exists(file.path(site_root, ".nojekyll")), "Missing .nojekyll")
check(file.exists(file.path(site_root, "sitemap.xml")), "Missing sitemap")
check(file.exists(file.path(site_root, "robots.txt")), "Missing robots.txt")
check(identical(unname(tools::md5sum("assets/shanlong-ding.jpg")),
                unname(tools::md5sum(file.path(site_root, "assets/shanlong-ding.jpg")))),
      "Published portrait differs from the supplied site asset")
if (length(errors)) stop(paste(unique(errors), collapse = "\n"), call. = FALSE)
cat(sprintf("PASS: %d rendered pages; language pairs, titles, navigation, contact links, assets, and internal links verified.\n", length(html_files)))
