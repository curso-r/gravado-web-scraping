library(httr)
library(rvest)
library(purrr)

u_dejt <- "https://dejt.jt.jus.br/dejt/f/n/diariocon"

r0_dejt <- GET(u_dejt)

vs <- r0_dejt |> 
  read_html() |> 
  html_element(xpath = "//input[@name='javax.faces.ViewState']") |> 
  html_attr("value")

body <- list(
  `corpo:formulario:tipoCaderno` = "1",
  `corpo:formulario:dataIni` = "25/07/2024",
  `corpo:formulario:dataFim` = "25/07/2024",
  `corpo:formulario:tribunal` = "",
  `corpo:formulario:ordenacaoPlc` = "",
  navDe = "",
  detCorrPlc = "",
  tabCorrPlc = "",
  detCorrPlcPaginado = "",
  exibeEdDocPlc = "",
  indExcDetPlc = "",
  org.apache.myfaces.trinidad.faces.FORM = "corpo:formulario",
  `_noJavaScript` = "false",
  javax.faces.ViewState = vs,
  source = "corpo:formulario:botaoAcaoPesquisar"
)

res <- POST(u_dejt, body = body, encode = "form")

onclicks <- res |> 
  read_html() |> 
  html_elements(xpath = "//a[contains(@class,'OraLink')]") |> 
  html_attr("onclick")

tabela <- res |> 
  read_html() |> 
  html_elements(xpath = "//table[contains(@class,'tabelaSelecao')]") |> 
  pluck(3) |> 
  html_table() |> 
  dplyr::mutate(onclick = onclicks)

onclick <- onclicks[5]


baixar_pdf <- function(onclick, body, path, dt = "") {
  body_pdf <- body
  src <- stringr::str_extract(onclick, "(?<=source:')[^']+")
  body_pdf$source <- src
  #f_pdf <- file.path(path, paste0(readr::parse_number(src), ".pdf"))
  f_pdf <- glue::glue("{path}/{dt}_{readr::parse_number(src)}.pdf")
  if (!file.exists(f_pdf)) {
    POST(u_dejt, body = body_pdf, write_disk(f_pdf))
  }
  f_pdf
}

# baixar_pdf(onclick, path = "dados/dejt/")

tabela_pdf <- tabela |> 
  dplyr::mutate(pdf_file = map_chr(onclick, \(x) baixar_pdf(x, "dados/dejt"), .progress = TRUE))

baixar_dia <- function(dt, path) {
  dia <- format(dt, "%d/%m/%Y")
  usethis::ui_info("Baixando dia {dia}...")
  u_dejt <- "https://dejt.jt.jus.br/dejt/f/n/diariocon"

  r0_dejt <- GET(u_dejt)

  vs <- r0_dejt |> 
    read_html() |> 
    html_element(xpath = "//input[@name='javax.faces.ViewState']") |> 
    html_attr("value")

  body <- list(
    `corpo:formulario:tipoCaderno` = "1",
    `corpo:formulario:dataIni` = dia,
    `corpo:formulario:dataFim` = dia,
    `corpo:formulario:tribunal` = "",
    `corpo:formulario:ordenacaoPlc` = "",
    navDe = "",
    detCorrPlc = "",
    tabCorrPlc = "",
    detCorrPlcPaginado = "",
    exibeEdDocPlc = "",
    indExcDetPlc = "",
    org.apache.myfaces.trinidad.faces.FORM = "corpo:formulario",
    `_noJavaScript` = "false",
    javax.faces.ViewState = vs,
    source = "corpo:formulario:botaoAcaoPesquisar"
  )

  res <- POST(u_dejt, body = body, encode = "form")

  onclicks <- res |> 
    read_html() |> 
    html_elements(xpath = "//a[contains(@class,'OraLink')]") |> 
    html_attr("onclick")

  tabela <- res |> 
    read_html() |> 
    html_elements(xpath = "//table[contains(@class,'tabelaSelecao')]") |> 
    pluck(3) |> 
    html_table() |> 
    dplyr::mutate(onclick = onclicks)

  tabela_pdf <- tabela |> 
    dplyr::mutate(pdf_file = map_chr(
      onclick, \(x) baixar_pdf(x, body, path, dt = dt), 
      .progress = TRUE)
    )
  
  tabela_pdf
}

dt <- as.Date("2023-08-02")
result <- baixar_dia(as.Date("2023-08-02"), path = "dados/dejt")
