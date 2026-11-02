# Genealogia akademicka ekonomistów polskich

Rejestr doktoratów polskich ekonomistów i relacji promotorskich (ok. 9,7 tys. osób, od XVIII w. do 2026 r.), z przeglądarką drzew genealogicznych, grafem relacji i indeksem uprawnień uczelni do nadawania stopnia doktora.

Strona: https://rkotkowski.github.io/genealogia-ekonomistow/

## Zawartość

| plik | co to jest |
|---|---|
| `index.html` | cała strona (HTML + JS, bez serwera i bez kroków budowania) |
| `data.json` | eksport rejestru: osoby, rok i uczelnia doktoratu, tytuł rozprawy, promotorzy |
| `uprawnienia.json` | uprawnienia jednostek do nadawania doktoratów (Monitor Polski 1952–2010, RAD-on od 2019) |
| `eksport_danych.R`, `eksport_uprawnienia.R` | skrypty, które tworzą pliki JSON z rejestru `.xlsx` (rejestr nie jest częścią repozytorium) |
| `vendor/d3.min.js` | d3 7.8.5 (licencja ISC) |
| `fonts/` | Spectral, IBM Plex Sans, IBM Plex Mono (SIL Open Font License 1.1) |

Strona nie wczytuje niczego z zewnętrznych serwerów i nie używa plików cookie ani analityki.

## Aktualizacja danych

```sh
Rscript eksport_danych.R ../genealogia_akademicka_ekonomistów_polskich_RRRRMMDD.xlsx
Rscript eksport_uprawnienia.R
git add data.json uprawnienia.json && git commit -m "Rejestr RRRRMMDD" && git push
```

Podgląd lokalny: `python3 -m http.server` w tym katalogu, potem http://localhost:8000.

## Poprawki i uzupełnienia

Zakładka „Zgłoś uzupełnienie” na stronie albo e-mail: kotkowski@inepan.waw.pl. Informacja o przetwarzaniu danych osobowych: zakładka „Dane osobowe”.

## Licencja

Dane (`data.json`, `uprawnienia.json`) zebrał autor ze źródeł publicznych; udostępnione na licencji [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/deed.pl). Przy wykorzystaniu prosimy o wskazanie autora i podanie adresu tej strony. Kod strony i skryptów: licencja MIT. Szczegóły w pliku `LICENSE`.

Administrator danych osobowych: dr Radosław Kotkowski, kotkowski@inepan.waw.pl.
