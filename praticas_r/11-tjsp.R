library(tidyverse)
library(httr)
library(rvest)

# usando httr

r_tjsp <- httr::POST(
  "https://esaj.tjsp.jus.br/cjsg/resultadoCompleta.do", 
  body = list(
    dados.buscaInteiroTeor = "test", 
    dados.origensSelecionadas = "T"
  )
)

r_tjsp_pag <- httr::GET(
  "https://esaj.tjsp.jus.br/cjsg/trocaDePagina.do", 
  query = list(
    tipoDeDecisao = "A", 
    pagina = 2, 
    conversationId = ""
  )
)

tab_html <- r_tjsp_pag |> 
  read_html(encoding = "UTF-8") |> 
  xml2::xml_find_all("//tr[@class='fundocinza1']//table")

tab_html[[1]] |> 
  html_table(fill = TRUE) |> 
  as_tibble() |> 
  mutate(X1 = str_squish(X1))

r_tjsp_pag$status_code

# trying httr2

req <- httr2::request("https://esaj.tjsp.jus.br/cjsg")

# get first page
req_busca <- req |> 
  httr2::req_url_path_append("resultadoCompleta.do") |> 
  httr2::req_body_form(
    dados.buscaInteiroTeor = "test", 
    dados.origensSelecionadas = "T"
  )

resp <- req_busca |> 
  httr2::req_perform()


# GET request for page 2

# retrieve cookies from last request
cookies <- resp$headers[names(resp$headers) == "Set-Cookie"] |> 
  purrr::set_names("Cookie")

req_tjsp_pag <- req |> 
  httr2::req_url_path_append("trocaDePagina.do") |> 
  httr2::req_url_query(
    tipoDeDecisao = "A", 
    pagina = 2, 
    conversationId = ""
  ) |> 
  httr2::req_headers(!!!cookies)

resp_pag <- req_tjsp_pag |> 
  httr2::req_perform()

tab_html <- resp_pag |> 
  httr2::resp_body_html(encoding = "UTF-8") |> 
  xml2::xml_find_all("//tr[@class='fundocinza1']//table")

tab_html[[1]] |> 
  html_table(fill = TRUE) |> 
  as_tibble() |> 
  mutate(X1 = str_squish(X1))
