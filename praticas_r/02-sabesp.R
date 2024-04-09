# 1. colete os dados de mananciais da sabesp
u_sabesp <- "http://mananciais.sabesp.com.br/api/Mananciais/ResumoSistemas/2022-01-15"
r_sabesp <- httr::GET(u_sabesp, httr::config(ssl_verifypeer = FALSE))
results <- httr::content(r_sabesp, simplifyDataFrame = TRUE)
results$ReturnObj$sistemas

# httr
req <- u_sabesp |> 
  httr2::request()

resp <- req |> 
  httr2::req_perform()

result <- resp |> 
  httr2::resp_body_json(simplifyDataFrame = TRUE)

result$ReturnObj$sistemas
