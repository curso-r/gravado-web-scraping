library(httr)
library(httr2)
library(purrr)

openai_subscription_key <- Sys.getenv("OPENAI_API_KEY")

endpoint <- "https://api.openai.com/v1/chat/completions"

instrucao_inicial <- "Você é um poeta que escreve no estilo de Olavo Bilac."

prompt <- "O rato roeu a roupa do rei de roma?"

messages <- list(
  list(
    role = "system",
    content = instrucao_inicial
  ),
  list(
    role = "user",
    content = prompt
  )
)

# httr ---------------------------------------------------------------

headers <- add_headers(
  "Authorization" = paste0("Bearer ", openai_subscription_key)
)

# Criando o payload da requisição POST (body)
payload <- list(
  model = "gpt-4-turbo",
  messages = messages,
  temperature = 0.5
)

# Fazendo a requisição. Note que precisamos do parâmetro `encode = "json"`
response <- POST(
  url = endpoint,
  body = payload,
  headers,
  encode = "json"
)

response |>
  content() |>
  pluck("choices", 1, "message", "content") |>
  cat()

# com httr2 ---------------------------------------------------------------

req_headers()

# aqui, não precisamos do encode = "json" porque a função
# `req_body_json` já faz isso
req <- endpoint |>
  request() |>
  req_headers("Authorization" = paste0("Bearer ", openai_subscription_key)) |>
  req_body_json(payload)

resp <- req |>
  req_perform()

result <- resp |>
  resp_body_json() |>
  pluck("choices", 1, "message", "content") |>
  cat()
