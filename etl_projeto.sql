WITH 

tb_transacoes AS (

    SELECT  IdTransacao,
            idcliente,
            qtdePontos,
            datetime(substr(DtCriacao,1,19)) AS DtCriacao,
            julianday('now') - julianday(substr(DtCriacao,1,10)) AS diffDate,
            CAST(strftime('%H', substr(dtcriacao,1,19)) AS INTEGER) AS dthora

    FROM transacoes

),

tb_cliente AS (

    SELECT  idCliente,
            datetime(substr(DtCriacao,1,19)) AS DtCriacao,
            julianday('now') - julianday(substr(DtCriacao,1,10)) AS idadebase

    FROM clientes
),

tb_sumario_transacoes AS (

    SELECT  idCliente,
            count(IdTransacao) AS qttrasacoesvida,
            count(CASE WHEN diffDate <= 56 THEN IdTransacao END) qttrasacoes56,
            count(CASE WHEN diffDate <= 28 THEN IdTransacao END) qttrasacoes28,
            count(CASE WHEN diffDate <= 14 THEN IdTransacao END) qttrasacoes14,
            count(CASE WHEN diffDate <= 7 THEN IdTransacao END) qttrasacoes7,
            min(diffDate) AS diasultimatransacao,
            sum(qtdePontos) AS saldopontos,

            sum(CASE WHEN qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS qtpontosposvida,
            sum(CASE WHEN qtdePontos > 0 AND diffdate <= 56 THEN qtdePontos ELSE 0 END) AS qtpontopos56,
            sum(CASE WHEN qtdePontos > 0 AND diffdate <= 28 THEN qtdePontos ELSE 0 END) AS qtpontopos28,
            sum(CASE WHEN qtdePontos > 0 AND diffdate <= 14 THEN qtdePontos ELSE 0 END) AS qtpontopos14,
            sum(CASE WHEN qtdePontos > 0 AND diffdate <= 7 THEN qtdePontos ELSE 0 END) AS qtpontopos7,

            sum(CASE WHEN qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS qtpontosnegvida,
            sum(CASE WHEN qtdePontos < 0 AND diffdate <= 56 THEN qtdePontos ELSE 0 END) AS qtpontoneg56,
            sum(CASE WHEN qtdePontos < 0 AND diffdate <= 28 THEN qtdePontos ELSE 0 END) AS qtpontoneg28,
            sum(CASE WHEN qtdePontos < 0 AND diffdate <= 14 THEN qtdePontos ELSE 0 END) AS qtpontoneg14,
            sum(CASE WHEN qtdePontos < 0 AND diffdate <= 7 THEN qtdePontos ELSE 0 END) AS qtpontoneg7
 
 

    FROM tb_transacoes
    GROUP BY idCliente

),

tb_transacao_produto AS (

    SELECT  t1.*,
            t3.DescNomeProduto,
            t3.DescCategoriaProduto

    FROM tb_transacoes AS t1

    LEFT JOIN transacao_produto AS t2
    ON t1.IdTransacao = t2.IdTransacao

    LEFT JOIN produtos as t3
    ON t2.IdProduto = t3.IdProduto
 
),

tb_cliente_produto AS ( 

    SELECT idCliente,  
            DescNomeProduto,
            count(*) AS qtdevida,
            count(CASE WHEN diffDate <= 56 THEN IdTransacao END) AS qtde56,
            count(CASE WHEN diffDate <= 28 THEN IdTransacao END) AS qtde28,
            count(CASE WHEN diffDate <= 14 THEN IdTransacao END) AS qtde14,
            count(CASE WHEN diffDate <= 7 THEN IdTransacao END) AS qtde7

    FROM tb_transacao_produto

    GROUP BY idCliente, DescNomeProduto

),

tb_CLiente_produto_rn AS (

    SELECT  *,
            row_number() OVER (PARTITION BY idCliente ORDER BY qtdevida DESC) AS rnVida,
            row_number() OVER (PARTITION BY idCliente ORDER BY qtde56 DESC) AS rn56,
            row_number() OVER (PARTITION BY idCliente ORDER BY qtde28 DESC) AS rn28,
            row_number() OVER (PARTITION BY idCliente ORDER BY qtde14 DESC) AS rn14,
            row_number() OVER (PARTITION BY idCliente ORDER BY qtde7 DESC) AS rn7

    FROM tb_cliente_produto

),

tb_cliente_dia AS (

SELECT idCliente,
        strftime('%w', DtCriacao) AS dtdia,
        count(*) AS QtdeTrasacao

FROM tb_transacoes
WHERE diffdate <= 28
GROUP BY idcliente, dtDia

),

tb_cliente_dia_rn AS (

SELECT  *,
        row_number() OVER (PARTITION BY idcliente ORDER BY qtdetrasacao DESC) as rndia

FROM tb_cliente_dia

),

tb_cliente_periodo AS (

SELECT  IdTransacao,
        idCliente,
        CASE 
            WHEN dthora BETWEEN 7 AND 12 THEN 'Manhã'
            WHEN dthora BETWEEN 13 AND 18 THEN 'Tarde'
            WHEN dthora BETWEEN 19 AND 23 THEN 'Noite'
            ELSE 'Sem informção'
        END AS Periodo,
        count(*) AS qtdetransacao

FROM tb_transacoes
WHERE diffdate <= 28
GROUP BY 1,2

),

tb_cliente_periodo_rn AS (

SELECT  *,
        row_number() OVER (PARTITION BY idCliente ORDER BY qtdetransacao DESC) as rnperiodo

FROM tb_cliente_periodo

),

tb_join AS (

SELECT  t1.*,
        t2.idadebase,
        t3.DescNomeProduto AS produtovida,
        t4.DescNomeProduto AS produto56,
        t5.DescNomeProduto AS produto28,
        t6.DescNomeProduto AS produto14,
        t7.DescNomeProduto AS produto7,
        coalesce(t8.dtdia, -1) AS dtDia,
        coalesce(t9.periodo, 'SEM INFORMAÇÃO')

FROM tb_sumario_transacoes AS t1

LEFT JOIN tb_cliente AS t2
ON t1.idCliente = t2.idcliente

LEFT JOIN tb_cliente_produto_rn AS t3
ON t1.idCliente = t3.idcliente
AND t3.rnvida = 1 

LEFT JOIN tb_cliente_produto_rn as t4
ON t1.idcliente = t4.idcliente 
AND t4.rn56 = 1

LEFT JOIN tb_cliente_produto_rn as t5
ON t1.idcliente = t4.idcliente 
AND t4.rn28 = 1

LEFT JOIN tb_cliente_produto_rn as t6
ON t1.idcliente = t4.idcliente 
AND t4.rn14 = 1

LEFT JOIN tb_cliente_produto_rn as t7
ON t1.idcliente = t4.idcliente 
AND t4.rn7 = 1

LEFT JOIN tb_cliente_dia_rn as t8
ON t1.idCliente = t8.idCliente
AND t8.rnDia = 1

LEFT JOIN tb_cliente_periodo_rn AS t9
ON t1.idCliente = t9.idCliente
AND t9.rnperiodo = 1 

)

SELECT  
        *,
        1.* qttrasacoes28 / qttrasacoesvida AS engajamento28vida

FROM tb_join
