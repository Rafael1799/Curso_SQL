-- Quantidade de transações acumuladas ao longo do tempo (Diario)?

DROP TABLE IF EXISTS relatorio_diario;

CREATE TABLE relatorio_diario AS

WITH

tb_diario AS (

SELECT  substr(DtCriacao,1,10) AS dtDia,
        count(DISTINCT IdTransacao) AS qtTransacao

FROM transacoes

GROUP BY dtDia
ORDER BY dtDia

),

tb_acum AS (

SELECT  *,
        sum(qtTransacao) OVER (ORDER BY dtDia) AS qtTransacaoAcum

FROM tb_diario

)

SELECT *
FROM tb_acum
;

SELECT * FROM relatorio_diario;
