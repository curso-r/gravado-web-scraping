# %% importando bibliotecas
import requests
import pandas as pd

# Coletando dados da Sabesp
# %% acessando a API

u_sabesp_base = 'https://mananciais.sabesp.com.br/api/Mananciais/ResumoSistemas/'
data = '2022-01-15'

u_sabesp = u_sabesp_base + data

# parâmetro verify: não verificar certificado SSL
# para esse exemplo, não é necessário no Windows, mas no Linux sim
r_sabesp = requests.get(u_sabesp, verify=False)

# %% para não mostrar o warning de certificado SSL:
requests.packages.urllib3.disable_warnings()
r_sabesp = requests.get(u_sabesp, verify=False)

# %% visualizando o resultado
result = r_sabesp.json()
result['ReturnObj']['sistemas']

# %% transformando em um DataFrame
df_sabesp = pd.DataFrame(result['ReturnObj']['sistemas'])
df_sabesp

# Aplicação: pegar o volume de água do Cantareira no ano de 2023

# %% criando um range de datas

datas = pd.date_range(start='2023-01-01', end='2023-12-01', freq='MS')
datas

# %% iterando sobre as datas
volumes = []

for data in datas:
  print('baixando dados de', data.strftime('%Y-%m-%d'), '...')
  # formatando a data para o padrão yyyy-mm-dd
  dia = data.strftime('%Y-%m-%d')
  u_sabesp = u_sabesp_base + dia
  r_sabesp = requests.get(u_sabesp, verify=False)
  result = r_sabesp.json()
  df = pd.DataFrame(result['ReturnObj']['sistemas'])
  # transforma a base de dados
  df_filtrado = (
    df
    .query('Nome=="Cantareira"')
    .filter(['VolumeOperacional', 'VolumePorcentagem'])
    .assign(data=dia)
  )
  volumes.append(df_filtrado)

df_volumes = pd.concat(volumes)

df_volumes
