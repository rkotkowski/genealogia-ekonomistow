# Eksport rejestru do data.json dla strony z genealogią (ekongen/strona/index.html)
# Użycie: Rscript eksport_danych.R [plik_rejestru.xlsx]
suppressMessages({library(readxl); library(jsonlite)})
args <- commandArgs(TRUE)
f <- if (length(args)) args[1] else "../genealogia_akademicka_ekonomistów_polskich_20261102.xlsx"
d <- read_excel(f, sheet = "KSIĘGA GŁÓWNA", guess_max = 20000, col_types = "text")
d <- d[!is.na(d$doktorant_id_double) & d$doktorant_id_double != "0", ]
stopifnot(!anyDuplicated(d$doktorant_id_double))
yr <- function(x) as.integer(sub("^\\D*(\\d{4}).*$", "\\1", ifelse(grepl("\\d{4}", x), x, NA)))
slug <- function(x) chartr("ŻŚŁÓĄĘŃĆŹ_", "ZSLOAENCZ-", x)
stopifnot(!anyDuplicated(slug(d$doktorant_id_double)))
uni <- d$uczelnia_aktualna_nazwa; uni[is.na(uni) | uni == "NA"] <- ""  # w rejestrze bywa dosłowny tekst „NA”
unis <- names(sort(table(uni), decreasing = TRUE))
hist <- ifelse(!is.na(d$uczelnia_nazwa_podczas_nadania) & d$uczelnia_nazwa_podczas_nadania != uni,
               d$uczelnia_nazwa_podczas_nadania, "")
link <- ifelse(grepl("^https?://", d$link_do_pracy), d$link_do_pracy, "")
nz <- function(x) ifelse(is.na(x), "", x)
out <- list(
  zrodlo = basename(f), wygenerowano = format(Sys.Date()),
  uczelnie = unis,
  id = slug(d$doktorant_id_double),
  n = nz(d$doktorant),
  t = nz(d$tytuł_doktoratu),
  y = yr(d$rok_doktoratu),
  u = match(uni, unis) - 1L,
  h = hist,
  p = nz(slug(d$promotor_id)),
  q = nz(slug(d$promotor_pomocniczy_id)),
  w = nz(d$wiki_doktoranta),
  l = link,
  hy = yr(d$habilitacja_rok),
  rv = gsub("^\\|+|\\|+$", "", gsub("\\|+", "|", paste(nz(slug(d$recenzent1_id)), nz(slug(d$recenzent2_id)), nz(slug(d$recenzent3_id)), sep = "|"))),
  pr = suppressWarnings(as.integer(substr(d$profesor_rok, 1, 4))),
  o = ifelse(!is.na(d$ORCID) & grepl("^[0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{3}[0-9X]$", d$ORCID), d$ORCID, "")
)
write_json(out, "data.json", auto_unbox = TRUE, na = "null")
cat("osób:", length(out$id), " plik:", round(file.size("data.json")/1e6, 2), "MB\n")
