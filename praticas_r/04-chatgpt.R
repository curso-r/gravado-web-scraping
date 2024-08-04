# usethis::edit_r_environ("project")

library(httr)

u_base <- "https://api.openai.com/v1/"
endpoint <- "chat/completions"
u_completions <- paste0(u_base, endpoint)

api_key <- Sys.getenv("OPENAI_API_KEY")

headers <- add_headers(
  Authorization = paste0("Bearer ", api_key)
)

# data = '{\n     "model": "gpt-4o-mini",\n     "messages": [{"role": "user", "content": "Say this is a test!"}],\n     "temperature": 0.7\n   }'

data <- list(
  model = "gpt-4o-mini",
  messages = list(
    list(
      role = "user",
      "content" = "Diga que isso é um teste!!"
    )
  ),
  temperature = 0.7
)

res <- POST(
  u_completions, 
  headers, 
  #content_type_json(),
  body = data,
  encode = "json"
)

res |> 
  content() |> 
  purrr::pluck("choices", 1, "message", "content")
