library(httr)
library(purrr)
library(rvest)

# paralelo
library(furrr)
library(progressr)

u_wiki <- "https://en.wikipedia.org/wiki/R_language"

r_wiki <- GET(u_wiki)

## outra alternativa
# read_html(u_wiki)

links <- r_wiki |> 
  read_html() |> 
  html_elements(xpath = "//table[@class='infobox vevent']//a")

## alternativa xpath
# r_wiki |> 
#   read_html() |> 
#   html_elements(xpath = "//table[contains(@class, 'infobox')]//a")

urls <- paste0("https://en.wikipedia.org", html_attr(links, "href"))

baixar_pagina <- function(u, indice, path) {
  f <- file.path(path, paste0(indice, ".html"))
  # o if é opcional
  if (!file.exists(f)) {
    GET(u, write_disk(f))
  }
}

## obs: imap pega o índice e coloca como segundo argumento
# imap(letters, \(letra, indice) print(paste(indice, letra)))

path <- "dados/wiki/"
imap(urls, \(x, y) baixar_pagina(x, y, path))

safe_baixar_pagina <- possibly(baixar_pagina)

imap(urls, \(x, y) safe_baixar_pagina(x, y, path), .progress = TRUE)

# em paralelo

baixar_pagina_prog <- function(u, indice, path, prog = NULL) {
  if (!is.null(prog)) prog()
  f <- file.path(path, paste0(indice, ".html"))
  # o if é opcional
  if (!file.exists(f)) {
    GET(u, write_disk(f))
  }
}

safe_baixar_pagina_prog <- possibly(baixar_pagina_prog)

plan(multisession, workers = 8)

with_progress({
  p <- progressor(length(urls))
  future_imap(urls, \(x, y) safe_baixar_pagina_prog(x, y, path, p))
})



