use ex9

-- Consultar nome, valor unitário, nome da editora e nome do autor dos livros do
-- estoque que foram vendidos. Não pode haver repetições.
SELECT DISTINCT
	est.nome AS titulo_livro,
	est.valor,
	edi.nome AS nome_editora,
	aut.nome AS autor,
	com.qtdComprada
FROM estoque est
INNER JOIN editora edi
	ON est.codEditora = edi.codigo
INNER JOIN autor aut 
	ON est.codAutor = aut.codigo
INNER JOIN compra com
	ON com.codEstoque = est.codigo
WHERE com.qtdComprada IS NOT NULL;

-- Consultar nome do livro, quantidade comprada e valor de compra da compra 15051
SELECT
	est.nome, 
	comp.qtdComprada,
	comp.valor
FROM estoque est
INNER JOIN compra comp
	ON est.codigo = comp.codEstoque
WHERE comp.codigo = 15051;

-- Consultar Nome do livro e site da editora dos livros da Makron books (Caso o site
-- tenha mais de 10 dígitos, remover o www.).
SELECT 
	est.nome as titulo_livro,
	CASE WHEN(LEN(edit.site) > 10) THEN
		SUBSTRING(edit.site, 5)
	ELSE 
		edit.site
	END AS site
FROM estoque est
INNER JOIN editora edit
	ON edit.codigo = est.codEditora
WHERE edit.nome LIKE '%Makron Books%';

-- Consultar nome do livro e Breve Biografia do David Halliday
SELECT 
	est.nome as titulo_livro,
	aut.biografia
FROM estoque est
INNER JOIN autor aut
	ON est.codAutor = aut.codigo
WHERE aut.nome LIKE '%David Halliday%'; 

-- Consultar código de compra e quantidade comprada do livro Sistemas Operacionais
-- Modernos
SELECT 
	comp.codigo,
	comp.qtdComprada
FROM compra comp
INNER JOIN estoque est
	ON comp.codEstoque = est.codigo
WHERE est.nome LIKE '%Sistemas Operacionais Modernos%';

-- Consultar quais livros não foram vendidos
USE ex9;

SELECT 
	est.nome,
	comp.qtdComprada
FROM estoque est LEFT OUTER JOIN compra comp
	ON est.codigo = comp.codEstoque
WHERE comp.qtdComprada IS NULL;

-- Consultar quais livros foram vendidos e não estão cadastrados. Caso o nome dos
-- livros termine com espaço, fazer o trim apropriado.
SELECT 
	TRIM(est.nome) AS titulo_livro
FROM estoque est LEFT OUTER JOIN compra comp
	ON est.codigo != comp.codEstoque
WHERE comp.qtdComprada > 0;

-- Consultar Nome e site da editora que não tem Livros no estoque (Caso o site tenha
-- mais de 10 dígitos, remover o www.)
SELECT 
	edit.nome,
	CASE WHEN (len(edit.site) > 10) THEN	
		SUBSTRING(edit.site,5)
	ELSE
		edit.site
	END AS site_editora
FROM editora edit LEFT OUTER JOIN estoque est
	ON est.codEditora = edit.codigo
WHERE est.codEditora IS NULL;

-- Consultar Nome e biografia do autor que não tem Livros no estoque (Caso a
-- biografia inicie com Doutorado, substituir por Ph.D.)
SELECT 
	aut.nome,
	CASE WHEN (aut.biografia LIKE 'Doutorado%') THEN
		'Ph.D.' + SUBSTRING(aut.biografia, 10)
	ELSE 
		aut.biografia
	END AS biografia 
FROM autor aut
LEFT OUTER JOIN estoque est
	ON est.codAutor = aut.codigo
WHERE codAutor IS NULL;

-- Consultar o nome do Autor, e o maior valor de Livro no estoque. Ordenar por valor
-- descendente
SELECT
	aut.nome,
	MAX(est.valor) AS livro_mais_caro
FROM autor aut
INNER JOIN estoque est
	ON aut.codigo = est.codAutor
GROUP BY aut.nome
ORDER BY MAX(est.valor) DESC;

-- Consultar o código da compra, o total de livros comprados e a soma dos valores
-- gastos. Ordenar por Código da Compra ascendente.
SELECT
	comp.codigo,
	COUNT(comp.codEstoque) as qtd_livros_comprados,
	SUM(comp.valor) as valor_compra
FROM compra comp
GROUP BY comp.codigo
ORDER BY comp.codigo ASC;

-- Consultar o nome da editora e a média de preços dos livros em estoque. Ordenar
-- pela Média de Valores ascendente.
SELECT 
	edit.nome,
	AVG(est.valor) as valor_medio
FROM editora edit
INNER JOIN estoque est
	ON est.codEditora = edit.codigo
GROUP BY edit.nome
ORDER BY AVG(est.valor) ASC;

--Consultar o nome do Livro, a quantidade em estoque o nome da editora, o site da
--editora (Caso o site tenha mais de 10 dígitos, remover o www.), criar uma coluna
--status onde:
--Caso tenha menos de 5 livros em estoque, escrever Produto em Ponto de Pedido
--Caso tenha entre 5 e 10 livros em estoque, escrever Produto Acabando
--Caso tenha mais de 10 livros em estoque, escrever Estoque Suficiente
--A Ordena��o deve ser por Quantidade ascendente
SELECT
	est.nome,
	est.quantidade,
	edit.nome,
	CASE
		WHEN (LEN(edit.site) > 10) THEN SUBSTRING(edit.site,5)
		ELSE edit.site
	END AS editora_site,
	CASE 
		WHEN (est.quantidade < 5) THEN 'Produto em Ponto de Pedido'
		WHEN (est.quantidade >= 5 AND est.quantidade <= 10) THEN 'Produto Acabando'
		ELSE 'Estoque Suficiente'
	END AS status
FROM editora edit
INNER JOIN estoque est
	ON est.codEditora = edit.codigo;

--Para montar um relatório, é necessário montar uma consulta com a seguinte saída:
--Código do Livro, Nome do Livro, Nome do Autor, Info Editora (Nome da Editora + Site)
--de todos os livros
SELECT 
	est.codigo,
	est.nome,
	aut.nome,
	edit.nome + ', visite em: ' + edit.site AS info_editora
FROM estoque est
INNER JOIN autor aut
	ON aut.codigo = est.codAutor
INNER JOIN editora edit
	ON edit.codigo = est.codEditora
WHERE edit.site IS NOT NULL;

--Consultar Codigo da compra, quantos dias da compra até hoje e quantos meses da
--compra até hoje
SELECT 
	comp.codigo,
	DATEDIFF(DAY, comp.dataCompra, GETDATE()) as tempo_dias,
	DATEDIFF(MONTH, comp.dataCompra, GETDATE()) as tempo_meses
FROM compra comp;

-- Consultar o código da compra e a soma dos valores gastos das compras que somam
-- mais de 200.00
SELECT 
	comp.codigo,
	SUM(comp.valor) as valor_gasto
FROM compra comp
GROUP BY comp.codigo
HAVING SUM(comp.valor) > 200;
