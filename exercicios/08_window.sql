-- Saldo de pontos atualizados de cada usuário
WITH 

tb_cliente_dia AS (

SELECT  idCliente,
        substr(DtCriacao,1,10) AS dtDia,
        sum(qtdePontos) AS totalPontos,
        sum(CASE WHEN qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS PontosPos

FROM transacoes

GROUP BY idCliente, dtDia

)

SELECT  *,
        sum(totalPontos) OVER (PARTITION BY idCliente ORDER BY dtDia) AS saldoPontos,
        sum(PontosPos) OVER (PARTITION BY idCliente ORDER BY dtDia) AS totalPontosP

FROM tb_cliente_dia