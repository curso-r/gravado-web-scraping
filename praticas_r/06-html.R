library(xml2)
library(rvest)

html <- read_html("dados/html/html_exemplo.html")

# extrair tags
# <p>
xml_find_all(html, "/html/body/p")

nodes <- xml_find_all(html, "//p")
nodes[[1]]
primeiro <- xml_find_first(html, "//p")

# agora vamos extrair texto
textos <- xml_text(nodes)

# agora vamos extrair os atributos
xml_attrs(nodes)
xml_attr(nodes, "style")

# RVEST

nodes <- html_elements(html, xpath = "//p")
primeiro <- html_element(html, xpath = "//p")

html_text(nodes)
html_attr(nodes, "style")
