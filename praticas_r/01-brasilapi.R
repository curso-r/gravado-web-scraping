library(httr)
library(httr2)
library(jsonlite)
library(tidyverse)

# cep ---------------------------------------------------------------------

u_base <- "https://brasilapi.com.br/api"
endpoint_cep <- "/cep/v1/"

# vamos gerar um CEP válido aqui: https://www.geradordecep.com.br
cep <- "58084435"

u_cep <- paste0(u_base, endpoint_cep, cep)
r_cep <- GET(u_cep)
r_cep

# Vamos entender as diferentes formas de pegar o resultado

content(r_cep)
content(r_cep, as = "text")
content(r_cep, as = "raw")
content(r_cep, as = "parsed")

# usando httr2
req <- u_cep |>
  request()

## alternativa com req_url_path_append()
# req <- u_base |>
#   request() |>
#   req_url_path_append(endpoint_cep) |>
#   req_url_path_append(cep)

resp <- req |>
  req_perform()

r_cep_httr2 |>
  resp_body_json()

r_cep_httr2 |>
  resp_body_string()

# agora vamos pesquisar na tabela FIPE

endpoint_fipe <- "/fipe/marcas/v1/"
tipo_veiculo <- "carros"
u_fipe <- paste0(u_base, endpoint_fipe, tipo_veiculo)
r_fipe <- GET(u_fipe)

## transformando resultado em um data frame

da <- content(r_fipe, simplifyDataFrame = TRUE) |>
  as_tibble()

da

## lendo com jsonlite

content(r_fipe, "text") |>
  fromJSON() |>
  as_tibble()

## salvando em arquivo

r_fipe <- GET(u_fipe, write_disk("fipe.json"))

## lendo arquivo com jsonlite

read_json("fipe.json", simplifyDataFrame = TRUE) |>
  as_tibble()

## e o parâmetro?

endpoint_fipe_tabelas <- "/fipe/tabelas/v1"
u_fipe_tabelas <- paste0(u_base, endpoint_fipe_tabelas)
r_fipe_tabelas <- GET(u_fipe_tabelas)

tabelas <- r_fipe_tabelas |>
  content(simplifyDataFrame = TRUE) |>
  as_tibble()

## chamando com um parâmetro

query_fipe <- list(
  tabela_referencia = "270"
)

r_fipe_query <- GET(u_fipe, query = query_fipe)

## outra forma de usar query

# com httr2

req <- u_base |>
  request() |>
  req_url_path_append(endpoint_fipe_tabelas) |>
  req_url_query(tabela_referencia = "270")

## alternativa
# req <- u_base |>
#   request() |>
#   req_url_path_append(endpoint_fipe_tabelas) |>
#   req_url_query(!!!query_fipe)

resp <- req |>
  req_perform()

resp |>
  resp_body_json(simplifyDataFrame = TRUE) |>
  as_tibble()

# preco de carro na FIPE --------------------------------------------------

## infelizmente ainda não dá para pegar a lista de carros pela Brasil API
## https://github.com/BrasilAPI/BrasilAPI/issues/373

## Mas nós podemos pegar aqui: https://www.tabelafipebrasil.com/fipe/carros
## (depois podemos fazer isso via web scraping!)

endpoint_preco <- "/fipe/preco/v1/"
cod_veiculo <- "004515-2"
u_preco <- paste0(u_base, endpoint_preco, cod_veiculo)
r_preco <- GET(u_preco)

content(r_preco, simplifyDataFrame = TRUE) |>
  as_tibble()

## agora vamos ver o preço do carro em outra tabela

req <- u_base |>
  request() |>
  req_url_path_append(endpoint_preco) |>
  req_url_path_append(cod_veiculo) |>
  req_url_query(tabela_referencia = "270")

resp <- req |>
  req_perform()

resp |>
  resp_body_json(simplifyDataFrame = TRUE) |>
  as_tibble()

## aplicação: analisar o preço do carro 0km em cada mês entre 2022 e 2024

tabelas_filtrado <- tabelas |>
  filter(codigo >= 281)

tabelas_filtrado

pegar_tabela_codigos <- function(tab) {
  # fazendo tudo em um pipeline só
  req |>
    req_url_query(tabela_referencia = tab) |>
    req_perform() |>
    resp_body_json(simplifyDataFrame = TRUE) |>
    as_tibble() |>
    filter(anoModelo == 32000)
}

da_preco <- tabelas_filtrado |>
  pull(codigo) |>
  map(pegar_tabela_codigos) |>
  list_rbind()

