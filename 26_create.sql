--DROP TABLE IF EXISTS clientes_d28;

CREATE TABLE clientes_d28 (
    idcliente varchar(250) PRIMARY KEY,
    QtdeTrasacoes INTERGER
);

DELETE FROM clientes_d28;

INSERT INTO clientes_d28
SELECT idCliente,
        count(DISTINCT IdTransacao) as QtdeTrasacoes

FROM transacoes
WHERE julianday('now') - julianday(substr(DtCriacao,1,10)) <= 28
GROUP BY idCliente;


SELECT * FROM clientes_d28; 