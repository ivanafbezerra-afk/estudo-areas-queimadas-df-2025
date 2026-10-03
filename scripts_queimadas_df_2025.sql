-- QUEIMADAS DF 2025 | Ivana Bezerra
-- Consolidacao reconstruida a partir das etapas do projeto.
-- Nao e uma exportacao literal do historico do pgAdmin.
-- Banco utilizado: queimada_df. Tabela final: public.focos_2025.
-- Por padrao, este arquivo executa apenas consultas de leitura.
-- Criacao/importacao ao final: referencia para um banco NOVO.

-- 1. Conferir estrutura existente
SELECT column_name, data_type, udt_name
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'focos_2025'
ORDER BY ordinal_position;

-- 2. Total de registros (resultado observado: 234)
SELECT COUNT(*) AS total_deteccoes FROM public.focos_2025;

-- 3. Satelites (resultado observado: AQUA_M-T)
SELECT satelite, COUNT(*) AS deteccoes
FROM public.focos_2025
GROUP BY satelite ORDER BY deteccoes DESC;

-- 4. Periodo e localidade
SELECT MIN(datahora_utc) AS primeira_deteccao,
       MAX(datahora_utc) AS ultima_deteccao
FROM public.focos_2025;

SELECT pais, estado, municipio, COUNT(*) AS deteccoes
FROM public.focos_2025
GROUP BY pais, estado, municipio ORDER BY deteccoes DESC;

-- 5. Conferencia das geometrias
SELECT ST_SRID(geom) AS srid, ST_GeometryType(geom) AS tipo,
       COUNT(*) AS quantidade
FROM public.focos_2025 GROUP BY 1, 2;

SELECT COUNT(*) FILTER (WHERE geom IS NULL) AS geometrias_nulas,
       COUNT(*) FILTER (WHERE NOT ST_IsValid(geom)) AS geometrias_invalidas,
       COUNT(*) FILTER (WHERE latitude NOT BETWEEN -90 AND 90
                         OR longitude NOT BETWEEN -180 AND 180)
           AS coordenadas_fora_do_intervalo
FROM public.focos_2025;

-- 6. Contagem mensal, incluindo meses sem deteccoes
WITH meses AS (
    SELECT generate_series(1, 12) AS mes
), contagens AS (
    SELECT EXTRACT(MONTH FROM datahora_utc)::integer AS mes,
           COUNT(*) AS deteccoes
    FROM public.focos_2025
    WHERE datahora_utc >= TIMESTAMP '2025-01-01'
      AND datahora_utc < TIMESTAMP '2026-01-01'
    GROUP BY 1
)
SELECT m.mes,
       (ARRAY['Jan','Fev','Mar','Abr','Mai','Jun',
              'Jul','Ago','Set','Out','Nov','Dez'])[m.mes] AS mes_nome,
       COALESCE(c.deteccoes, 0) AS deteccoes
FROM meses m LEFT JOIN contagens c USING (mes)
ORDER BY m.mes;
-- Esperado: 0,1,2,0,4,13,35,75,70,33,1,0 (total 234).
-- Exportar este resultado pelo pgAdmin para focos_mensais_df_2025.csv.

-- 7. Indicadores derivados da contagem mensal
WITH base AS (
    SELECT EXTRACT(MONTH FROM datahora_utc)::integer AS mes
    FROM public.focos_2025
    WHERE datahora_utc >= TIMESTAMP '2025-01-01'
      AND datahora_utc < TIMESTAMP '2026-01-01'
)
SELECT COUNT(*) AS total,
       COUNT(*) FILTER (WHERE mes IN (8,9)) AS agosto_setembro,
       ROUND(100.0 * COUNT(*) FILTER (WHERE mes IN (8,9))
             / NULLIF(COUNT(*), 0), 2) AS percentual_agosto_setembro,
       COUNT(*) FILTER (WHERE mes BETWEEN 7 AND 10) AS julho_outubro,
       ROUND(100.0 * COUNT(*) FILTER (WHERE mes BETWEEN 7 AND 10)
             / NULLIF(COUNT(*), 0), 2) AS percentual_julho_outubro
FROM base;

-- 8. REFERENCIA DE REPRODUCAO: criacao e importacao (INATIVO)
-- Os tipos abaixo sao uma proposta reconstruida; conferir o bloco 1
-- para documentar os tipos exatos do banco existente.
-- NAO descomentar e executar no banco atual.
/*
CREATE EXTENSION IF NOT EXISTS postgis;

CREATE TABLE public.focos_csv (
    datahora TEXT, satelite TEXT, pais TEXT, estado TEXT,
    municipio TEXT, bioma TEXT, dias_sem_chuva TEXT,
    precipitacao TEXT, risco_fogo TEXT, frp TEXT,
    latitude TEXT, longitude TEXT
);

CREATE TABLE public.focos_2025 (
    datahora_utc TIMESTAMP WITHOUT TIME ZONE,
    satelite TEXT, pais TEXT, estado TEXT, municipio TEXT, bioma TEXT,
    dias_sem_chuva INTEGER, precipitacao DOUBLE PRECISION,
    risco_fogo DOUBLE PRECISION, frp DOUBLE PRECISION,
    latitude DOUBLE PRECISION, longitude DOUBLE PRECISION,
    geom geometry(Point, 4326)
);

-- No pgAdmin: importar bdqueimadas_2025-01-01_2025-12-31.csv
-- em public.focos_csv (CSV, cabecalho, UTF-8, separador virgula).
-- Usar as 12 colunas na ordem do arquivo.
-- A importacao pela interface nao e um comando SQL registrado aqui.

INSERT INTO public.focos_2025 (
    datahora_utc, satelite, pais, estado, municipio, bioma,
    dias_sem_chuva, precipitacao, risco_fogo, frp,
    latitude, longitude, geom
)
SELECT
    REPLACE(BTRIM(datahora), CHR(65279), '')::timestamp,
    BTRIM(satelite), BTRIM(pais), BTRIM(estado),
    BTRIM(municipio), BTRIM(bioma),
    NULLIF(BTRIM(dias_sem_chuva), '')::integer,
    NULLIF(BTRIM(precipitacao), '')::double precision,
    NULLIF(BTRIM(risco_fogo), '')::double precision,
    NULLIF(BTRIM(frp), '')::double precision,
    NULLIF(BTRIM(latitude), '')::double precision,
    NULLIF(BTRIM(longitude), '')::double precision,
    ST_SetSRID(ST_MakePoint(
        NULLIF(BTRIM(longitude), '')::double precision,
        NULLIF(BTRIM(latitude), '')::double precision
    ), 4326)
FROM public.focos_csv;
-- O CSV utilizado ja correspondia ao recorte escolhido do projeto.
-- Conferir quantidade, satelite, localidade e periodo apos importar.
-- Nao repetir INSERT: ele duplicaria os registros.
-- Valores -999 sao preservados como no dado importado;
-- nao devem ser interpretados como medidas validas em analises.

CREATE INDEX focos_2025_geom_gix
    ON public.focos_2025 USING GIST (geom);
ANALYZE public.focos_2025;
*/

-- 9. ETAPAS REALIZADAS NO QGIS (nao sao SQL)
-- Limite: BR_UF_2024 -> selecionar DF -> exportar limite_df.gpkg.
-- Reprojetar/exportar pontos para focos_2025_utm.gpkg, EPSG:31983.
-- Kernel: raio 3000 m, pixel 100 m, funcao quartica,
-- saida Raw, sem ponderacao e sem campo de raio variavel.
-- Recortar densidade pelo limite do DF, mantendo resolucao 100 m,
-- NoData -9999 -> densidade_focos_df_2025_recorte.tif.
-- Layout: satelite Esri, mascara externa, grade UTM e elementos.
-- Exportacao: Densidade_Focos_DF_2025.png e PDF.
-- Indice Kernel Raw nao representa deteccoes/km2 nem area queimada.
-- Nao ha SQL original de view recuperado: nenhuma view foi inventada.
