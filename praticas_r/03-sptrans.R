library(tidyverse)
library(httr)

u_sptrans <- "https://api.olhovivo.sptrans.com.br/v2.1"
endpoint <- "/Posicao"

u_sptrans_posicao <- paste0(u_sptrans, endpoint)

r_posicao <- GET(u_sptrans_posicao)
r_posicao |> 
  content()

# usethis::edit_r_environ(scope = "project")

# api_key <- "4af5e3112da870ac5708c48b7a237b30206806f296e1d302e4cb611660e2e03f"
api_key <- Sys.getenv("API_OLHO_VIVO")

endpoint_login <- "/Login/Autenticar"
u_sptrans_login <- paste0(u_sptrans, endpoint_login)

q_sptrans_login <- list(token = api_key)

r_sptrans_login <- POST(u_sptrans_login, query = q_sptrans_login)
r_sptrans_login |> 
  content()

# isso só funciona porque o httr guarda informações da sessão nos cookies
r_posicao <- GET(u_sptrans_posicao)

d_posicoes <- r_posicao |> 
  content(simplifyDataFrame = TRUE) |> 
  pluck("l") |> 
  as_tibble()

d_posicoes$vs[[1]]

d_posicoes |> 
  unnest(vs) |> 
  ggplot(aes(x = px, y = py)) +
  geom_point() +
  coord_equal()
