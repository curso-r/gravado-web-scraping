# %%
import requests
import pandas as pd
import json

# cep ----------------------------------------------------------------

# %%
u_base = 'https://brasilapi.com.br/api'
endpoint_cep = '/cep/v1/'

# vamos gerar um CEP válido aqui: https://www.geradordecep.com.br
cep = '89010025'

u_cep = u_base + endpoint_cep + cep
r_cep = requests.get(u_cep)
r_cep

# %%
print(r_cep.text)

print(r_cep.json())

print(r_cep.content)

# agora vamos pesquisar na tabela FIPE ---------------------------------------

# %%

endpoint_fipe = '/fipe/marcas/v1/'
tipo_veiculo = 'carros'

u_fipe = u_base + endpoint_fipe + tipo_veiculo

r_fipe = requests.get(u_fipe)

## transfomando resultado em um DataFrame
# %%
df = pd.DataFrame(r_fipe.json())
df

## salvando em um arquivo json
# %%
r_fipe = requests.get(u_fipe)
with open('fipe.json', 'wb') as f:
  f.write(r_fipe.content)

## salvando em um arquivo csv
# %%
df.to_csv('fipe.csv', index=False)

## e o parâmetro?

# %%
endpoint_fipe_tabelas = '/fipe/tabelas/v1'
u_fipe_tabelas = u_base + endpoint_fipe_tabelas
r_fipe_tabelas = requests.get(u_fipe_tabelas)

tabelas = pd.DataFrame(r_fipe_tabelas.json())
tabelas

## chamando com um parâmetro

query_fipe = {'tabela_referencia': 270}

r_fipe = requests.get(u_fipe, params=query_fipe)

pd.DataFrame(r_fipe.json())

# preço de um carro específico --------------------------------------------

## infelizmente ainda não dá para pegar a lista de carros pela Brasil API
## https://github.com/BrasilAPI/BrasilAPI/issues/373

## Mas nós podemos pegar aqui: https://www.tabelafipebrasil.com/fipe/carros

# %%
endpoint_preco = '/fipe/preco/v1/'
cod_veiculo = '004515-2'
u_preco = u_base + endpoint_preco + cod_veiculo

r_preco = requests.get(u_preco)

pd.DataFrame(r_preco.json())

## agora vamos ver o preço do carro em outra tabela

query_preco = {'tabela_referencia': 270}

r_preco = requests.get(u_preco, params=query_preco)

pd.DataFrame(r_preco.json())

## aplicação: analisar o preço do carro 0km em cada mês entre 2022 e 2024

# %%

tabelas_filtrado = tabelas[tabelas['codigo'] >= 281]
tabelas_filtrado

# %%
df_lista = []

for tab in tabelas_filtrado['codigo']:
  query_preco = {'tabela_referencia': tab}
  r_preco = requests.get(u_preco, params=query_preco)
  df_preco = pd.DataFrame(r_preco.json()).query('anoModelo == 32000')
  df_preco['tabela_referencia'] = tab
  df_lista.append(df_preco)

df_preco = pd.concat(df_lista)
df_preco