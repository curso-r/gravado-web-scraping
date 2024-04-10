library(httr)
library(httr2)
library(tidyverse)

# Coletando dados da Sabesp

u_sabesp_base <- "https://mananciais.sabesp.com.br/api/Mananciais/ResumoSistemas/"
data <- "2022-01-15"
u_sabesp <- paste0(u_sabesp_base, data)

# parâmetro ssl_verifypeer = FALSE para ignorar a verificação do certificado SSL
# para esse exemplo, não é necessário no Windows, mas no Linux sim
r_sabesp <- GET(u_sabesp, config(ssl_verifypeer = FALSE))

result <- content(r_sabesp, simplifyDataFrame = TRUE)
result$ReturnObj$sistemas

# usando pluck
result |>
  pluck("ReturnObj", "sistemas")

# httr2

req <- u_sabesp_base |>
  request() |>
  req_url_path_append("2022-01-15") |>
  req_options(ssl_verifypeer = FALSE)

resp <- req |>
  req_perform()

result <- resp |>
  resp_body_json(simplifyDataFrame = TRUE)

result |>
  pluck("ReturnObj", "sistemas")

## Aplicação: pegar o volume de água do Cantareira no ano de 2023

pegar_volume_cantareira_dia <- function(dia) {
  u_sabesp_base |>
    request() |>
    req_url_path_append(dia) |>
    req_options(ssl_verifypeer = FALSE) |>
    req_perform() |>
    resp_body_json(simplifyDataFrame = TRUE) |>
    pluck("ReturnObj", "sistemas") |>
    # limpa os nomes
    janitor::clean_names() |>
    # apenas o Cantareira
    filter(nome == "Cantareira") |>
    # seleciona as colunas com modificação
    mutate(data = dia, volume_operacional, volume_porcentagem, .keep = "none")
}

meses <- seq(as.Date("2023-01-01"), as.Date("2023-12-31"), by = "1 month")

da_volume <- map(meses, pegar_volume_cantareira_dia, .progress = TRUE) |>
  list_rbind()

da_volume
