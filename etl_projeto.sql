WITH 

tb_transacoes AS (

    SELECT  IdTransacao,
            idcliente,
            qtdePontos,
            datetime(substr(DtCriacao,1,19)) AS DtCriacao,
            julianday('now') - julianday(substr(DtCriacao,1,10)) AS diffDate

    FROM transacoes        

)

SELECT  idCliente,
        count(IdTransacao) AS qttrasacoesvida,
        count(CASE WHEN diffDate <= 56 THEN IdTransacao END) qttrasacoes56,
        count(CASE WHEN diffDate <= 28 THEN IdTransacao END) qttrasacoes28,
        count(CASE WHEN diffDate <= 14 THEN IdTransacao END) qttrasacoes14,
        count(CASE WHEN diffDate <= 7 THEN IdTransacao END) qttrasacoes7,
        min(diffDate) AS diasultimatransacao

FROM tb_transacoes
GROUP BY idCliente