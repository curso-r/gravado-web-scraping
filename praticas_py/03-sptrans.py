# %% importando bibliotecas
import requests
import pandas as pd

# Coletando dados da SPTrans

# %% acessando a API

u_sptrans_base = 'http://api.olhovivo.sptrans.com.br/v2.1'
endpoint = '/Posicao'

u_sptrans_busca = u_sptrans_base + endpoint

r_sptrans = requests.get(u_sptrans_busca)

# precisamos de autorização!
print(r_sptrans.status_code)
print(r_sptrans.text)

# %% armazenando api keys

# Obtenha a API key e coloque no seu ambiente em um arquivo .env
# com a variável API_OLHO_VIVO, por exemplo
# em seguida, use o pacote python-dotenv para carregar a variável
# do ambiente

from dotenv import load_dotenv
import os
load_dotenv('./.env')

api_key = os.getenv('API_OLHO_VIVO')
print(api_key)

# %% acessando a API com autorização

# caso voce nao queira/nao tenha conseguido fazer uma conta
api_key = '4af5e3112da870ac5708c48b7a237b30206806f296e1d302e4cb611660e2e03f'

# %% acessando a API com autorização
u_sptrans_login = u_sptrans_base + '/Login/Autenticar'
params = {'token': api_key}

r_sptrans_login = requests.post(u_sptrans_login, params=params)

# agora deu certo!
print(r_sptrans_login.status_code)
print(r_sptrans_login.text)

# %%  o python requests não guarda o cookie da sessão automaticamente

r_sptrans_busca = requests.get(u_sptrans_busca)

r_sptrans_busca.json()

# %% precisamos, então, criar uma sessão

s = requests.Session()

r_sptrans_login = s.post(u_sptrans_login, params=params)

# agora, como estamos na mesma sessão, a autenticação é mantida
r_sptrans_busca = s.get(u_sptrans_busca)

r_sptrans_busca.json()

# %% coletando dados
import json
df = pd.DataFrame(r_sptrans_busca.json()['l'])

# cada linha da base é uma linha de ônibus,
# e a coluna vs guarda a posição dos ônibus
df

# %% obtendo coluna vs, que está aninhada

df_bus = pd.json_normalize(r_sptrans_busca.json()['l'], 'vs', meta=['cl'])

df_bus

# %% juntando com a base original

df_final = df_bus.merge(df, on='cl')

df_final.info()

# %%
import folium
from folium.plugins import MarkerCluster

# criando um mapa
m = folium.Map(
  location=[df_final['py'].mean(), df_final['px'].mean()],
  zoom_start=5
)

# criando um cluster de marcadores
marker_cluster = MarkerCluster().add_to(m)

# adicionando marcadores
for idx, row in df_final.iterrows():
  folium.Marker(location=[row['py'], row['px']], popup=row['c']).add_to(marker_cluster)

# mostra o mapa
m