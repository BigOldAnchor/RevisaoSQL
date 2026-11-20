CREATE DATABASE ex05
GO
USE ex05
GO
CREATE TABLE fornecedor (
codigo INT NOT NULL,
nome VARCHAR(50) NOT NULL,
atividade VARCHAR(80) NOT NULL,
telefone CHAR(8) NOT NULL
PRIMARY KEY(codigo)
)
GO
CREATE TABLE cliente (
codigo INT NOT NULL,
nome VARCHAR(50) NOT NULL,
logradouro VARCHAR(80) NOT NULL,
numero INT NOT NULL,
telefone CHAR(8) NOT NULL,
data_nasc DATE NOT NULL
PRIMARY KEY(codigo)
)
GO
CREATE TABLE produto (
codigo INT NOT NULL,
nome VARCHAR(50) NOT NULL,
valor_unitario DECIMAL(7,2) NOT NULL,
qtd_estoque INT NOT NULL,
descricao VARCHAR(80) NOT NULL,
cod_forn INT NOT NULL
PRIMARY KEY(codigo)
FOREIGN KEY(cod_forn) REFERENCES fornecedor(codigo)
)
GO
CREATE TABLE pedido (
codigo INT NOT NULL,
cod_cli INT NOT NULL,
cod_prod INT NOT NULL,
quantidade INT NOT NULL,
previsao_ent DATE NOT NULL
PRIMARY KEY(codigo, cod_cli, cod_prod, previsao_ent)
FOREIGN KEY(cod_cli) REFERENCES cliente(codigo),
FOREIGN KEY(cod_prod) REFERENCES produto(codigo)
)
GO
INSERT INTO fornecedor VALUES (1001,'Estrela','Brinquedo','41525898')
INSERT INTO fornecedor VALUES (1002,'Lacta','Chocolate','42698596')
INSERT INTO fornecedor VALUES (1003,'Asus','Informática','52014596')
INSERT INTO fornecedor VALUES (1004,'Tramontina','Utensílios Domésticos','50563985')
INSERT INTO fornecedor VALUES (1005,'Grow','Brinquedos','47896325')
INSERT INTO fornecedor VALUES (1006,'Mattel','Bonecos','59865898')
INSERT INTO cliente VALUES (33601,'Maria Clara','R. 1 de Abril',870,'96325874', CAST(N'2000-08-15' AS DATE))
INSERT INTO cliente VALUES (33602,'Alberto Souza','R. XV de Novembro',987,'95873625',
CAST(N'1985-02-02' AS DATE))
INSERT INTO cliente VALUES (33603,'Sonia Silva','R. Voluntários da Pátria',1151,'75418596',
CAST(N'1957-08-23' AS DATE))
INSERT INTO cliente VALUES (33604,'José Sobrinho','Av. Paulista',250,'85236547', CAST(N'1986-12-09' AS DATE))
INSERT INTO cliente VALUES (33605,'Carlos Camargo','Av. Tiquatira',9652,'75896325',
CAST(N'1971-03-25' AS DATE))
INSERT INTO produto VALUES (1,'Banco Imobiliário',65.00,15,'Versão Super Luxo',1001)
INSERT INTO produto VALUES (2,'Puzzle 5000 peças',50.00,5,'Mapas Mundo',1005)
INSERT INTO produto VALUES (3,'Faqueiro',350.00,0,'120 peças',1004)
INSERT INTO produto VALUES (4,'Jogo para churrasco',75.00,3,'7 peças',1004)
INSERT INTO produto VALUES (5,'Tablet',750.00,29,'Tablet',1003)
INSERT INTO produto VALUES (6,'Detetive',49.00,0,'Nova Versão do Jogo',1001)
INSERT INTO produto VALUES (7,'Chocolate com Paçoquinha',6.00,0,'Barra',1002)
INSERT INTO produto VALUES (8,'Galak',5.00,65,'Barra',1002)
INSERT INTO pedido VALUES (99001,33601,1,1,CAST(N'2026-09-07' AS DATE))
INSERT INTO pedido VALUES (99001,33601,2,1,CAST(N'2026-09-07' AS DATE))
INSERT INTO pedido VALUES (99001,33601,8,3,CAST(N'2026-09-09' AS DATE))
INSERT INTO pedido VALUES (99002,33602,2,1,CAST(N'2026-09-09' AS DATE))
INSERT INTO pedido VALUES (99002,33602,4,3,CAST(N'2026-09-09' AS DATE))
INSERT INTO pedido VALUES (99003,33605,5,1,CAST(N'2026-09-15' AS DATE))
GO

--Consultar a quantidade, valor total e valor total com desconto (25%) dos itens
--comprados par Maria Clara.
SELECT 
	pedido.quantidade,
	cast((pedido.quantidade * produto.valor_unitario) AS decimal(5,2)) as valor_total,
	CAST((pedido.quantidade * produto.valor_unitario * 0.75) AS decimal(5,2)) as valor_total_desconto
FROM pedido
INNER JOIN produto
	ON pedido.cod_prod = produto.codigo
INNER JOIN cliente
	ON cliente.codigo = pedido.cod_cli
WHERE cliente.nome LIKE '%Maria Clara%';

--Consultar quais brinquedos não tem itens em estoque.
SELECT 
	produto.nome
FROM produto
WHERE produto.qtd_estoque IS NULL OR
	produto.qtd_estoque = 0;

--Consultar quais nome e descrições de produtos que não estão em pedidos
SELECT * FROM pedido;
SELECT 
	produto.codigo,
	produto.nome,
	produto.descricao
FROM produto LEFT OUTER JOIN pedido
	ON pedido.cod_prod = produto.codigo
WHERE pedido.cod_prod IS NULL;

--Alterar a quantidade em estoque do faqueiro para 10 peças.
UPDATE produto
SET qtd_estoque = 10 WHERE nome LIKE '%Faqueiro%';

--Consultar Quantos clientes tem mais de 40 anos.
SELECT 
	COUNT(cliente.codigo) as maiores_40
FROM cliente
	WHERE DATEDIFF(YEAR, cliente.data_nasc, GETDATE()) > 40;

--Consultar Nome e telefone (Formatado XXXX-XXXX) dos fornecedores de Brinquedos e
--Chocolate.
SELECT
	fornecedor.nome,
	SUBSTRING(fornecedor.telefone, 1, 4) + '-' + SUBSTRING(fornecedor.telefone, 5, 8) as telefone
FROM fornecedor 
WHERE fornecedor.atividade LIKE 'Brinquedo%'
OR fornecedor.atividade LIKE '%Chocolate%';

--Consultar nome e desconto de 25% no preço dos produtos que custam menos de R$50,00
SELECT produto.valor_unitario, produto.nome FROM produto
SELECT 
	produto.nome,
	CAST((produto.valor_unitario * 0.75) AS DECIMAL(5,2)) as valor_desconto
FROM produto 
WHERE produto.valor_unitario IN
(
	SELECT produto.valor_unitario
	FROM produto
	WHERE produto.valor_unitario < 50
);

--Consultar nome e aumento de 10% no preço dos produtos que custam mais de R$100,00
SELECT 
	produto.nome,
	CAST((produto.valor_unitario * 1.10) AS DECIMAL(5,2)) as valor_aumento
FROM produto
WHERE produto.valor_unitario IN (
	SELECT 
		produto.valor_unitario
	FROM produto 
	WHERE produto.valor_unitario >  100
);

--Consultar desconto de 15% no valor total de cada produto da venda 99001.
SELECT
	CAST((produto.valor_unitario * 0.85) AS DECIMAL(5,2)) AS valor_desconto
FROM produto 
INNER JOIN pedido ON pedido.cod_prod = produto.codigo
WHERE pedido.codigo = 99001;

SELECT 
	pedido.codigo,
	cliente.nome,
	DATEDIFF(YEAR, cliente.data_nasc, GETDATE()) AS idade
FROM pedido
INNER JOIN cliente ON pedido.cod_cli = cliente.codigo;

--Consultar o nome do fornecedor do produto mais caro
SELECT 
	fornecedor.nome
FROM fornecedor 
INNER JOIN produto ON produto.cod_forn = fornecedor.codigo
WHERE produto.valor_unitario IN (
	SELECT 
		MAX(produto.valor_unitario)
	FROM produto
)

--Consultar a média dos valores cujos produtos ainda estão em estoque
SELECT
	CAST(AVG(produto.valor_unitario) AS DECIMAL(5,2)) as media_valor
FROM produto 
WHERE produto.qtd_estoque > 0;

--Consultar o nome do cliente, endereço composto por logradouro e número, o valor
--unitário do produto, o valor total (Quantidade * valor unitario) da compra do cliente
--de nome Maria Clara
SELECT
	cliente.nome,
	cliente.logradouro + ', ' + CAST(cliente.numero AS VARCHAR(10)) AS endereco,
	produto.valor_unitario,
	CAST((pedido.quantidade * produto.valor_unitario) AS DECIMAL(5,2)) AS valor_total
FROM cliente
INNER JOIN pedido ON pedido.cod_cli = cliente.codigo
INNER JOIN produto ON produto.codigo = pedido.cod_prod
WHERE cliente.nome LIKE '%Maria Clara%';

--Considerando que o pedido de Maria Clara foi entregue 15/03/2023, consultar
--quantos dias houve de atraso. A cláusula do WHERE deve ser o nome da cliente.
SELECT 
	DATEDIFF(DAY, pedido.previsao_ent, '2023-03-15') as dias_atraso
FROM pedido 
INNER JOIN cliente ON cliente.codigo = pedido.cod_cli
WHERE cliente.nome LIKE '%Maria Clara%';

--Consultar qual a nova data de entrega para o pedido de Alberto% sabendo que se
--pediu 9 dias a mais. A cláusula do WHERE deve ser o nome do cliente. A data deve ser
--exibida no formato dd/mm/aaaa.
SELECT 
	CONVERT(CHAR(10),DATEADD(DAY, 9, pedido.previsao_ent), 103) as nova_data
FROM pedido
INNER JOIN cliente ON cliente.codigo = pedido.cod_cli
WHERE cliente.nome LIKE 'Alberto%';