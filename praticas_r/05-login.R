library(httr)

u_scrape_base <- "https://quotes.toscrape.com"
u_scrape <- paste0(u_scrape_base, "/login")

r0_scrape <- GET(u_scrape)

token <- r0_scrape |> 
  content("text") |> 
  stringr::str_extract("[a-zA-Z]{20,}")

body_scrape <- list(
  username = "julio",
  password = "asdasdasdasd",
  csrf_token = token
)

r_scrape <- POST(
  u_scrape, 
  body = body_scrape,
  encode = "form"
)

r_pag_inicial <- GET(
  u_scrape_base,
  write_disk("dados/quotes/pag_inicial.html", overwrite = TRUE)
)
