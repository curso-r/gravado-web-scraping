library(httr)
# install.packages("remotes")
# remotes::install_github("decryptr/captcha")
library(captcha)

u_tjba <- "http://esaj.tjba.jus.br/cpopg/search.do"
processo <- "0001351-58.2012.8.05.0006"
parte_inicial <- stringr::str_sub(processo, 1, 15)
parte_final <- stringr::str_sub(processo, -4, -1)

r0_tjba <- GET(u_tjba)

u_captcha <- "http://esaj.tjba.jus.br/cpopg/imagemCaptcha.do"
r_captcha <- GET(
  u_captcha,
  write_disk("dados/tjba/captcha.png", TRUE),
  config(ssl_verifypeer = FALSE)
)

cap <- read_captcha("dados/tjba/captcha.png")

cap |> 
  plot()

## solução manual
## vl_captcha <- captcha_annotate(cap)

modelo <- captcha_load_model("esaj")

vl_captcha <- decrypt("dados/tjba/captcha.png", modelo)

params <- list(
  dadosConsulta.localPesquisa.cdLocal = "-1",
  cbPesquisa = "NUMPROC",
  dadosConsulta.tipoNuProcesso = "UNIFICADO",
  numeroDigitoAnoUnificado = parte_inicial,
  foroNumeroUnificado = parte_final,
  dadosConsulta.valorConsultaNuUnificado = processo,
  dadosConsulta.valorConsulta = "",
  vlCaptcha = vl_captcha
)

res <- GET(
  u_tjba, query = params,
  write_disk("dados/tjba/result.html")
)
