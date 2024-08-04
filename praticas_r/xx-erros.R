library(purrr)
library(httr)

pegar_site <- function(x) {
  r <- GET(x)
  r$status_code
}

pegar_site("https://google.com")
pegar_site("https://errado.site")

## base R
# try()
# tryCatch()

possibly()
safely()

possivelmente_pegar_site <- possibly(pegar_site, otherwise = 0)

possivelmente_pegar_site("https://google.com")
possivelmente_pegar_site("https://errado.site")

safe_pegar_site <- safely(pegar_site, otherwise = 0)

safe_pegar_site("https://google.com")
safe_pegar_site("https://errado.site")

