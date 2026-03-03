WITH 

tb_transacoes AS (

    SELECT  IdTransacao,
            idcliente,
            qtdePontos,
            datetime(substr(DtCriacao,1,19)) AS DtCriacao,
            julianday('now') - julianday(substr(DtCriacao,1,10)) AS diffDate

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

tb_join AS (

    SELECT  t1.*,
            t2.idadebase

    FROM tb_sumario_transacoes AS t1

    LEFT JOIN tb_cliente AS t2
    ON t1.idCliente = t2.idCliente

)

SELECT  t1.*,
        t2.IdProduto

FROM tb_transacoes AS t1

LEFT JOIN transacao_produto AS t2
ON t1.IdTransacao = t2.IdTransacao

LEFT JOIN produtos as t3
ON t2.IdProduto = t3.id produtos
 
