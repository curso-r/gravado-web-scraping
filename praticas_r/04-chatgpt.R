
openai_subscription_key <- Sys.getenv("OPENAI_API_KEY")

endpoint <- "https://api.openai.com/v1/chat/completions"

# Create authorization header

headers <- httr::add_headers(
  c("Authorization" = paste0("Bearer ", openai_subscription_key))
)

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

# Create payload
payload <- list(
  model = "gpt-3.5-turbo",
  messages = messages,
  temperature = 1
)

# Make POST request
response <- httr::POST(
  url = endpoint,
  body = payload,
  headers,
  encode = "json"
)

response |> 
  httr::content() |> 
  purrr::pluck("choices", 1, "message", "content") |> 
  cat()
