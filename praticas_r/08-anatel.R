library(httr)

u_anatel <- "https://anatel.gov.br/biblioteca/asp/resultadoFrame.asp"

b_anatel <- list(
  "leg_campo1" = "decisão",
  "leg_ordenacao" = "publicacaoDESC",
  "leg_normas" = "-1",
  "leg_numero" = "",
  "ano_ass" = "",
  "leg_orgao_origem" = "-1",
  "sel_data_ass" = "0",
  "data_ass_inicio" = "",
  "data_ass_fim" = "",
  "leg_campo5" = "",
  "sel_data_pub" = "0",
  "data_pub_inicio" = "",
  "data_pub_fim" = "",
  "leg_campo6" = "",
  "processo" = "",
  "leg_campo4" = "",
  "leg_autoria" = "",
  "leg_numero_projeto" = "",
  "leg_campo2" = "",
  "leg_bib" = "",
  "submeteu" = "legislacao"
)

res <- POST(
  u_anatel, 
  body = b_anatel,
  encode = "form"
)

res$status_code
res |> 
  httr::content("text")
