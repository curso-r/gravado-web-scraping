library(tidyverse)
library(httr)
library(rvest)

# com o httr

u_tjsp <- "https://esaj.tjsp.jus.br/cjsg/resultadoCompleta.do"

b_tjsp <- list(
  "conversationId" = "",
  "dados.buscaInteiroTeor" = "lol",
  "dados.pesquisarComSinonimos" = "S",
  "dados.pesquisarComSinonimos" = "S",
  "dados.buscaEmenta" = "",
  "dados.nuProcOrigem" = "",
  "dados.nuRegistro" = "",
  "agenteSelectedEntitiesList" = "",
  "contadoragente" = "0",
  "contadorMaioragente" = "0",
  "codigoCr" = "",
  "codigoTr" = "",
  "nmAgente" = "",
  "juizProlatorSelectedEntitiesList" = "",
  "contadorjuizProlator" = "0",
  "contadorMaiorjuizProlator" = "0",
  "codigoJuizCr" = "",
  "codigoJuizTr" = "",
  "nmJuiz" = "",
  "classesTreeSelection.values" = "",
  "classesTreeSelection.text" = "",
  "assuntosTreeSelection.values" = "",
  "assuntosTreeSelection.text" = "",
  "comarcaSelectedEntitiesList" = "",
  "contadorcomarca" = "0",
  "contadorMaiorcomarca" = "0",
  "cdComarca" = "",
  "nmComarca" = "",
  "secoesTreeSelection.values" = "",
  "secoesTreeSelection.text" = "",
  "dados.dtJulgamentoInicio" = "",
  "dados.dtJulgamentoFim" = "",
  "dados.dtPublicacaoInicio" = "",
  "dados.dtPublicacaoFim" = "",
  "dados.origensSelecionadas" = "T",
  "tipoDecisaoSelecionados" = "A",
  "dados.ordenarPor" = "dtPublicacao"
)

r_tjsp <- POST(u_tjsp, body = b_tjsp)

content(r_tjsp, "text")

baixar_pagina_tjsp <- function(pag) {
  Sys.sleep(1)
  u_tjsp_pag <- "https://esaj.tjsp.jus.br/cjsg/trocaDePagina.do?tipoDeDecisao=A&pagina=2&conversationId="
  
  # urltools::param_get(u_tjsp_pag) |> dput()
  
  q_tjsp_pag <- list(
    conversationId = "", 
    pagina = pag, 
    tipoDeDecisao = "A"
  )
  
  r_tjsp_pag <- GET(
    u_tjsp_pag, 
    query = q_tjsp_pag,
    write_disk(paste0("output/", pag, ".html"), overwrite = TRUE)
  )
  
}

content(r_tjsp_pag, "text") |> 
  stringr::str_extract("Resultados\\X{30}")

paginas <- 1:10
walk(paginas, baixar_pagina_tjsp)


# parsing -----------------------------------------------------------------



parse_tabela <- function(tab) {
  # tab <- lista_de_tabelas[[5]]
  tab_completa <- tab |> 
    mutate(X1 = str_squish(X1))
  tab_1st_row <- tab_completa |> 
    slice(1) |> 
    separate(
      X1, c("processo", "texto"), sep = " ",
      extra = "merge"
    ) |> 
    select(-X2)
  
  tab_others <- tab_completa |> 
    slice(-1) |> 
    select(-X2) |> 
    separate(
      X1, c("name", "value"), sep = ": ",
      extra = "merge"
    ) |> 
    pivot_wider() |> 
    janitor::clean_names()
  
  bind_cols(
    tab_1st_row,
    tab_others
  )
  
}

parse_pag <- function(arquivo) {
  # arquivo <- "output/4.html"
  
  # readr::guess_encoding(arquivo)
  lista_de_tabelas <- arquivo |> 
    xml2::read_html(encoding = "UTF-8") |> 
    xml2::xml_find_all("//tr[@class='fundocinza1']/td[2]/table") |> 
    html_table()
  
  lista_de_tabelas |> 
    map(parse_tabela) |> 
    list_rbind(names_to = "id_pag")
}

da_tjsp <- fs::dir_ls("output") |> 
  map(parse_pag, .progress = TRUE) |> 
  list_rbind(names_to = "file_pag")

dplyr::glimpse(da_tjsp)
