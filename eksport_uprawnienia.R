# Indeks uprawnień do nadawania doktoratów w naukach ekonomicznych → uprawnienia.json dla strony.
# Źródła: zrodla/uprawnienia_MP/uprawnienia_przeglad.csv (wykazy MP 1952–2010) + zrodla/uprawnienia_RADon/organy_ekonomia_zarzadzanie_*.csv (od 2019).
# Mapowanie nazw: kolumna `rejestr` = nazwy z uczelnia_aktualna_nazwa w rejestrze (kilka rozdzielone „|”), `radon` = nazwa w RAD-on.
suppressMessages({library(jsonlite)})
Z <- "../../zrodla"
p <- read.csv(file.path(Z, "uprawnienia_MP/uprawnienia_przeglad.csv"), check.names = FALSE)
rad <- read.csv(sort(Sys.glob(file.path(Z, "uprawnienia_RADon/organy_ekonomia_zarzadzanie_*.csv")), decreasing = TRUE)[1])
map <- c(  # przegląd → rejestr | RAD-on (tylko tam, gdzie nazwy się różnią)
 "Uniwersytet Gdański (do 1970 WSE w Sopocie)" = "Uniwersytet Gdański",
 "PAN – Instytut Nauk Ekonomicznych (do 1971 Zakład)" = "Instytut Nauk Ekonomicznych PAN",
 "PAN – Instytut Rozwoju Wsi i Rolnictwa" = "Instytut Rozwoju Wsi i Rolnictwa PAN",
 "Instytut Ekonomiki Rolnictwa i Gospodarki Żywnościowej" = "Instytut Ekonomiki Rolnictwa i Gospodarki Żywnościowej - Państwowy Instytut Badawczy",
 "WSNS / Akademia Nauk Społecznych przy KC PZPR (do 1990)" = "Akademia Nauk Społecznych (zlikwidowana)",
 "Uniwersytet Jagielloński w Krakowie" = "Uniwersytet Jagielloński",
 "Akademia Górniczo-Hutnicza w Krakowie" = "Akademia Górniczo-Hutnicza im. Stanisława Staszica",
 "Akademia Leona Koźmińskiego" = "Akademia Leona Koźmińskiego w Warszawie",
 "Politechnika Śląska w Gliwicach" = "Politechnika Śląska")
map_radon <- c(
 "Akademia Górniczo-Hutnicza w Krakowie" = "Akademia Górniczo-Hutnicza im. Stanisława Staszica w Krakowie",
 "Uniwersytet Szczeciński (do 1985 Wydział Inż.-Ekon. Transportu Politechniki Szczecińskiej)" = "Uniwersytet Szczeciński",
 "Uniwersytet Morski w Gdyni (Akademia Morska)" = "Uniwersytet Morski w Gdyni",
 "Uniwersytet Radomski (WSI / Politechnika Radomska / UTH)" = "Uniwersytet Radomski",
 "Zachodniopomorski Uniwersytet Technologiczny w Szczecinie (do 2009 AR Szczecin)" = "Zachodniopomorski Uniwersytet Technologiczny w Szczecinie",
 "Akademia Finansów w Warszawie" = "Akademia Finansów i Biznesu Vistula",
 "Społeczna Akademia Nauk w Łodzi (SWSPiZ)" = "Społeczna Akademia Nauk w Łodzi",
 "Politechnika Śląska w Gliwicach" = "Politechnika Śląska",
 "Uniwersytet Jagielloński w Krakowie" = "Uniwersytet Jagielloński w Krakowie")
lata <- names(p)[grepl("^\\d{4}$", names(p))]
rad$od2 <- ifelse(is.na(rad$od) | rad$od == "", "2019-10-01", rad$od)
rad_u <- split(rad, rad$uczelnia)
unit <- function(nazwa, rejestr, radon, row) {
  st <- if (is.null(row)) setNames(rep("", length(lata)), lata) else unlist(row[lata]); st[is.na(st)] <- ""
  r <- rad_u[[radon]]
  list(nazwa = nazwa, rejestr = rejestr, radon = if (is.null(r)) NULL else radon,
       wykazy = as.list(st), pierwszy_dr = if (is.null(row)) NULL else row$pierwszy_doktorat,
       radon_od = if (is.null(r)) NULL else min(substr(r$od2, 1, 4)),
       radon_do = if (is.null(r) || all(r$do == "" | is.na(r$do))) NULL else max(substr(r$do, 1, 4)),
       radon_rady = if (is.null(r)) NULL else paste(unique(r$doktorat), collapse = "; "))
}
out <- lapply(seq_len(nrow(p)), function(i) { n <- p$uczelnia_dzis[i]
  unit(n, unname(if (n %in% names(map)) map[n] else n), unname(if (n %in% names(map_radon)) map_radon[n] else if (n %in% names(map)) map[n] else n), p[i, ]) })
# RAD-on: jednostki spoza wykazów MP (uprawnienia dopiero po 2010 r.)
known <- vapply(out, function(o) o$radon %||% "", "")
`%||%` <- function(a, b) if (is.null(a)) b else a
known <- vapply(out, function(o) if (is.null(o$radon)) "" else o$radon, "")
extra <- setdiff(names(rad_u), known)
extra <- extra[!extra %in% c("Uniwersytet Zielonogórski w Zielonej Górze")]  # dubel nazwy w RAD-on
out <- c(out, lapply(extra, function(n) unit(n, n, n, NULL)))
write_json(list(lata_wykazow = as.integer(lata), zrodlo_radon = basename(sort(Sys.glob(file.path(Z, "uprawnienia_RADon/organy_ekonomia_zarzadzanie_*.csv")), decreasing = TRUE)[1]),
                jednostki = out), "uprawnienia.json", auto_unbox = TRUE, null = "null")
cat("jednostek:", length(out), "(z wykazów MP:", nrow(p), "; tylko RAD-on:", length(extra), ")\n")
cat("bez RAD-on (z MP):", sum(vapply(out[seq_len(nrow(p))], function(o) is.null(o$radon), TRUE)), "\n")
