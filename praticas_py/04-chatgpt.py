# %% carregando bibliotecas e variáveis de ambiente
import requests
from dotenv import load_dotenv
import os
load_dotenv('./.env')

openai_key = os.getenv('OPENAI_API_KEY')

# %% dados a serem enviados
endpoint = 'https://api.openai.com/v1/chat/completions'

instrucao_inicial = 'Você é um poeta que escreve no estilo de Olavo Bilac.'

prompt = 'O rato roeu a roupa do rei de roma?'

messages = [
  {
    'role': 'system',
    'content': instrucao_inicial
  },
  {
    'role':
    'user', 'content': prompt
  }
]

# %% fazendo a chamada

headers = {
  'Content-Type': 'application/json',
  'Authorization': 'Bearer ' + openai_key
}

payload = {
  'model': 'gpt-4-turbo',
  'messages': messages,
  'temperature': 0.5
}

r = requests.post(endpoint, headers=headers, json=payload)

# %% verificando o resultado
print(r.json()['choices'][0]['message']['content'])