# Focos de calor no Distrito Federal — 2025

Análise da distribuição espacial e temporal dos focos de calor detectados no Distrito Federal em 2025, com dados do Programa Queimadas do INPE e processamento em PostgreSQL/PostGIS e QGIS.

O projeto integra organização de dados, criação de um banco espacial, consultas SQL, análise de concentração por Kernel e elaboração de um mapa temático.

## Objetivo

Identificar os períodos com maior número de detecções e visualizar sua concentração espacial no Distrito Federal, demonstrando um fluxo de trabalho entre banco de dados geográfico e ferramentas de geoprocessamento.

## Dados utilizados

| Informação | Descrição |
|---|---|
| Fonte dos focos de calor | Programa Queimadas — INPE |
| Área de estudo | Distrito Federal |
| Período | Janeiro a dezembro de 2025 |
| Satélite selecionado | AQUA_M-T |
| Total de detecções analisadas | 234 |
| Limite territorial | IBGE — malha de Unidades da Federação de 2024 |
| Base de imagem | Esri World Imagery |

Os registros incluem data e hora, satélite, localização, bioma, precipitação, dias sem chuva, risco de fogo e potência radiativa do fogo (FRP).

## Ferramentas

- **PostgreSQL:** armazenamento e consultas.
- **PostGIS:** criação e gerenciamento das geometrias.
- **SQL:** transformação, verificação e agregação dos registros.
- **QGIS:** processamento espacial, análise Kernel e composição cartográfica.

## Metodologia

1. Importação do CSV em uma tabela intermediária.
2. Conversão dos campos para os tipos adequados.
3. Criação da tabela `focos_2025` e das geometrias de pontos a partir de longitude e latitude, em WGS 84 — EPSG:4326.
4. Criação de índice espacial GiST.
5. Verificação dos registros e agregação mensal por consultas SQL.
6. Conexão do banco ao QGIS e reprojeção para SIRGAS 2000 / UTM zona 23S — EPSG:31983.
7. Estimativa da concentração espacial dos focos por Kernel.
8. Recorte do resultado ao limite do Distrito Federal.
9. Elaboração do mapa, do gráfico mensal e do estudo de caso.

### Configuração da análise Kernel

| Parâmetro | Valor |
|---|---|
| Raio de influência | 3.000 m |
| Tamanho do pixel | 100 m |
| Função Kernel | Quártica |
| Ponderação | Sem campo de peso |
| Saída | Valor bruto — Raw |

A superfície resultante representa a concentração relativa das detecções conforme os parâmetros adotados. Seus valores não correspondem diretamente a focos por km².

## Resultados

Foram analisadas **234 detecções** do satélite AQUA_M-T.

| Mês | Detecções |
|---|---:|
| Janeiro | 0 |
| Fevereiro | 1 |
| Março | 2 |
| Abril | 0 |
| Maio | 4 |
| Junho | 13 |
| Julho | 35 |
| Agosto | 75 |
| Setembro | 70 |
| Outubro | 33 |
| Novembro | 1 |
| Dezembro | 0 |
| **Total** | **234** |

- **Agosto** apresentou o maior número de detecções: 75.
- **Agosto e setembro** reuniram aproximadamente 62% do total.
- **Julho a outubro** concentraram aproximadamente 91% das detecções.

O mapa Kernel permite visualizar os núcleos de maior concentração espacial no período analisado.

## Limitações

- Um foco de calor é uma detecção por satélite e não equivale necessariamente a um incêndio individual.
- As detecções não permitem calcular diretamente a extensão da área queimada.
- A análise utiliza apenas o satélite AQUA_M-T e não reúne todas as detecções de todos os satélites disponíveis.
- A superfície Kernel depende do raio, da função e da resolução escolhidos.
- O pixel de 100 m define a resolução da superfície gerada, não a precisão de localização das detecções.
- Os resultados não estabelecem as causas dos eventos nem identificam, por si só, danos ambientais.

## Materiais do projeto

- Estudo de caso em PDF.
- Mapa de concentração espacial dos focos de calor.
- Gráfico e tabela de distribuição mensal.
- Scripts SQL de organização e consulta dos dados.

Os scripts disponibilizados documentam o fluxo de trabalho. Os trechos de criação e importação devem ser revisados e adaptados ao ambiente antes da execução.

## Competências demonstradas

- Organização e transformação de dados CSV.
- Modelagem de dados espaciais em PostgreSQL/PostGIS.
- Criação de geometrias e índices espaciais.
- Consultas SQL e agregação temporal.
- Integração entre banco espacial e QGIS.
- Reprojeção e processamento de dados geográficos.
- Análise de concentração espacial por Kernel.
- Elaboração de mapas temáticos e comunicação dos resultados.

## Fontes

- [Programa Queimadas — INPE](https://terrabrasilis.dpi.inpe.br/queimadas/portal/)
- [Malhas territoriais — IBGE](https://www.ibge.gov.br/geociencias/organizacao-do-territorio/malhas-territoriais.html)
- [Documentação do QGIS](https://docs.qgis.org/)
- [Documentação do PostGIS](https://postgis.net/documentation/)

## Autoria

**Ivana Bezerra**  
Portfólio de Geoprocessamento e Sensoriamento Remoto — 2026.
