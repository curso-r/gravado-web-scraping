library(webdriver)

pjs <- run_phantomjs()
ses <- Session$new(port = pjs$port)

u_pesqele <- "https://rseis.shinyapps.io/pesqEle/"

ses$go(u_pesqele)
ses$takeScreenshot()

elems <- ses$findElements(xpath = '//span[@class="info-box-number"]')
elems[[1]]$getText()

# Obter os valores que estão nos retângulos iniciais
numeros <- purrr::map_chr(elems, ~.x$getText())

# Filtrar os resultados para pesquisas presidenciais e obter novamente
radio <- ses$findElement(xpath = "//input[@name='abrangencia' and @value='nacionais']")
radio$click()
ses$takeScreenshot()

elems <- ses$findElements(xpath = '//span[@class="info-box-number"]')
elems[[1]]$getText()
numeros <- purrr::map_chr(elems, ~.x$getText())
html <- ses$getSource()

# Acessar a aba de empresas
elem <- ses$findElement(xpath = '//a[@href="#shiny-tab-empresas"]')
elem$click()

# Mostrar 100
elem <- ses$findElement(xpath = "//select[@name='DataTables_Table_0_length']/option[@value='100']")
elem$click()

# Parsear o HTML para extrair informações
html <- ses$getSource()
readr::write_file(html, "output/shiny_webdriver.html")

"output/shiny_webdriver.html" |>
  xml2::read_html() |>
  xml2::xml_find_first("//table[@id='DataTables_Table_0']") |>
  rvest::html_table() |>
  dplyr::rename_with(janitor::make_clean_names, replace = c("º" = ""))
