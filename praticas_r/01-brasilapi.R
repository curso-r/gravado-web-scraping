library(httr)
library(jsonlite)

# cep ---------------------------------------------------------------------

u_base <- "https://brasilapi.com.br/api"
endpoint_cep <- "/cep/v2/"

cep <- "58084435"

u_cep <- paste0(u_base, endpoint_cep, cep)

r_cep <- GET(u_cep)

# obter os resultados a partir da chamada

content(r_cep)
# content(r_cep, as = "text")
content(r_cep, as = "raw")
content(r_cep, as = "parsed")

content(r_cep, as = "text") |> 
  fromJSON()


# agora vamos pesquisar na tabela FIPE

endpoint_fipe <- "/fipe/marcas/v1/"
tipo_veiculo <- "carros"
u_fipe <- paste0(u_base, endpoint_fipe, tipo_veiculo)

r_fipe <- GET(u_fipe)

content(r_fipe)

content(r_fipe, as = "text") |> 
  fromJSON(simplifyDataFrame = TRUE)

content(r_fipe, simplifyDataFrame = TRUE)
# data.frame

content(r_fipe, simplifyDataFrame = TRUE) |> 
  tibble::as_tibble()

r_fipe <- GET(
  u_fipe, 
  write_disk("dados/brasilapi/fipe_marcas.json", overwrite = TRUE)
)
r_fipe

# vamos obter as tabelas da FIPE
endpoint_fipe_tabelas <- "/fipe/tabelas/v1/"
u_fipe_tabelas <- paste0(u_base, endpoint_fipe_tabelas)
r_fipe_tabelas <- GET(u_fipe_tabelas)

tabelas_fipe <- r_fipe_tabelas |> 
  content(simplifyDataFrame = TRUE) |> 
  tibble::as_tibble()

tabelas_fipe |> 
  print(n = 100)

query_fipe <- list(
  "tabela_referencia" = "270"
)
r_fipe_query <- GET(u_fipe, query = query_fipe)

content(r_fipe, simplifyDataFrame = TRUE) |> 
  tibble::as_tibble()

content(r_fipe_query, simplifyDataFrame = TRUE) |> 
  tibble::as_tibble()

paste0(u_fipe, "?tabela_referencia=270") |> 
  GET()

# pegando o preco de um carro na tabela FIPE

endpoint_preco <- "/fipe/preco/v1/"
cod_veiculo <- "060006-7"
u_preco <- paste0(u_base, endpoint_preco, cod_veiculo)

r_preco <- GET(u_preco)

content(r_preco, simplifyDataFrame = TRUE) |> 
  tibble::as_tibble()

query_fipe <- list(
  "tabela_referencia" = "278"
)

r_preco_antigo <- GET(u_preco, query = query_fipe)

content(r_preco_antigo, simplifyDataFrame = TRUE) |> 
  tibble::as_tibble()
