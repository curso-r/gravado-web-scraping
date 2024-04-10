library(tidyverse)
library(httr)
library(httr2)

u_sptrans <- "http://api.olhovivo.sptrans.com.br/v2.1"
endpoint <- "/Posicao"

u_sptrans_busca <- paste0(u_sptrans, endpoint)
r_sptrans <- GET(u_sptrans_busca)
r_sptrans
content(r_sptrans)

# Obtenha a API key e coloque no seu ambiente
## Dica: usar usethis::edit_r_environ("project")
api_key <- Sys.getenv("API_OLHO_VIVO")

# caso voce nao queira/nao tenha conseguido fazer uma conta
api_key <- "4af5e3112da870ac5708c48b7a237b30206806f296e1d302e4cb611660e2e03f"

u_sptrans_login <- paste0(u_sptrans, "/Login/Autenticar")
q_sptrans_login <- list(token = api_key)
# q_sptrans_login <- list(token = api_key)
r_sptrans_login <- POST(u_sptrans_login, query = q_sptrans_login)

# precisa ser TRUE!
content(r_sptrans_login)

# agora sim, estamos autenticados :)

(r_sptrans <- httr::GET(u_sptrans_busca))
result <- content(r_sptrans, simplifyDataFrame = TRUE)

result$l |>
  tibble::as_tibble()

# alternativa httr2 -------------------------------------------------------

u_sptrans <- "http://api.olhovivo.sptrans.com.br/v2.1"
req_base <- u_sptrans |>
  request()

req_login <- req_base |>
  req_url_path_append("/Login/Autenticar") |>
  req_url_query(token = Sys.getenv("API_OLHO_VIVO")) |>
  # necessário para fazer com que a requisição seja POST
  req_body_form(x = NULL)

resp_login <- req_login |>
  #req_verbose() |>
  req_perform()

# ok!
resp_login |>
  resp_body_json()

req_busca <- req_base |>
  req_url_path_append("Posicao")

resp_busca <- req_busca |>
  req_perform()

# mesmo assim nao deu!
# precisamos guardar os cookies da autenticacao

req_base <- u_sptrans |>
  request() |>
  # aqui está o cookie!
  req_cookie_preserve(tempfile())

req_base

req_login <- req_base |>
  req_url_path_append("/Login/Autenticar") |>
  req_url_query(token = Sys.getenv("API_OLHO_VIVO")) |>
  # necessário para fazer com que a requisição seja POST
  req_body_form(x = NULL)

resp_login <- req_login |>
  req_perform()

# ok!
resp_login |>
  resp_body_json()

req_busca <- req_base |>
  req_url_path_append("Posicao")

# agora foi!
resp_busca <- req_busca |>
  req_perform()

da_posicoes <- resp_busca |>
  resp_body_json(simplifyDataFrame = TRUE) |>
  pluck("l") |>
  tibble::as_tibble()

## Aplicação: mapa das posições

# cada linha da base é uma linha de ônibus,
# e a coluna vs guarda a posição dos ônibus
da_posicoes

# base desaninhada
da_posicoes_onibus <- da_posicoes |>
  unnest(vs)

# visualizacao! pacote leaflet
library(leaflet)

da_posicoes_onibus |>
  mutate(label = str_glue(
    "Linha: {c}<br>De: {lt0}<br>Para: {lt1}"
  )) |>
  leaflet() |>
  addTiles() |>
  addMarkers(
    ~px, ~py,
    popup = ~label,
    clusterOptions = markerClusterOptions()
  )
