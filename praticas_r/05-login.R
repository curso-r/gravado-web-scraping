# url de login
u_scrape_base <- "https://quotes.toscrape.com"
u_scrape <- paste0(u_scrape_base, "/login")

# pega página de login para obter token
r0_scrape <- httr::GET(u_scrape)

# pega o token de dentro da página

# forma 1: usando stringr
value <- r0_scrape |> 
  httr::content("text") |> 
  stringr::str_extract("(?<=csrf_token.{1,100}value=\")[^\"]+")

# forma 2: usando xml2 (veremos na próxima aula!)
value <- r0_scrape |> 
  xml2::read_html() |> 
  xml2::xml_find_all("//*[@name='csrf_token']") |> 
  xml2::xml_attr("value")

# monta o corpo do login
body_scrape <- list(
  username = "meulogin",
  password = "sdfsdfsdf",
  csrf_token = value
)

# faz o login
r_scrape <- httr::POST(
  u_scrape, 
  body = body_scrape
)

# depois de fazer o login, vamos acessar a página principal para testar

# salva em um arquivo temporário para abrir depois
tmp <- fs::file_temp(ext = ".html")
httr::GET(
  "https://quotes.toscrape.com/",
  httr::write_disk(tmp, TRUE)
)
browseURL(tmp)
