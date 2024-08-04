library(httr)

# montando a requisição GET

dia <- "2024-07-17"

u_base <- "https://mananciais.sabesp.com.br/api/Mananciais/ResumoSistemas/"

u_dia <- paste0(u_base, dia)

r_dia <- GET(u_dia)

l_dia <- content(r_dia, simplifyDataFrame = TRUE)

l_dia$ReturnObj$sistemas |> 
  tibble::tibble()

d_dia <- l_dia |> 
  purrr::pluck("ReturnObj", "sistemas") |> 
  tibble::tibble() |> 
  janitor::clean_names()

sabesp_baixar_dia <- function(dia) {
  u_base <- "https://mananciais.sabesp.com.br/api/Mananciais/ResumoSistemas/"
  u_dia <- paste0(u_base, dia)
  r_dia <- GET(u_dia)
  l_dia <- content(r_dia, simplifyDataFrame = TRUE)
  d_dia <- l_dia |> 
    purrr::pluck("ReturnObj", "sistemas") |> 
    tibble::tibble() |> 
    janitor::clean_names()
  d_dia
}

sabesp_baixar_dia("2024-05-02")
